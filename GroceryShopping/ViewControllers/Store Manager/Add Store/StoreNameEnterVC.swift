//
//  StoreNameEnterVC.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 1/29/21.
//

import UIKit

class StoreNameEnterVC: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var itemDelegate: StoreDelegate!
    var totalStores = ["Costco", "Trader Joe's", "Produce", "Target", "Walmart", "Walgreens"]
    var showingStores: [String] = []
    var stores: [Store] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        textField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        textField.becomeFirstResponder()
    }
    
    func loadUserStores() {
        do {
            stores = try UserDefaults.standard.get(objectType: [Store].self, forKey: "stores") ?? []
        } catch {
            print("error getting stores")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadUserStores()
        navigationItem.largeTitleDisplayMode = .never
        for (index, store) in totalStores.enumerated() {
            if stores.containsStore(Store(name: store)) {
                totalStores.remove(at: totalStores.firstIndex(of: store) ?? index)
            }
        }
        totalStores.sort()
    }
    
    @IBAction func textFieldChange(_ sender: Any) {
        //Returning all strings which contain textfield string
        showingStores = totalStores.filter { item in
            return item.lowercased().contains((textField.text?.lowercased()) ?? "placeholder val")
            
        }
        tableView.reloadData()
        
    }
    
    func transferData() {
        guard !stores.containsStore(Store(name: textField.text!)) else {
            Alert.regularAlert(title: "Store already exists!", message: "The store '\(textField.text!)' already exists. Please enter another name", vc: self)
            return
        }
        if textField.text == "" {
            Alert.regularAlert(title: "Text is Empty!", message: "Please put text in the text box", vc: self)
        } else {
            itemDelegate.addStore(textField.text!)
            navigationController?.popViewController(animated: true)
        }
    }
    
    
}

protocol StoreDelegate {
    func addStore(_ store: String)
}

extension StoreNameEnterVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !showingStores.isEmpty {
            return showingStores.count
        }
        return totalStores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if showingStores.isEmpty && textField.text != ""{
            cell.textLabel?.text = ""
        }
        else if showingStores.isEmpty {
            cell.textLabel?.text = totalStores[indexPath.row]
        }
        else {
            cell.textLabel?.text = showingStores[indexPath.row]
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        cell.addGestureRecognizer(tap)
        return cell
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        textField.text = (sender.view as! UITableViewCell).textLabel?.text
        textFieldChange(sender)
    }
    
    
}

extension StoreNameEnterVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        transferData()
        return true
    }
}
