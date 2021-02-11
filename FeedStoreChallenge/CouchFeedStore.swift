//
//  CouchFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Ivan Ornes on 8/2/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import CouchbaseLiteSwift

public class CouchFeedStore: FeedStore {
	
	private let database: Database
	
	public init(databaseName: String) throws {
		self.database = try Database(name: databaseName)
	}

	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		let feedDocumets = feed.map { $0.toMutableDocument() }
		let timestampDocument = MutableDocument(id: "timestamp")
		/// Saving the timestamp as a timeIntervalSinceReferenceDate string avoids loosing precision
		timestampDocument.setString("\(timestamp.timeIntervalSinceReferenceDate)", forKey: "timestamp")
		timestampDocument.setString("timestamp", forKey: "type")
		do {
			try deleteAllDocuments()
			try database.inBatch {
				try database.saveDocument(timestampDocument)
				for document in feedDocumets {
					try database.saveDocument(document)
				}
			}
			completion(nil)
		} catch {
			completion(error)
		}
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		let imageFeedQuery = QueryBuilder
			.select(
					SelectResult.expression(Meta.id),
					SelectResult.property("url"),
					SelectResult.property("location"),
					SelectResult.property("description")
				)
			.from(DataSource.database(database))
		
		let timestampQuery = QueryBuilder
			.select(
				SelectResult.expression(Meta.id),
				SelectResult.property("timestamp")
			)
			.from(DataSource.database(database))
			.where(Expression.property("type").equalTo(Expression.string("timestamp")))
			.limit(Expression.int(1))
		
		do {
			let timestampResults = try timestampQuery.execute()
			let imageFeedResults = try imageFeedQuery.execute()
			var timestamp: Date = .init()
			for result in timestampResults {
				timestamp = Date(timeIntervalSinceReferenceDate: TimeInterval(result.string(forKey: "timestamp")!)!)
			}
			
			let mappedImages = imageFeedResults.compactMap { $0.localFeedImage }
			if mappedImages.isEmpty {
				completion(.empty)
			} else {
				completion(.found(feed: mappedImages, timestamp: timestamp))
			}
		} catch {
			completion(.failure(error))
		}
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		do {
			try deleteAllDocuments()
			completion(nil)
		} catch {
			completion(error)
		}
	}
	
	private func deleteAllDocuments() throws {
		let results = try QueryBuilder
			.select(SelectResult.expression(Meta.id))
			.from(DataSource.database(database))
			.execute()
		
		for result in results.allResults() {
			if let id = result.string(forKey: "id"),
			   let document = database.document(withID: id) {
				try database.deleteDocument(document)
			}
		}
	}
}

extension ResultSet.Element {
	var localFeedImage: LocalFeedImage? {
		guard let id = string(forKey: "id"),
			  let imageID = UUID(uuidString: id),
			  let imageURL = string(forKey: "url"),
			  let url = URL(string: imageURL) else { return nil }
		return LocalFeedImage(id: imageID,
					   description: string(forKey: "description"),
					   location: string(forKey: "location"),
					   url: url)
	}
}

extension LocalFeedImage {
	func toMutableDocument() -> MutableDocument {
		let document = MutableDocument(id: id.uuidString, data: ["url": url.absoluteString])
		if let location = location {
			document.setString(location, forKey: "location")
		}
		if let description = description {
			document.setString(description, forKey: "description")
		}
		return document
	}
}
