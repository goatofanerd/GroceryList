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
}
