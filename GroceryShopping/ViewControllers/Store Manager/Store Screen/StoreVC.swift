//
//  StoreVC.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 2/4/21.
//

import UIKit
import ViewAnimator
import GoogleSignIn
import FirebaseDatabase
class StoreVC: UIViewController {
    
    let cartBarButton = BadgedButtonItem(with: UIImage(systemName: "cart.fill"))
    @IBOutlet weak var addNewItemField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var existingItems: [Item] = []
    var items: [Item] = []
    var notNeeded: [Item] = []
    var boughtItems: [Item] = []
    var filteredItems: [Item] = []
    var storeName: String!
    var state = FilteredState.all
    var familyRef: DatabaseReference!
    var currentUserName: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.hideKeyboardWhenTappedAround()
        tableView.rowHeight = 60
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.contentInsetAdjustmentBehavior = .never
        navigationItem.largeTitleDisplayMode = .always
        
        addNewItemField.delegate = self
        storeName = self.navigationItem.title!
        
        let tapNavBar = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        navigationController?.navigationBar.addGestureRecognizer(tapNavBar)
        
        cartBarButton.badgeAnimation = true
        cartBarButton.badgeTintColor = .systemBlue
        cartBarButton.badgeTextColor = .white
        cartBarButton.position = .right
        cartBarButton.hasBorder = true
        cartBarButton.borderColor = .black
        cartBarButton.tapAction = {
            self.launchBoughtItems()
        }
        self.navigationItem.rightBarButtonItems?.append(cartBarButton)
        
