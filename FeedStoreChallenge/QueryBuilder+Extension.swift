//
//  QueryBuilder+Extension.swift
//  FeedStoreChallenge
//
//  Created by Ivan Ornes on 11/2/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import CouchbaseLiteSwift

extension QueryBuilder {
	class func allDocumentsQuery(from database: Database) -> From {
		select(SelectResult.expression(Meta.id))
			.from(DataSource.database(database))
	}
	
	class func allFeedImagesQuery(from database: Database) -> From {
		select(
				SelectResult.expression(Meta.id),
				SelectResult.property("url"),
				SelectResult.property("location"),
				SelectResult.property("description")
			)
		.from(DataSource.database(database))
	}
	
	class func allDocuments(from database: Database) throws -> [Document] {
		try allDocumentsQuery(from: database).execute().allResults().compactMap { result -> Document? in
			if let id = result.string(forKey: "id") {
				return database.document(withID: id)
			}
			return nil
		}
	}
}

