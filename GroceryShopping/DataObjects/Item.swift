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
    
    mutating func changeBoughtTime(date: DateComponents) {
        lastBought = date
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
