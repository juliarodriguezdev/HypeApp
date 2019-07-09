//
//  Hyphe.swift
//  HypheApp
//
//  Created by Julia Rodriguez on 7/9/19.
//  Copyright © 2019 Julia Rodriguez. All rights reserved.
//

import Foundation
import CloudKit

// structs are lighter than classes

struct Constants {
    static let recordTypeKey = "Hyphe"
    fileprivate static let recordTextKey = "Text"
    fileprivate static let recordTimestampKey = "Timestamp"
}

class Hyphe {
    
    let hypheText: String
    let timestamp: Date
    
    // designated initializer
    init(hypheText: String, timestamp: Date) {
        
        self.hypheText = hypheText
        self.timestamp = timestamp
    }
}

extension Hyphe {
    // Creating a faliable convenience Hyphe from a record
    convenience init?(ckRecord: CKRecord) {
        
        guard let hypeText = ckRecord[Constants.recordTextKey] as? String, let hypheTimestamp = ckRecord[Constants.recordTimestampKey] as? Date else { return nil }
        // initalizing a Hype from the CKRecord
        self.init(hypheText: hypeText, timestamp: hypheTimestamp)
    }
    
}

    // Creating a CKRecord
extension CKRecord {
    // convenience initializer for ckRecord from Hyphe (Model)
    convenience init(hyphe: Hyphe) {
        self.init(recordType: Constants.recordTypeKey)
        self.setValue(hyphe.hypheText, forKey: Constants.recordTextKey)
        self.setValue(hyphe.timestamp, forKey: Constants.recordTimestampKey)
    }
}
