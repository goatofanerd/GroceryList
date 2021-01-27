//
//  NewItemVC.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 1/22/21.
//

import UIKit

class NewItemVC: UIViewController{

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var itemDelegate: ItemDelegate!
    var totalItems = ["apples", "zucchinis", "eggs", "bananas", "peaches", "chips", "candy canes", "pears", "croissants", "tomatoes", "coffee", "tea", "bread", "chicken", "turkey", "beef", "pork", "soup", "bacon", "cranberries", "blueberries", "strawberries", "cheese", "cereal", "onions", "potatoes", "yogurt", "avocado", "mushrooms", "broccoli", "peanuts", "butter", "peanut butter", "spinach", "garlic", "orange juice", "apple juice", "grapes", "oranges", "cuties"]
    var showingItems: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        textField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        textField.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.largeTitleDisplayMode = .never
        totalItems.sort()
    }
    
    @IBAction func textFieldChange(_ sender: Any) {
        //Returning all strings which contain textfield string
        showingItems = totalItems.filter { item in
            return item.lowercased().contains((textField.text?.lowercased()) ?? "placeholder val")
        }
        tableView.reloadData()
        
    }
    
    func transferData() {
        if textField.text == "" {
            Alert.regularAlert(title: "Text is Empty!", message: "Please put text in the text box", vc: self)
        } else {
            itemDelegate.addItem(textField.text!)
            dismiss(animated: true, completion: nil)
        }
    }
    
    
}

protocol ItemDelegate {
    func addItem(_ item: String)
}

extension NewItemVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !showingItems.isEmpty {
            return showingItems.count
        }
        return totalItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if showingItems.isEmpty && textField.text != ""{
            cell.textLabel?.text = ""
        }
        else if showingItems.isEmpty {
            cell.textLabel?.text = totalItems[indexPath.row]
        }
        else {
            cell.textLabel?.text = showingItems[indexPath.row]
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

extension NewItemVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        transferData()
        return true
    }
}
