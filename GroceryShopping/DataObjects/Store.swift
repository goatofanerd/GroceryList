//
//  Store.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 1/19/21.
//

import Foundation

struct Store: Codable, Equatable {
    
    var name: String
    var items = Dictionary<String, Int>()
    
    init(name: String) {
        self.name = name
    }
    
    mutating func addItem(item: String, priority: Int) {
        items.updateValue(priority, forKey: item)
    }
    
    func getItem(atIndex index: Int) -> (String, Int){
        let key = Array(items.keys)[index]
        let value = Array(items)[index].value
        return (key, value)
        
    }
    
    func contains(_ nameOf: String) -> Bool{
        if self.name == nameOf {
            return true
        }
        return false
    }
    
    mutating func removeItem(_ key: String) {
        items.removeValue(forKey: key)
    }
}

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
