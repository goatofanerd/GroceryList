//
//  AddItemScreenVC.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 1/22/21.
//

import UIKit

class AddItemScreenVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var itemName: UIButton!
    var stores: [Store]!
    var selectedStores: [String] = []
    var selectedStoreCells: [ChooseStoreCell] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
    }
    
    @IBAction func submit(_ sender: Any) {
        var nameOfItem = itemName.title(for: .normal)!
        nameOfItem = nameOfItem.trimmingCharacters(in: .whitespacesAndNewlines)
        guard nameOfItem != "" && nameOfItem != "Enter name of item..." else {
            Alert.regularAlert(title: "No Item Entered!", message: "Please enter the name of the item", vc: self)
            return
        }
        
        guard !selectedStores.isEmpty else {
            Alert.regularAlert(title: "No Stores Selected", message: "Please select at least one store", vc: self)
            return
        }
        
        //Updating stores
        for (indexOfStore, store) in stores.enumerated() {
            
            if selectedStores.contains(store.name) {
                stores[indexOfStore].addItem(item: nameOfItem, priority: selectedStores.firstIndex(of: store.name)! + 1)
            } else {
                stores[indexOfStore].removeItem(nameOfItem)
            }
            updateUserDefaults(stores: stores)
        }
        
        do {
            try print(UserDefaults.standard.get(objectType: [Store].self, forKey: "stores") as Any)
        } catch {
            print("cant get stores")
        }
        
        //dismiss(animated: true, completion: nil)
    }
    
    func updateUserDefaults(stores: [Store]) {
        do {
            try UserDefaults.standard.set(object: stores, forKey: "stores")
        } catch {
            print("error updating stores")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        do {
            stores = try UserDefaults.standard.get(objectType: [Store].self, forKey: "stores")
        } catch {
            print("error getting stores")
        }
        
    }

    
    @IBAction func addItemButtonTapped(_ sender: Any) {
        
        let newItemVC = storyboard?.instantiateViewController(identifier: "newItem") as! NewItemVC
        newItemVC.itemDelegate = self
        newItemVC.modalPresentationStyle = .fullScreen
        present(newItemVC, animated: true, completion: nil)
    }
}

extension AddItemScreenVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let stores = stores {
            return stores.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ChooseStoreCell
        cell.storeLabel.text = stores?[indexPath.row].name
        cell.checkButton.addTarget(self, action: #selector(AddItemScreenVC.addStoreClicked(_:)), for: .touchUpInside)
        return cell
    }
    
    @objc func addStoreClicked(_ sender: UIButton!) {
        //check if button is selected or not
        let store = (sender.superview?.superview as! ChooseStoreCell).storeLabel.text!
        
        if selectedStores.contains(store) {
            //Unselect
            let indexOf = selectedStores.firstIndex(of: store)!
            sender.backgroundColor = UIColor(named: "unselectedGrayColor")
            sender.setTitle("", for: .normal)
            selectedStores.remove(at: indexOf)
            selectedStoreCells.remove(at: indexOf)
            //Update other buttons to match array
            updateButtons(from: indexOf)
        }
        else {
            sender.backgroundColor = UIColor(named: "selectedBlueColor")
            sender.setTitle("\(selectedStores.count + 1)", for: .normal)
            selectedStores.append(store)
            selectedStoreCells.append(sender.superview?.superview as! ChooseStoreCell)
        }
    }
    
    func updateButtons(from index: Int) {
        let allCells = Array(selectedStoreCells[index...])
        var indexOf = index
        for cell in allCells {
            cell.checkButton.setTitle("\(indexOf + 1)", for: .normal)
            indexOf += 1
        }
        
    }
    
    
    
    
}
extension AddItemScreenVC: ItemDelegate {
    func addItem(_ item: String) {
        itemName.setTitleColor(UIColor.label, for: .normal)
        itemName.setTitle("   " + item.trimmingCharacters(in: .whitespacesAndNewlines), for: .normal)
    }
}
