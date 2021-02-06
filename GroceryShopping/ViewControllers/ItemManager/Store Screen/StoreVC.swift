//
//  StoreVC.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 2/4/21.
//

import UIKit

class StoreVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var items: [Item] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        loadUserItems()
    }
    
    func loadUserItems() {
        do {
            items = try UserDefaults.standard.get(objectType: [Item].self, forKey: "items") ?? []
        } catch {
            showFailureToast(message: "Error getting items")
        }
        
        for (index, item) in items.enumerated() {
            if !item.stores.contains(Store(name: navigationItem.title!)) {
                //items.remove(at: index)
            }
        }
    }
    
    
    @IBAction func backToHomeScreen(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func launchItemScreen(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(identifier: "AddItemsExisting") as! StoreItemManagerVC
        vc.storeName = navigationItem.title!
        let navController = UINavigationController(rootViewController: vc)
        navigationController?.present(navController, animated: true, completion: nil)
    }
}

extension StoreVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ItemCell.identifier) as! ItemCell
        cell.itemName.text = items[indexPath.row].name
        cell.lastBought.text = "1/29"
        return cell
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