        //handle notifications
        addObservers()
    }
    
    @objc func launchBoughtItems() {
        let boughtItemsVC = storyboard!.instantiateViewController(identifier: "BoughtItemsScreen") as! BoughtItemsVC
        boughtItemsVC.setStoreVC(self)
        boughtItemsVC.setBoughtItems(boughtItems)
        navigationController?.pushViewController(boughtItemsVC, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadUserItems()
        tableView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.isHidden = false
        let animation = AnimationType.from(direction: .top, offset: 300)
        UIView.animate(views: tableView.visibleCells, animations: [animation])
        
        if userIsLoggedIn() {
            currentUserName = GIDSignIn.sharedInstance()?.currentUser.profile.givenName
        }
    }
    
    func loadUserItems() {
        items = []
        do {
            if userIsLoggedIn() {
                existingItems = Family.items
                boughtItems = Family.boughtItems
            } else {
                existingItems = try UserDefaults.standard.get(objectType: [Item].self, forKey: "items") ?? []
            }
        } catch {
            showFailureToast(message: "Error getting items")
        }
        
        for item in existingItems {
            if item.stores.containsStore(Store(name: storeName)) {
                items.append(item)
            }
        }
        
        cartBarButton.setBadge(with: boughtItems.count)
    }
    
    
    @IBAction func backToHomeScreen(_ sender: Any) {

        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func filterButtonTapped(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Filter Items", message: nil, preferredStyle: .actionSheet)
        
        if state == .all {
            actionSheet.addAction(UIAlertAction(title: "Show Only Uncompleted", style: .default, handler: {[self]_ in
                state = .notCompleted
                
                filteredItems.removeAll()
                for item in items {
                    if isNeeded(item: item) {
                        filteredItems.append(item)
                    }
                }
                
                tableView.reloadData()
                
            }))
        } else {
            actionSheet.addAction(UIAlertAction(title: "Show All", style: .default, handler: { [self]_ in
                filteredItems.removeAll()
                state = .all
                tableView.reloadData()
            }))
        }
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        save()
        NotificationCenter.default.removeObserver(self)
        if userIsLoggedIn() {
            Family.items = existingItems
//            uploadUserStuffToDatabase { (completion) in
//                if !completion {
//                    self.showErrorNotification(message: "Error uploading information to cloud")
//                }
//            }
        }
    }
    
    func save() {
        do {
            try UserDefaults.standard.set(object: existingItems, forKey: "items")
        } catch {
            showFailureToast(message: "Error saving items!")
        }
    }
    
    func isNeeded(item: Item) -> Bool {
        return item.neededStores.containsStore(Store(name: storeName))
    }
    
    func addBackItem(_ addedItem: Item, checkedOut: Bool) {
        var item = addedItem
        do {
            try boughtItems.removeItem(withItem: item.name)
            
            item.addStore(storeName)
            item.removeFromStore(nil)
            if checkedOut {
                item.changeBoughtTime()
            } else {
                item.removeBoughtTime()
            }
            
            if addedItem.storeRemovedFrom?.name == storeName {
                items.append(item)
            }
            
            if let index = existingItems.indexOfItem(addedItem) {
                existingItems[index] = item
            }
            
            
            
            Family.items = existingItems
            Family.boughtItems = boughtItems
            
            if !checkedOut {
                if userIsLoggedIn() {
                    uploadUserStuffToDatabase { [self] (completed) in
                        print("uploaded")
                        uploadMostRecentChange(message: currentUserName + " brought back the item \(addedItem.name ?? "(error)") from the cart!")
                    }
                } else {
                    print("user not logged in")
                }
            }
            
            
            
        } catch {
            showFailureToast(message: "Error Bringing Back Item!")
        }
        
        tableView.reloadData()
        cartBarButton.setBadge(with: boughtItems.count)
        
        if checkedOut {
            if userIsLoggedIn() {
                uploadUserStuffToDatabase { [self] (completed) in
                    print("uploaded")
                    uploadMostRecentChange(message: currentUserName + " checked out the cart. All items are back in the list and marked as previously bought.")
                }
            } else {
                print("user not logged in")
            }
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: -Cloud has changed
extension StoreVC {
    
    func addObservers() {
        if userIsLoggedIn(), let id = Family.id {
            familyRef = Database.database().reference().child("families").child(id)
            NotificationCenter.default.addObserver(self, selector: #selector(itemChanged), name: .individualStoreUpdated, object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(boughtItemsChanged), name: .itemAddedToCart, object: nil)
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
    
    @objc func boughtItemsChanged() {
        getBoughtItems(user: GIDSignIn.sharedInstance()!.currentUser) { (boughtItems) in
            
            Family.getMostRecentChange(familyRef: self.familyRef) { (message, user) in
                guard user != GIDSignIn.sharedInstance()!.currentUser.profile.email else {
                    return
                }
                
                self.boughtItems = boughtItems
                Family.boughtItems = boughtItems
                self.cartBarButton.setBadge(with: boughtItems.count)
                
            }
        }
    }
}
extension StoreVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if state != .all {
            return filteredItems.count
        }
        
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ItemCell.identifier) as! ItemCell
        
        if filteredItems.isEmpty {
            cell.itemName.text = items[indexPath.row].name
            if let date = items[indexPath.row].lastBought {
                cell.lastBought.text = "\(date.month!)/\(date.day!)"
            } else {
                cell.lastBought.text = ""
            }
            
            if isNeeded(item: items[indexPath.row]) {
                cell.itemName.textColor = .label
            } else {
                cell.itemName.textColor = .gray
            }
        } else {
            cell.itemName.text = filteredItems[indexPath.row].name
            if let date = filteredItems[indexPath.row].lastBought {
                cell.lastBought.text = "\(date.month!)/\(date.day!)"
            } else {
                cell.lastBought.text = ""
            }
            
            if isNeeded(item: filteredItems[indexPath.row]) {
                cell.itemName.textColor = .label
            } else {
                cell.itemName.textColor = .gray
            }
            cell.itemName.textColor = .label
            
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
        let notNeeded = notNeededAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [notNeeded, delete])
    }
    
    func boughtAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let action = UIContextualAction(style: .destructive, title: "Bought") { [self] (action, view, completion) in
            
            var showingItems: [Item] = []
            if state == .all {
                showingItems = items
            } else {
                showingItems = filteredItems
            }
            
            if let index = existingItems.firstIndex(of: showingItems[indexPath.row]) {
                //existingItems[index].changeBoughtTime()
                existingItems[index].removeStore(withName: storeName)
                existingItems[index].removeFromStore(storeName)
            }
            
            boughtItems.append(showingItems[indexPath.row])
            boughtItems[boughtItems.count - 1].removeFromStore(storeName)
            cartBarButton.setBadge(with: boughtItems.count)
            if state == .all {
                print("all")
                items.remove(at: indexPath.row)
            } else {
                print("select")
                do {
                    try items.removeItem(withItem: filteredItems[indexPath.row].name)
                } catch {}
                filteredItems.remove(at: indexPath.row)
            }

            tableView.deleteRows(at: [indexPath], with: .middle)
            showSuccessToast(message: "Marked item as bought.")
            
            Family.items = existingItems
            Family.boughtItems = boughtItems
            if userIsLoggedIn() {
                uploadUserStuffToDatabase { (completed) in
                    print("uploaded")
                    uploadMostRecentChange(message: currentUserName + " marked the item \(showingItems[indexPath.row].name ?? "(error)") as bought!")
                }
            } else {
                print("user not logged in")
            }
            
            completion(true)
            
        }
        action.backgroundColor = .systemGreen
        
        return action
    }
    
    func notNeededAction(at indexPath: IndexPath) -> UIContextualAction {
        var title: String
        var backgroundColor = UIColor()
        
        var showingItems: [Item] = []
        if state == .all {
            showingItems = items
        } else {
            showingItems = filteredItems
        }
        if showingItems[indexPath.row].neededStores.containsStore(Store(name: self.storeName)) {
            title = "Not Needed"
            backgroundColor = .systemOrange
        } else {
            title = "Bring Back"
            backgroundColor = .systemBlue
        }
        
        let action = UIContextualAction(style: .destructive, title: title) { [self] (action, view, completion) in
            
            var nameOfItem = ""
            if state == .all {
                if let index = existingItems.firstIndex(of: items[indexPath.row]) {
                    nameOfItem = existingItems[index].name
                    existingItems[index].markStoreAsOpposite(store: Store(name: storeName))
                }
                items[indexPath.row].markStoreAsOpposite(store: Store(name: storeName))
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            else {
                if let index = existingItems.firstIndex(of: filteredItems[indexPath.row]) {
                    existingItems[index].markStoreAsOpposite(store: Store(name: storeName))
                }
                items[items.firstIndex(of: filteredItems[indexPath.row])!].markStoreAsOpposite(store: Store(name: storeName))
                filteredItems.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
            }
            
            Family.items = existingItems
            if userIsLoggedIn() {
                uploadUserStuffToDatabase { (completed) in
                    print("uploaded")
                    uploadMostRecentChange(message: currentUserName + " marked the item '\(nameOfItem)' as Not Needed!")
                }
            } else {
                print("not logged in")
            }
            completion(true)
            
        }
        
        action.backgroundColor = backgroundColor
        return action
    }
      
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let action = UIContextualAction(style: .destructive, title: "") { [self] (action, view, completion) in
            var deletedItemName = ""
            
            if let index = existingItems.firstIndex(of: items[indexPath.row]) {
                deletedItemName = existingItems[index].name
                existingItems[index].removeStore(withName: storeName)
            }
            
            do {
                if state == .all {
                    try items.removeItem(withItem: (tableView.cellForRow(at: indexPath) as! ItemCell).itemName.text!)
                } else {
                    try items.removeItem(withItem: filteredItems[indexPath.row].name)
                    filteredItems.remove(at: indexPath.row)
                }
            } catch {
                showFailureToast(message: "Error Deleting")
            }
            
            tableView.deleteRows(at: [indexPath], with: .middle)
            showToast(message: "Deleted item.", image: UIImage(systemName: "trash")!, color: .red, fontColor: .red)
            
            Family.items = existingItems
            if userIsLoggedIn() {
                uploadUserStuffToDatabase { (completed) in
                    print("uploaded")
                    uploadMostRecentChange(message: currentUserName + " deleted the item '" + deletedItemName + "'")
                }
            } else {
                print("user not logged in")
            }
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
        guard addNewItemField.text != "" else {
            showFailureToast(message: "No Item Entered!")
            return
        }
        
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
                
                if state != .all {
                    filteredItems.append(item)
                }
            }
            
        }
        
        if !added {
            let newItem = Item(name: addNewItemField.text!, stores: [Store(name: storeName)])
            items.append(newItem)
            existingItems.append(newItem)
            
            if state != .all {
                filteredItems.append(newItem)
            }
        }
        
        Family.items = existingItems
        if userIsLoggedIn() {
            uploadUserStuffToDatabase { [self] (completed) in
                print("uploaded")
                uploadMostRecentChange(message: currentUserName + " added the item '\(addNewItemField.text!)' to the list!")
            }
        } else {
            print("not logged in")
        }
        
        if state == .all {
            tableView.insertRows(at: [IndexPath(row: items.count - 1, section: 0)], with: .left)
            tableView.scrollToRow(at: IndexPath(row: items.count - 1, section: 0), at: .bottom, animated: true)
        } else {
            tableView.insertRows(at: [IndexPath(row: filteredItems.count - 1, section: 0)], with: .left)
            tableView.scrollToRow(at: IndexPath(row: filteredItems.count - 1, section: 0), at: .bottom, animated: true)
        }
    }
    
    enum FilteredState: String {
        case all = "Show All"
        case notCompleted = "Show Completed"
        case completed = "Show Uncompleted"
    }
}



//MARK: -Delete Store
/*
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
 */
