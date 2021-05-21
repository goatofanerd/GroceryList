//
//  StorageUpdates.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 4/19/21.
//

import UIKit
import GoogleSignIn
import FirebaseDatabase
extension Family {
    
    /// Post notifications when the storage location is updated
    /// - Parameters:
    ///   - ref: Respective Family Ref for user
    ///   - user: Current user for the app
    static func addNotificationsForStorageUpdates(familyRef: DatabaseReference, user: GIDGoogleUser) {
        
        self.hasAddedNotifications = true
        
        familyRef.child("items").observe(.value) { (snapshot) in
            print("items changed")
            do {
                if let items = snapshot.value as? String {
                    self.items = try HelperFunctions.decodeFromString(items, objectType: [Item].self)
                }
                NotificationCenter.default.post(name: .individualStoreUpdated, object: nil)
            } catch {
                print("error decoding items")
            }
        }
        
        familyRef.child("stores").observe(.value) { (snapshot) in
            print("stores changed")
            
            do {
                if let stores = snapshot.value as? String {
                    self.stores = try HelperFunctions.decodeFromString(stores, objectType: [Store].self)
                }
                NotificationCenter.default.post(name: .newStoreAdded, object: nil)
            } catch {
                print("error decoding stores")
            }
        }
        
        familyRef.child("people").observe(.value) { (snapshot) in
            print("people changed")
            NotificationCenter.default.post(name: .newMemberAdded, object: nil)
        }
        
        familyRef.child("bought_items").observe(.value) { (snapshot) in
            print("bought items changed")
            NotificationCenter.default.post(name: .itemAddedToCart, object: nil)
        }
    }
    
    static func getMostRecentChange(familyRef: DatabaseReference, completion: @escaping((String, String) -> Void)) {
        
        familyRef.child("recent_change").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                let dictionary = snapshot.value as! NSDictionary
                completion(dictionary.allValues[0] as! String, dictionary.allValues[1] as! String)
            }
        }
        
        
    }
}
