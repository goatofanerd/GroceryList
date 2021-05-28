//
//  BoughtItemsVC.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 2/19/21.
//

import UIKit

class BoughtItemsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var boughtItems: [Item] = []
    var removedItems: [Item] = []
    var storeVC: StoreVC!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavBarButtons()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
    }
    
    func setBoughtItems(_ items: [Item]) {
        self.boughtItems = items
    }
    
    func setStoreVC(_ vc: StoreVC) {
        self.storeVC = vc
    }
    
    private func setNavBarButtons() {
        self.navigationItem.title = "Bought Items"
        
        //X Button
        let xButton = UIBarButtonItem(image: UIImage(systemName: "multiply"), style: .plain, target: self, action: #selector(dismissScreen))
        xButton.tintColor = .label
        self.navigationItem.leftBarButtonItem = xButton
        
        //Checkout Button
        let checkoutButton = UIBarButtonItem(title: "Checkout", style: .done, target: self, action: #selector(checkout))
        checkoutButton.tintColor = .label
        self.navigationItem.rightBarButtonItem = checkoutButton
    }
    
    @objc private func dismissScreen() {
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func checkout() {
        
        let alert = UIAlertController(title: "Are you sure you want to check out?", message: "Checking out will mark these items as bought.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { [self] action in
            
            for item in boughtItems {
                storeVC.addBackItem(item, checkedOut: true)
                removedItems.append(item)
            }
            
            dismissScreen()
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }

}

extension BoughtItemsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return boughtItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        cell.textLabel?.text = "    " + boughtItems[indexPath.row].name
        cell.textLabel?.textColor = .systemGreen
        cell.textLabel?.font = UIFont(name: "Sinhala Sangam MN", size: 21)
        
        //Separator Full Line
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        storeVC.addBackItem(boughtItems[indexPath.row], checkedOut: false)
        removedItems.append(boughtItems[indexPath.row])
        boughtItems.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .left)
        showSuccessToast(message: "Added back item")
    }
    
    
}
