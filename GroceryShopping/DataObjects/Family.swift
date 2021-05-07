//
//  Family.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 4/11/21.
//

import UIKit
import FirebaseDatabase

struct Family {
    static var items: [Item] = []
    static var stores: [Store] = []
    static var id: String?
    static var hasAddedNotifications = false
    static func reset() {
        self.items.removeAll()
        self.stores.removeAll()
        hasAddedNotifications = false
        id = nil
    }
    
    static func getFamily(email: String, completion: @escaping((String?) -> Void)) {
        let ref = Database.database().reference().child("user_emails").child(email.toLegalStorageEmail()).child("family")
        ref.observeSingleEvent(of: .value) { (snap) in
            completion(snap.value as? String)
        }
    }
}
