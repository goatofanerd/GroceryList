//
//  StoreVC.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 2/4/21.
//

import UIKit

class StoreVC: UIViewController {
    
    @IBOutlet weak var addNewItemField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var existingItems: [Item] = []
    var items: [Item] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.hideKeyboardWhenTappedAround()
        tableView.rowHeight = 60
        tableView.dataSource = self
        tableView.delegate = self
        
        addNewItemField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadUserItems()
    }
    
    func loadUserItems() {
        items = []
        do {
            existingItems = try UserDefaults.standard.get(objectType: [Item].self, forKey: "items") ?? []
        } catch {
            showFailureToast(message: "Error getting items")
        }
        
        for item in existingItems {
            if item.stores.contains(Store(name: navigationItem.title!)) {
                items.append(item)
            }
        }
    }
    
    
    @IBAction func backToHomeScreen(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        save()
    }
    
    func save() {
        do {
            try UserDefaults.standard.set(object: existingItems, forKey: "items")
        } catch {
            navigationController?.viewControllers[0].showFailureToast(message: "Error saving items!")
        }
    }
}

extension StoreVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ItemCell.identifier) as! ItemCell
        cell.itemName.text = items[indexPath.row].name
        if let date = items[indexPath.row].lastBought {
            cell.lastBought.text = "\(date.month!)/\(date.day!)"
        } else {
            cell.lastBought.text = ""
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension StoreVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        addItemToList()
        addNewItemField.text = ""
        return true
    }
    
    func addItemToList() {
        
        var itemNames: [String] = []
        
        for item in items {
            itemNames.append(item.name)
        }
        
        guard !itemNames.contains(addNewItemField.text!) else {
            showFailureToast(message: "Item already exists!")
            return
        }
        
        var added = false
        for (index, var item) in existingItems.enumerated() {
            
            if item.name == addNewItemField.text! {
                item.addStore(self.navigationItem.title!)
                added = true
                existingItems[index] = item
                items.append(item)
            }
            
        }
        
        if !added {
            let newItem = Item(name: addNewItemField.text!, stores: [Store(name: self.navigationItem.title!)])
            items.append(newItem)
            existingItems.append(newItem)
        }
        
        tableView.insertRows(at: [IndexPath(row: items.count - 1, section: 0)], with: .left)
    }
}



//MARK: -Delete Store
extension StoreVC {
    @IBAction func deleteStore(_ sender: Any) {
        let alert = UIAlertController(title: "Are you sure you want to delete?", message: "This action is irreversible!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {_ in
            do {
                let storeName = self.navigationItem.title!
                var tempItems: [Item] = []
                let items = try UserDefaults.standard.get(objectType: [Item].self, forKey: "items")!
                for var item in items {
                    if item.stores.contains(Store(name: storeName)) {
                        item.stores.remove(at: item.stores.firstIndex(of: Store(name: storeName))!)
                    }
                    tempItems.append(item)
                }
                
                try UserDefaults.standard.set(object: tempItems, forKey: "items")
                var stores = try UserDefaults.standard.get(objectType: [Store].self, forKey: "stores")!
                stores.remove(at: stores.firstIndex(of: Store(name: storeName))!)
                try UserDefaults.standard.set(object: stores, forKey: "stores")
                self.navigationController?.viewControllers[0].showToast(message: "Successfully deleted!", image: UIImage(systemName: "trash")!)
                self.navigationController?.popViewController(animated: true)
            } catch {
                self.showFailureToast(message: "Error deleting!")
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}
