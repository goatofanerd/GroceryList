//
//  StoreManageVC.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 2/25/21.
//

import UIKit
import GoogleSignIn
import FirebaseDatabase
class StoreManageVC: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var colorChanger: UIBarButtonItem!
    var storeName: String!
    var store: Store!
    var items: [Item] = []
    var existingItems: [Item] = []
    var didDeleteStore = false
    var familyRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setNavBarItems()
        hideKeyboardWhenTappedAround()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 50
        tableView.tableFooterView = UIView()
        tableView.contentInsetAdjustmentBehavior = .never
        
        textField.delegate = self
        
        addObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func addObservers() {
        if userIsLoggedIn(), let id = Family.id {
            familyRef = Database.database().reference().child("families").child(id)
            NotificationCenter.default.addObserver(self, selector: #selector(itemChanged), name: .individualStoreUpdated, object: nil)
        }
    }
    
    @objc func itemChanged() {
        getItems(user: GIDSignIn.sharedInstance()!.currentUser) { (items) in
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            
            Family.getMostRecentChange(familyRef: self.familyRef) { (message, user) in
                guard user != GIDSignIn.sharedInstance()!.currentUser.profile.email else {
                    return
                }
                
                guard message != "" else {
                    return
                }
                
                Family.items = items
                self.loadUserItems()
                self.tableView.reloadData()
                
                self.showAnimationNotification(animationName: "EnvelopeSharing", message: message, duration: 2.5 ,color: .systemBlue, fontColor: .systemBlue)
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getStore()
        didDeleteStore = false
        colorChanger.tintColor = store.color.color
        loadUserItems()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        save()
        
        if userIsLoggedIn() {
            uploadMostRecentChange(message: "\(GIDSignIn.sharedInstance().currentUser.profile.givenName!) made a change to \(store.name)")
            uploadUserStuffToDatabase { (completion) in
                if !completion {
                    self.showErrorNotification(message: "Error uploading information to cloud")
                }
            }
        }
    }
    
    func loadUserItems() {
        do {
            if userIsLoggedIn() {
                existingItems = Family.items
            } else {
                existingItems = try UserDefaults.standard.get(objectType: [Item].self, forKey: "items") ?? []
            }
        } catch {
            showFailureToast(message: "Error getting items")
        }
        
        items.removeAll()
        for item in existingItems {
            if item.stores.containsStore(Store(name: storeName)) {
                items.append(item)
            }
        }
    }
    
    func save() {
        do {
            //Save color
            var stores = try UserDefaults.standard.get(objectType: [Store].self, forKey: "stores")
            
            if !didDeleteStore {
                if let existingStore = stores?.firstStore(name: storeName) {
                    stores![existingStore].color = Color(color: colorChanger.tintColor!)
                }
            }
            
            //Save Items
            try UserDefaults.standard.set(object: existingItems, forKey: "items")
            
            try UserDefaults.standard.set(object: stores, forKey: "stores")
            
            Family.items = existingItems
            Family.stores = stores!
        } catch {
            print("error saving")
        }
    }
    
}

extension StoreManageVC: UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldItemManagerCell.identifier) as! TextFieldItemManagerCell
        
        if indexPath.row != items.count {
            cell.configure(withText: items[indexPath.row].name, delegate: self, tag: indexPath.row)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let action = UIContextualAction(style: .destructive, title: "") { [self] (action, view, completion) in
            let deletedItemName = items[indexPath.row].name
            if let index = existingItems.firstIndex(of: items[indexPath.row]) {
                existingItems[index].removeStore(withName: storeName)
            }
            
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .middle)
            showToast(message: "Deleted item.", image: UIImage(systemName: "trash")!, color: .red, fontColor: .red)
            
            Family.items = existingItems
            if userIsLoggedIn() {
                uploadUserStuffToDatabase { (completed) in
                    print("uploaded")
                    uploadMostRecentChange(message: GIDSignIn.sharedInstance().currentUser.profile.givenName! + " deleted the item '" + deletedItemName! + "'")
                }
            } else {
                print("user not logged in")
            }
            completion(true)
            
        }
        action.image = UIImage(systemName: "trash")
        
        return action
    }
    
    
    
    //Text Field Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard textField.text != "" else {
            showFailureToast(message: "No Item Entered!")
            textField.text = ""
            return true
        }
        
        guard !items.containsItem(Item(name: textField.text!)) else {
            showFailureToast(message: "Item already exists!")
            textField.text = ""
            return true
        }
        
        if textField.tag == -1 {
            //New Item
            var added = false
            for (index, var item) in existingItems.enumerated() {
                
                if item.name == textField.text! {
                    item.addStore(storeName)
                    added = true
                    existingItems[index] = item
                    items.append(item)
                }
                
            }
            
            if !added {
                let newItem = Item(name: textField.text!, stores: [Store(name: storeName)])
                items.append(newItem)
                existingItems.append(newItem)
            }
            
            tableView.insertRows(at: [IndexPath(row: items.count - 1, section: 0)], with: .left)
            textField.text = ""
            
            Family.items = existingItems
            if userIsLoggedIn() {
                uploadUserStuffToDatabase { [self] (completed) in
                    print("uploaded")
                    uploadMostRecentChange(message: GIDSignIn.sharedInstance().currentUser.profile.givenName! + " added the item '" + items.last!.name + "' to the list")
                }
            } else {
                print("user not logged in")
            }
            
        }
        else {
            //Existing Item
            let index = textField.tag
            let oldItem = items[index]
            items[index].name = textField.text!
            
            existingItems[existingItems.indexOfItem(oldItem)!].name = textField.text!
            
            Family.items = existingItems
            if userIsLoggedIn() {
                uploadUserStuffToDatabase { [self] (completed) in
                    print("uploaded")
                    uploadMostRecentChange(message: GIDSignIn.sharedInstance().currentUser.profile.givenName! + " changed the name of '\(oldItem.name!)' into '\(items[index].name!)'")
                }
            } else {
                print("user not logged in")
            }
        }
        view.endEditing(true)
        
        return true
    }
    
    
}
//MARK: -Initial Setup
extension StoreManageVC {
    func setNavBarItems() {
        self.navigationItem.title = storeName
        
        //X Button
        let xButton = UIBarButtonItem(image: UIImage(systemName: "multiply"), style: .plain, target: self, action: #selector(dismissScreen))
        xButton.tintColor = .label
        self.navigationItem.leftBarButtonItem = xButton
        
        //Color Changer
        colorChanger = UIBarButtonItem(image: UIImage(systemName: "circle.fill"), style: .plain, target: self, action: #selector(launchPickerView))
        
        //Trash Button
        let trashButton = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: #selector(deleteStore))
        trashButton.tintColor = .systemRed
        
        self.navigationItem.rightBarButtonItems = [trashButton, colorChanger]
        
        
    }
    
    @objc func dismissScreen() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func deleteStore() {
        let alert = UIAlertController(title: "Are you sure you want to delete?", message: "This action is irreversible!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [self]_ in
            
            didDeleteStore = true
            if userIsLoggedIn() {
                do {
                    var tempItems: [Item] = []
                    let items = Family.items
                    for var item in items {
                        if item.stores.containsStore(Store(name: storeName)) {
                            try item.stores.removeStore(withStore: storeName)
                        }
                        tempItems.append(item)
                    }
                    
                    Family.items = tempItems
                    
                    var stores = Family.stores
                    try stores.removeStore(withStore: storeName)
                    Family.stores = stores
                    
                    try UserDefaults.standard.set(object: tempItems, forKey: "items")
                    try UserDefaults.standard.set(object: stores, forKey: "stores")
                    
                    self.showSuccessToast(message: "Successfully deleted!")
                    self.navigationController?.popViewController(animated: true)
                } catch {
                    self.showFailureToast(message: "Error deleting!")
                }
            }
            else {
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
                    self.showSuccessToast(message: "Successfully deleted!")
                    self.navigationController?.popViewController(animated: true)
                } catch {
                    self.showFailureToast(message: "Error deleting!")
                }
            }
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func getStore() {
        do {
            let stores = try UserDefaults.standard.get(objectType: [Store].self, forKey: "stores")!
            store = stores[stores.firstStore(name: storeName)!]
        } catch {
            showFailureToast(message: "Error getting store.")
        }
    }
}

extension StoreManageVC: UIColorPickerViewControllerDelegate {
    @objc func launchPickerView() {
        let colorPicker = UIColorPickerViewController()
        colorPicker.selectedColor = colorChanger.tintColor ?? .blue
        colorPicker.delegate = self
        present(colorPicker, animated: true, completion: nil)
    }
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        colorChanger.tintColor = viewController.selectedColor
    }
}
