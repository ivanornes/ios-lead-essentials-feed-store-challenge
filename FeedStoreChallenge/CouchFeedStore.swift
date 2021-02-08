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
	
	public init() {
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		completion(.empty)
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
	}
}
