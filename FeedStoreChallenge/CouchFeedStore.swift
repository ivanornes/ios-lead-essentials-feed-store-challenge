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
		
		do {
			let imageFeedResults = try imageFeedQuery.execute()
			let mappedImages = imageFeedResults.compactMap { $0.localFeedImage }
			if mappedImages.isEmpty {
				completion(.empty)
			} else {
				let value = database.document(withID: "timestamp")!.string(forKey: "timestamp")!
				let timestamp = Date(timeIntervalSinceReferenceDate: TimeInterval(value)!)
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
