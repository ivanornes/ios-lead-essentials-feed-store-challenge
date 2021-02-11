//
//  Date+Extension.swift
//  FeedStoreChallenge
//
//  Created by Ivan Ornes on 11/2/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import CouchbaseLiteSwift

extension Date {
	var document: MutableDocument {
		let timestampDocument = MutableDocument(id: "timestamp")
		/// Saving the timestamp as a timeIntervalSinceReferenceDate string avoids loosing precision
		timestampDocument.setString("\(timeIntervalSinceReferenceDate)", forKey: "timestamp")
		timestampDocument.setString("timestamp", forKey: "type")
		return timestampDocument
	}
}
