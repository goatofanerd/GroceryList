//
//  ItemManagerVC.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 2/16/21.
//

import UIKit

class ItemManagerVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var stores: [Store] = []
    let storeColors = [UIColor(named: "Blue")!, UIColor(named: "Green")!, UIColor(named: "Purple")!, UIColor(named: "Red")!, UIColor(named: "Orange")!, UIColor(named: "Lime")!, UIColor(named: "LightBlue")!, UIColor(named: "Pink")!]
    var reorderTableView: LongPressReorderTableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 50
        tableView.tableFooterView = UIView()
        
        reorderTableView = LongPressReorderTableView(tableView)
        //reorderTableView.enableLongPressReorder()
        reorderTableView.delegate = self
        
    }
    
    override func positionChanged(currentIndex: IndexPath, newIndex: IndexPath) {
        stores.swapAt(currentIndex.row, newIndex.row)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadUserStores()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        do {
            try UserDefaults.standard.set(object: stores, forKey: "stores")
        } catch {}
    }
    func loadUserStores() {
        do {
            stores = try UserDefaults.standard.get(objectType: [Store].self, forKey: "stores")!
        } catch {
            showFailureToast(message: "No stores found.")
        }
    }

}

extension ItemManagerVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        stores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        //TODO: have store color
        cell.backgroundColor = storeColors[indexPath.row % 6]
        cell.textLabel?.text = stores[indexPath.row].name
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
