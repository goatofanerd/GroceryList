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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavBarButtons()
        
        tableView.dataSource = self
        tableView.delegate = self
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
        navigationController?.popViewController(animated: true)
    }

}

extension BoughtItemsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return boughtItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = boughtItems[indexPath.row].name
        cell.textLabel?.textColor = .systemGreen
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        boughtItems.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .left)
        showAnimationToast(animationName: "TrashOpening", message: "Brought Back Item.")
    }
    
    
}
