//
//  Item.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 1/26/21.
//

import Foundation

struct Item: Codable, Equatable {
    var name: String!
    var stores: [Store] = []
    var lastBought: DateComponents?
    
    init(name: String, stores: [Store] = [], lastBought: DateComponents? = nil) {
        self.name = name
        self.stores = stores
        self.lastBought = lastBought
    }
    
    mutating func addStore(_ store: String) {
        if !stores.contains(Store(name: store)) {
            stores.append(Store(name: store))
        }
    }
    
    mutating func changeBoughtTime() {
        lastBought = DateComponents(month: Calendar.current.component(.month, from: Date()), day: Calendar.current.component(.day, from: Date()))
    }
    
    mutating func removeStore(at index: Int) {
        stores.remove(at: index)
    }
    
    mutating func removeStore(withName: String) {
        if let index = stores.firstIndex(of: Store(name: withName)) {
            removeStore(at: index)
        }
    }
    
    func getYear() -> Int? {
        return lastBought?.year
    }
    
    func getMonth() -> Int? {
        return lastBought?.month
    }
    
    func getDay() -> Int? {
        return lastBought?.day
    }
}
