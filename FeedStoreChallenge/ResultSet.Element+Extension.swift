//
//  ResultSet.Element+Extension.swift
//  FeedStoreChallenge
//
//  Created by Ivan Ornes on 11/2/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import CouchbaseLiteSwift

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
