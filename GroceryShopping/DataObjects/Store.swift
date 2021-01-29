//
//  Store.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 1/19/21.
//

import Foundation
struct Store: Codable, Equatable {
    
    var name: String
}

//struct Color: Codable {
//    var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0
//
//    var color: UIColor {
//        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
//    }
//
//    init(color: UIColor) {
//        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
//    }
//}
// MARK: - UserDefaults extensions

public extension UserDefaults {

    /// Set Codable object into UserDefaults
    ///
    /// - Parameters:
    ///   - object: Codable Object
    ///   - forKey: Key string
    /// - Throws: UserDefaults Error
    func set<T: Codable>(object: T, forKey: String) throws {

        let jsonData = try JSONEncoder().encode(object)

        set(jsonData, forKey: forKey)
    }

    /// Get Codable object into UserDefaults
    ///
    /// - Parameters:
    ///   - object: Codable Object
    ///   - forKey: Key string
    /// - Throws: UserDefaults Error
    func get<T: Codable>(objectType: T.Type, forKey: String) throws -> T? {

        guard let result = value(forKey: forKey) as? Data else {
            return nil
        }

        return try JSONDecoder().decode(objectType, from: result)
    }
}
