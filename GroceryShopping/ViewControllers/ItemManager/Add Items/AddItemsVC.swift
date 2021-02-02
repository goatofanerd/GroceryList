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
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.rowHeight = 50
        tableView.delegate = self
        tableView.dataSource = self
        addNewItemField.delegate = self
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        loadUserItems()
    }
    
    func loadUserItems() {
        
        do {
            existingItems = try UserDefaults.standard.get(objectType: [Item].self, forKey: "items") ?? [Item(name: "Item1"), Item(name: "Item2"), Item(name: "Item3"), Item(name: "Item4"), Item(name: "Item5"), Item(name: "Item6"), Item(name: "Item7"), Item(name: "Item8"), Item(name: "Item9"), Item(name: "Item10"), Item(name: "Item11"), Item(name: "Item12"), Item(name: "Item13"), Item(name: "Item14"), Item(name: "Item15"), Item(name: "Item16"), Item(name: "Item17"), Item(name: "Item18"), Item(name: "Item19"), Item(name: "Item20"), Item(name: "Item21"), Item(name: "Item22"), Item(name: "Item23"), Item(name: "Item24"), Item(name: "Item25"), Item(name: "Item26"), Item(name: "Item27"), Item(name: "Item28")]
        } catch {
            print("Error getting items")
        }
    }

    @IBAction func closeAndSave(_ sender: Any) {
        save()
        dismiss(animated: true, completion: nil)
    }
    
    func save() {
        
    }
}

extension AddItemsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return existingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ItemsCheckboxCell.reuseIdentifier) as! ItemsCheckboxCell
        cell.checkBox.isUserInteractionEnabled = false
        cell.checkBox.layer.borderWidth = 1
        cell.checkBox.tintColor = .white
        cell.configure(itemName: existingItems[indexPath.row].name)
        
        if !checkedItems.contains(Item(name: existingItems[indexPath.row].name)) {
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
        let cell = tableView.cellForRow(at: indexPath) as! ItemsCheckboxCell
        
        if cell.checkBox.backgroundColor == UIColor(named: "LightBlue") {
            checkedItems.remove(at: checkedItems.firstIndex(of: Item(name: cell.itemName.text!)) ?? 0)
            cell.checkBox.setImage(nil, for: .normal)
            cell.checkBox.backgroundColor = .clear
            cell.checkBox.layer.borderColor = UIColor.gray.cgColor
            cell.itemName.textColor = .gray
        } else {
            checkedItems.append(existingItems[indexPath.row])
            cell.checkBox.setImage(UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(scale: .small))?.withTintColor(.white), for: .normal)
            cell.checkBox.backgroundColor = UIColor(named: "LightBlue")
            cell.checkBox.layer.borderColor = UIColor.blue.cgColor
            cell.itemName.textColor = .label
        }
        tableView.deselectRow(at: indexPath, animated: true)
        print(checkedItems)
    }
    
    
}

extension AddItemsVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        addItemToTableView()
        return true
    }
    
    func addItemToTableView() {
        guard !existingItems.contains(Item(name: addNewItemField.text!)) else {
            Alert.regularAlert(title: "Item Already Exists!", message: "The item " + addNewItemField.text! + " already exists.", vc: self)
            return
        }
        
        guard addNewItemField.text != "" else {
            Alert.regularAlert(title: "Empty Text Field!", message: "Please enter some text.", vc: self)
            return
        }
        existingItems.insert(Item(name: addNewItemField.text!), at: 0)
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .left)
        tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .top)
        tableView.delegate?.tableView?(tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        
        addNewItemField.text = ""
    }
}
