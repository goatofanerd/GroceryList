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
    var storeName: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.hideKeyboardWhenTappedAround()
        tableView.rowHeight = 60
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        addNewItemField.delegate = self
        storeName = self.navigationItem.title!
        navigationItem.largeTitleDisplayMode = .always
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadUserItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.setContentOffset(.zero, animated: true)
    }
    
    func loadUserItems() {
        items = []
        do {
            existingItems = try UserDefaults.standard.get(objectType: [Item].self, forKey: "items") ?? []
        } catch {
            showFailureToast(message: "Error getting items")
        }
        
        for var item in existingItems {
            if item.stores.containsStore(Store(name: storeName)) {
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
        
        //Separator Full Line
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let bought = boughtAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [bought])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func boughtAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Bought") { (action, view, completion) in
            
            if let index = self.existingItems.firstIndex(of: self.items[indexPath.row]) {
                self.existingItems[index].changeBoughtTime()
                self.existingItems[index].removeStore(withName: self.storeName)
            }
            self.items.remove(at: indexPath.row)
            
            self.tableView.deleteRows(at: [indexPath], with: .middle)
            self.showSuccessToast(message: "Marked item as bought.")
            completion(true)
            
        }
        action.backgroundColor = .systemGreen
        
        return action
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let action = UIContextualAction(style: .destructive, title: "") { (action, view, completion) in
            if let index = self.existingItems.firstIndex(of: self.items[indexPath.row]) {
                self.existingItems[index].removeStore(withName: self.storeName)
            }
            self.items.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .middle)
            self.showToast(message: "Deleted item.", image: UIImage(systemName: "trash")!, color: .red, fontColor: .red)
            completion(true)
            
        }
        action.image = UIImage(systemName: "trash")
        
        return action
    }
    
    
    
}

extension StoreVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addItemToList()
        addNewItemField.text = ""
        return true
    }
    
    func addItemToList() {
        guard !items.containsItem(Item(name: addNewItemField.text!)) else {
            showFailureToast(message: "Item already exists!")
            return
        }
        
        var added = false
        for (index, var item) in existingItems.enumerated() {
            
            if item.name == addNewItemField.text! {
                item.addStore(storeName)
                added = true
                existingItems[index] = item
                items.append(item)
            }
            
        }
        
        if !added {
            let newItem = Item(name: addNewItemField.text!, stores: [Store(name: storeName)])
            items.append(newItem)
            existingItems.append(newItem)
        }
        
        tableView.insertRows(at: [IndexPath(row: items.count - 1, section: 0)], with: .left)
        
        tableView.scrollToRow(at: IndexPath(row: items.count - 1, section: 0), at: .bottom, animated: true)
    }
}



//MARK: -Delete Store
extension StoreVC {
    @IBAction func deleteStore(_ sender: Any) {
        let alert = UIAlertController(title: "Are you sure you want to delete?", message: "This action is irreversible!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [self]_ in
            do {
                var tempItems: [Item] = []
                let items = try UserDefaults.standard.get(objectType: [Item].self, forKey: "items")!
                for var item in items {
                    if item.stores.containsStore(Store(name: storeName)) {
                        try item.stores.removeStore(withStore: storeName)
                    }
                    tempItems.append(item)
                }
                
                try UserDefaults.standard.set(object: tempItems, forKey: "items")
                var stores = try UserDefaults.standard.get(objectType: [Store].self, forKey: "stores")!
                try stores.removeStore(withStore: storeName)
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
