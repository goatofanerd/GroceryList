//
//  AddItemVC.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 1/29/21.
//

import UIKit

class AddItemVC: UIViewController {

    @IBOutlet weak var itemName: UIButton!
    var isPresentingStoreAdder = false
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        itemName.layer.borderWidth = 2
        itemName.layer.borderColor = UIColor.gray.cgColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let store = itemName.title(for: .normal)?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        guard !isPresentingStoreAdder else { return }
        do {
            var stores = try UserDefaults.standard.get(objectType: [Store].self, forKey: "stores") ?? []
            if !stores.contains(Store(name: store)) {
                stores.append(Store(name: store))
                print(store)
                try UserDefaults.standard.set(object: stores, forKey: "stores")
            }
        } catch {
            print("error getting/retrieving stores")
        }
    }
    
    
    @IBAction func addItemButtonTapped(_ sender: Any) {
        
        let newItemVC = storyboard?.instantiateViewController(identifier: "StoreAdder") as! StoreNameEnterVC
        newItemVC.itemDelegate = self
        newItemVC.modalPresentationStyle = .fullScreen
        isPresentingStoreAdder = true
        navigationController?.pushViewController(newItemVC, animated: true)
    }
    
}

extension AddItemVC: ItemDelegate {
    func addStore(_ store: String) {
        itemName.setTitleColor(UIColor.label, for: .normal)
        itemName.setTitle("   " + store.trimmingCharacters(in: .whitespacesAndNewlines), for: .normal)
        isPresentingStoreAdder = false
    }
}
