//
//  ItemManagerVC.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 2/16/21.
//

import UIKit
import ViewAnimator

class ItemManagerVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var stores: [Store] = []
    var reorderTableView: LongPressReorderTableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 50
        tableView.tableFooterView = UIView()
        
        reorderTableView = LongPressReorderTableView(tableView)
        reorderTableView.enableLongPressReorder()
        reorderTableView.delegate = self
        
    }
    
    override func positionChanged(currentIndex: IndexPath, newIndex: IndexPath) {
        stores.swapAt(currentIndex.row, newIndex.row)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.isHidden = true
        loadUserStores()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.isHidden = false
        let animationLeft = AnimationType.from(direction: .left, offset: 300)
        UIView.animate(views: tableView.visibleCells, animations: [animationLeft])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        do {
            try UserDefaults.standard.set(object: stores, forKey: "stores")
            (tabBarController?.viewControllers?[0] as? ShoppingVC)?.storeCollectionView.reloadData()
        } catch {
            navigationController?.viewControllers[0].showFailureToast(message: "Error Saving Stores")
        }
    }
    
    func loadUserStores() {
        do {
            stores = try UserDefaults.standard.get(objectType: [Store].self, forKey: "stores")!
        } catch {
            showFailureToast(message: "No stores found.")
        }
        
        tableView.reloadData()
    }

}

extension ItemManagerVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        stores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        //TODO: have store color
        cell.backgroundColor = stores[indexPath.row].color.color
        cell.textLabel?.text = stores[indexPath.row].name
        cell.textLabel?.textColor = .white
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.gray.cgColor
        cell.layer.cornerRadius = 10
        cell.contentView.frame = cell.contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
