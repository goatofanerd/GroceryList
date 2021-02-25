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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavBarButtons()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
    }
    
    func setBoughtItems(_ boughtItems: [Item]) {
        self.boughtItems = boughtItems
    }
    
    private func setNavBarButtons() {
        self.navigationItem.title = "Bought Items"
        
        //X Button
        let xButton = UIBarButtonItem(image: UIImage(systemName: "multiply"), style: .plain, target: self, action: #selector(dismissScreen))
        xButton.tintColor = .label
        self.navigationItem.leftBarButtonItem = xButton
    }
    
    @objc private func dismissScreen() {
        let storeVC = navigationController?.viewControllers[1] as! StoreVC
        storeVC.addBackItems(removedItems)
        navigationController?.popViewController(animated: true)
        
        if removedItems.count == 1 {
            storeVC.showSuccessToast(message: "Added back \(removedItems.count) item.")
        } else {
            storeVC.showSuccessToast(message: "Added back \(removedItems.count) items.")
        }
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
        cell.textLabel?.font = UIFont(name: "DIN Alternate Bold", size: 18)
        
        //Separator Full Line
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        removedItems.append(boughtItems[indexPath.row])
        boughtItems.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .left)
        showAnimationToast(animationName: "TrashOpening", message: "Brought Back Item.")
    }
    
    
}
