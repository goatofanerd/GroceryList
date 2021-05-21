//
//  NotificationNames.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 3/1/21.
//

import Foundation

extension Notification.Name {
    
    /// Notification when user successfully sign in using Google
    static var signInGoogleCompleted: Notification.Name {
        return .init(rawValue: #function)
    }
    
    /// Notification when current user has signed into their family
    static var signedIntoFamily: Notification.Name {
        return .init(rawValue: #function)
    }
    
    /// Notification when an item in a store is changed by a separate user
    static var individualStoreUpdated: Notification.Name {
        return .init(rawValue: #function)
    }
    
    /// Notification when a new user has joined the family
    static var newMemberAdded: Notification.Name {
        return .init(rawValue: #function)
    }
    
    /// Notification when another store has been added by a separate user.
    static var newStoreAdded: Notification.Name {
        return .init(rawValue: #function)
    }
    
    /// Notification when an item has been marked as bought/removed from bought
    static var itemAddedToCart: Notification.Name {
        return .init(rawValue: #function)
    }
}
