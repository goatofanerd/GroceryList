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
    var neededStores: [Store] = []
    init(name: String, stores: [Store] = [], lastBought: DateComponents? = nil, neededStores: [Store] = []) {
        self.name = name
        self.stores = stores
        self.lastBought = lastBought
        
        if neededStores.isEmpty {
            self.neededStores = stores
        } else {
            self.neededStores = neededStores
        }
    }
    
    mutating func addStore(_ store: String) {
        if !stores.containsStore(Store(name: store)) {
            stores.append(Store(name: store))
            neededStores.append(Store(name: store))
        }
    }
    
    mutating func changeBoughtTime() {
        lastBought = DateComponents(month: Calendar.current.component(.month, from: Date()), day: Calendar.current.component(.day, from: Date()))
    }
    
    mutating func removeStore(at index: Int) {
        do {
            try neededStores.removeStore(withStore: stores[index].name)
        } catch {}
        stores.remove(at: index)
    }
    
    mutating func removeStore(withName: String) {
        if let index = stores.firstIndex(of: Store(name: withName)) {
            removeStore(at: index)
        }
    }
    
    mutating func markStoreAsOpposite(store: Store) {
        if neededStores.containsStore(store) {
            do {
                try neededStores.removeStore(withStore: store.name)
            } catch {}
        } else {
            neededStores.append(store)
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

extension Array where Element == Item {
    func containsItem(_ element: Item) -> Bool {
        let names = getNames()
        return names.contains(element.name)
    }
    
    mutating func removeItem(withItem name: String) throws {
        let names = getNames()
        
        if let firstIndex = names.firstIndex(of: name) {
            self.remove(at: firstIndex)
        } else {
            throw "Error Deleting"
        }
    }
    
    private func getNames() -> [String] {
        var names: [String] = []
        for item in self {
            names.append(item.name)
        }
        return names
    }
    
    func indexOfItem(_ item: Item) -> Int? {
        let names = getNames()
        return names.firstIndex(of: item.name)
    }
}

extension String: Error {}
