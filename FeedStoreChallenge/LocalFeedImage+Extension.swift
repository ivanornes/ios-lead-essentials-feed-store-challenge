//
//  LocalFeedImage+extension.swift
//  FeedStoreChallenge
//
//  Created by Ivan Ornes on 11/2/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import CouchbaseLiteSwift

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
