//
//  Item.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 1/26/21.
//

import UIKit

struct Item: Codable {
    var name: String!
    var stores: [Store] = []
    var lastBought: Date?
    
    mutating func addStore(_ store: String, color: UIColor) {
        let uiColor: Color = Color(color: color)
        stores.append(Store(name: store, color: uiColor))
    }
    
    mutating func changeBoughtTime(date: Date) {
        lastBought = date
    }
}
