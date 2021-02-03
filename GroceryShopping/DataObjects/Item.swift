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
    var lastBought: Date?
    
    init(name: String, stores: [Store] = [], lastBought: Date? = nil) {
        self.name = name
        self.stores = stores
        self.lastBought = lastBought
    }
    
    mutating func addStore(_ store: String) {
        if !stores.contains(Store(name: store)) {
            stores.append(Store(name: store))
        }
    }
    
    mutating func changeBoughtTime(date: Date) {
        lastBought = date
    }
}
