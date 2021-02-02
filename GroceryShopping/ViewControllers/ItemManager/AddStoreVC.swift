//
//  AddItemVC.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 1/29/21.
//

import UIKit

class AddStoreVC: UIViewController {

    @IBOutlet weak var createButton: UIBarButtonItem!
    @IBOutlet weak var itemName: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        itemName.layer.borderWidth = 2
        itemName.layer.borderColor = UIColor.gray.cgColor
        createButton.tintColor = .gray
    }
    
    @IBAction func cancel(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func createStoreAndExit(_ sender: Any) {
        guard createButton.tintColor != .gray else { return }
        guard let store = itemName.title(for: .normal)?.trimmingCharacters(in: .whitespacesAndNewlines) else { Alert.regularAlert(title: "Empty Store Name", message: "Please have a proper store name.", vc: self); return }
        do {
            var stores = try UserDefaults.standard.get(objectType: [Store].self, forKey: "stores") ?? []
            if !stores.contains(Store(name: store)) {
                stores.append(Store(name: store))
                print(store)
                try UserDefaults.standard.set(object: stores, forKey: "stores")
                navigationController?.popViewController(animated: true)
            } else {
                let alert = UIAlertController(title: "Duplicate Store Names", message: "Duplicate store names, either replace the existing one with the new one, or discard the new one.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Replace", style: UIAlertAction.Style.default, handler: {_ in
                    stores[stores.firstIndex(of: Store(name: store))!] = Store(name: store)
                    self.navigationController?.popViewController(animated: true)
                }))
                alert.addAction(UIAlertAction(title: "Discard", style: .destructive, handler: {_ in
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        } catch {
            print("error getting/retrieving stores")
        }
    }
    @IBAction func addStoreButtonTapped(_ sender: Any) {
        
        let newStoreVC = storyboard?.instantiateViewController(identifier: "StoreAdder") as! StoreNameEnterVC
        newStoreVC.itemDelegate = self
        newStoreVC.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(newStoreVC, animated: true)
    }
    
    @IBAction func addItemsButtonTapped(_ sender: Any) {
        let newItemVC = storyboard?.instantiateViewController(identifier: "AddItemsNew") as! AddItemsVC
        let navController = UINavigationController(rootViewController: newItemVC) // Creating a navigation controller with VC1 at the root of the navigation stack.
        if let title = itemName.title(for: .normal)?.trimmingCharacters(in: .whitespacesAndNewlines) {
            newItemVC.navigationItem.title = title + " List"
        } else {
            newItemVC.navigationItem.title = "Add Items"
        }
        self.present(navController, animated: true, completion: nil)
    }
    
}

extension AddStoreVC: ItemDelegate {
    func addStore(_ store: String) {
        itemName.setTitleColor(UIColor.label, for: .normal)
        itemName.setTitle("   " + store.trimmingCharacters(in: .whitespacesAndNewlines), for: .normal)
        createButton.tintColor = .label
    }
}
