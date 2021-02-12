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
		database = try Database(name: databaseName)
	}

	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		do {
			try deleteAllDocuments()
			try database.inBatch {
				try database.saveDocument(timestamp.document)
				for document in feed.map({ $0.toMutableDocument() }) {
					try database.saveDocument(document)
				}
			}
			completion(nil)
		} catch {
			completion(error)
		}
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		let imageFeedQuery = QueryBuilder.allFeedImagesQuery(from: database)
		do {
			let mappedImages = try imageFeedQuery.execute().compactMap { $0.localFeedImage }
			if let timestamp = QueryBuilder.timestamp(from: database) {
				completion(.found(feed: mappedImages, timestamp: timestamp))
			} else {
				completion(.empty)
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
		try QueryBuilder.allDocuments(from: database).forEach { try database.deleteDocument($0) }
	}
}
