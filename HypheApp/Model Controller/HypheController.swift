//
//  HypheController.swift
//  HypheApp
//
//  Created by Julia Rodriguez on 7/9/19.
//  Copyright © 2019 Julia Rodriguez. All rights reserved.
//

import Foundation
import CloudKit

class HypheController {
    
    //MARK: - Hyphe cannot be controlled
    let publicDB = CKContainer.default().publicCloudDatabase
    
    // Singleton
    static let sharedInstance = HypheController()
    
    // Source of Truth
    var hyphes: [Hyphe] = []
    
    // CRUD
    
    // Save, gave Date a default value do not need to initialize
    // call back/ closure / completion handler = @escaping, give a Bool otherwise Void (noting), -> = OR
    func saveHyphe(with text: String, completion: @escaping (Bool) -> Void) {
        
        let hype = Hyphe(hypheText: text)
        let hypheRecord = CKRecord(hyphe: hype)
        
        // use _ when we do not use it in the scope { }. Not re-initialize the same object twice, used a wild operator instead 
        publicDB.save(hypheRecord) { (_, error) in
            if let error = error {
                print("There was an error: \(error.localizedDescription)")
                completion(false)
                return
            }
            //self.hyphes.append(hype)
            // add newest hyphe at the very top of the array 
            self.hyphes.insert(hype, at: 0)
            completion(true)
        }
        
    }
    
    // Fetch, know if the fetch is successful, use a closure return a Bool or nothing
    func fetchDemHyphes(completion: @escaping (Bool) -> Void) {
        
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: Constants.recordTypeKey, predicate: predicate)
        
        query.sortDescriptors = [NSSortDescriptor(key: Constants.recordTimestampKey, ascending: false)]
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("there was an error performing query: \(error.localizedDescription)")
                completion(false)
                return
            }
            guard let records = records else { completion(false); return }
            // initialize a Hyphe(ckRecord: $0)
            // compact map creates an array of records, which self.hyphe is an [Hyphe]
            let hyphes = records.compactMap({ Hyphe(ckRecord: $0)})
            self.hyphes = hyphes
            completion(true)
            
        }
    }
    // Subscription, completion: know wether it was successful or not
    func subscribeToRemoteNotifications(completion: @escaping (Error?) -> Void) {
        let predicate = NSPredicate(value: true)
        
        let subscription = CKQuerySubscription(recordType: Constants.recordTypeKey, predicate: predicate, options: .firesOnRecordCreation)
        
        // Accessing CKSubscription's notification info property, and editing it
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.alertBody = "Hello, user - there is a new hyphe!"
        notificationInfo.shouldBadge = true
        notificationInfo.soundName = "default"
        
        // Take edited values and set it to our subscription's notification info (original)
        subscription.notificationInfo = notificationInfo
        
        publicDB.save(subscription) { (_, error) in
            if let error = error {
                print("there was an error saving subscription: \(error.localizedDescription)")
                completion(error)
                return
            }
            // dont have an error, complete with nil
            completion(nil)
        }
    }
    
    
    
    
    
}
