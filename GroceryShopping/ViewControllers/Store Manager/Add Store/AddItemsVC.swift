//
//  AddItemsVC.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 1/30/21.
//

import UIKit

class AddItemsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var addNewItemField: UITextField!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    
    var existingItems: [Item] = []
    var checkedItems: [Item] = []
    var filteredItems: [Item] = []
    var reorderTable: LongPressReorderTableView!
    
    var storeName: String!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.rowHeight = 50
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        addNewItemField.delegate = self
        searchBar.delegate = self
        reorderTable = LongPressReorderTableView(tableView)
        reorderTable.enableLongPressReorder()
        reorderTable.delegate = self
        
        self.hideKeyboardWhenTappedAround()
    
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var indexPaths: [IndexPath] = []
        for (index, item) in filteredItems.enumerated() {
            if item.stores.containsStore(Store(name: storeName)) {
                checkedItems.append(item)
                indexPaths.append(IndexPath(row: index, section: 0))
            }
        }

        for indexPath in indexPaths {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
        
        if let last = indexPaths.last {
            tableView.deselectRow(at: last, animated: true)
        }
    }
    
    override func positionChanged(currentIndex: IndexPath, newIndex: IndexPath) {
        if checkedItems.contains(existingItems[currentIndex.row]) && checkedItems.contains(existingItems[newIndex.row]) {
            print("contains")
            checkedItems.swapAt(checkedItems.firstIndex(of: existingItems[currentIndex.row])!, checkedItems.firstIndex(of: existingItems[newIndex.row])!)
        }
        existingItems.swapAt(currentIndex.row, newIndex.row)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserItems()
    }
    
    func loadUserItems() {
        
        do {
            existingItems = try UserDefaults.standard.get(objectType: [Item].self, forKey: "items") ?? [/*Item(name: "Item1"), Item(name: "Item2"), Item(name: "Item3"), Item(name: "Item4"), Item(name: "Item5"), Item(name: "Item6"), Item(name: "Item7"), Item(name: "Item8"), Item(name: "Item9"), Item(name: "Item10"), Item(name: "Item11"), Item(name: "Item12"), Item(name: "Item13"), Item(name: "Item14"), Item(name: "Item15"), Item(name: "Item16"), Item(name: "Item17"), Item(name: "Item18"), Item(name: "Item19"), Item(name: "Item20"), Item(name: "Item21"), Item(name: "Item22"), Item(name: "Item23"), Item(name: "Item24"), Item(name: "Item25"), Item(name: "Item26"), Item(name: "Item27"), Item(name: "Item28")*/]
            
        } catch {
            print("Error getting items")
        }
        
        filteredItems = existingItems
    }

    @IBAction func closeAndSave(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        save()
    }
    
    func save() {
        storeName = storeName!
        
        for (index, var item) in existingItems.enumerated() {
            if checkedItems.containsItem(item) {
                item.addStore(storeName)
                existingItems[index] = Item(name: item.name, stores: item.stores)
            } else {
                if item.stores.containsStore(Store(name: storeName)) {
                    item.stores.remove(at: item.stores.firstIndex(of: Store(name: storeName))!)
                    existingItems[index] = Item(name: item.name, stores: item.stores)
                }
            }
        }
        
        do {
            try UserDefaults.standard.set(object: existingItems, forKey: "items")
        } catch {
            print("error setting items")
        }
        
    }
}


extension AddItemsVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredItems = []
        for (index, item) in existingItems.enumerated(){
            
            if item.name.lowercased().starts(with: searchText.lowercased()) {
                filteredItems.append(existingItems[index])
            }
            
        }
        self.viewDidLayoutSubviews()
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}

extension AddItemsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredItems.count
    }
    
    // this method handles row deletion
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            // remove the item from the data model
            if(checkedItems.contains(filteredItems[indexPath.row])) {
                do {
                    try checkedItems.removeItem(withItem: filteredItems[indexPath.row].name)
                } catch {
                    print("error deleting")
                }
            }
            filteredItems.remove(at: indexPath.row)
            existingItems.remove(at: indexPath.row)
            // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .left)
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ItemsCheckboxCell.reuseIdentifier) as! ItemsCheckboxCell
        cell.checkBox.isUserInteractionEnabled = false
        cell.checkBox.layer.borderWidth = 1
        cell.checkBox.tintColor = .label
        cell.configure(itemName: filteredItems[indexPath.row].name ?? "error")
        
        if !checkedItems.contains(filteredItems[indexPath.row]) {
            cell.checkBox.layer.borderColor = UIColor.gray.cgColor
            cell.checkBox.layer.backgroundColor = UIColor.clear.cgColor
            cell.checkBox.setImage(nil, for: .normal)
            cell.itemName.textColor = .gray
        } else {
            cell.checkBox.setImage(UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(scale: .small))?.withTintColor(.white), for: .normal)
            cell.checkBox.backgroundColor = UIColor(named: "LightBlue")
            cell.checkBox.layer.borderColor = UIColor.blue.cgColor
            cell.itemName.textColor = .label
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        markRowAsSelected(indexPath: indexPath)
    }
    
    func markRowAsSelected(indexPath: IndexPath) {
    
        guard let cell = tableView.cellForRow(at: indexPath) as? ItemsCheckboxCell else { print("unable to mark row");
            return
        }
        
        if cell.checkBox.backgroundColor == UIColor(named: "LightBlue") {
            do {
                try checkedItems.removeItem(withItem: cell.itemName!.text!)
            } catch {
                print("error unchecking")
            }
            cell.checkBox.setImage(nil, for: .normal)
            cell.checkBox.backgroundColor = .clear
            cell.checkBox.layer.borderColor = UIColor.gray.cgColor
            cell.itemName.textColor = .gray
        } else {
            checkedItems.append(filteredItems[indexPath.row])
            cell.checkBox.setImage(UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(scale: .small))?.withTintColor(.white), for: .normal)
            cell.checkBox.backgroundColor = UIColor(named: "LightBlue")
            cell.checkBox.layer.borderColor = UIColor.blue.cgColor
            cell.itemName.textColor = .label
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}

extension AddItemsVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addItemToTableView()
        return true
    }
    
    func addItemToTableView() {
        guard !existingItems.containsItem(Item(name: addNewItemField.text!)) else {
            addNewItemField.resignFirstResponder()
            showFailureToast(message: "The item " + addNewItemField.text! + " already exists!")
            return
        }
        
        guard addNewItemField.text != "" else {
            addNewItemField.resignFirstResponder()
            showFailureToast(message: "Empty text field!")
            return
        }
        existingItems.insert(Item(name: addNewItemField.text!), at: 0)
        filteredItems.insert(Item(name: addNewItemField.text!), at: 0)
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .left)
        tableView.setContentOffset(.zero, animated: false)
        searchBar.delegate?.searchBar?(searchBar, textDidChange: searchBar.text!)
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        tableView.delegate?.tableView?(tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        
        addNewItemField.text = ""
        
        //save()
        //loadUserItems()
        //tableView.reloadData()
    }
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}