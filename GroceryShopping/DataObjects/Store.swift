//
//  Store.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 1/19/21.
//
import UIKit
struct Store: Codable, Equatable {
    static func == (lhs: Store, rhs: Store) -> Bool {
        return lhs.name == rhs.name
    }
    
    var name: String
    var color: Color
    
    init(name: String, color: UIColor = .systemBlue) {
        self.name = name
        self.color = Color(color: color)
    }
}

extension Array where Element == Store {
    func firstStore(name: String) -> Int? {
        let names = getNames()
        
        return names.firstIndex(of: name)
    }
    func containsStore(_ element: Store) -> Bool {
        let names = getNames()
        return names.contains(element.name)
    }
    
    mutating func removeStore(withStore name: String) throws {
        let names = getNames()
        
        if let index = names.firstIndex(of: name) {
            remove(at: index)
        }
        
    }
    
    private func getNames() -> [String] {
        var names: [String] = []
        for store in self {
            names.append(store.name)
        }
        return names
    }
}

struct Color: Codable {
    var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0

    var color: UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    init(color: UIColor) {
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
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
