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
        tableView.rowHeight = 58
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
            stores = try UserDefaults.standard.get(objectType: [Store].self, forKey: "stores") ?? []
        } catch {
            showFailureToast(message: "No stores found.")
        }
        
        tableView.reloadData()
    }
    
}

extension ItemManagerVC: UITableViewDataSource, UITableViewDelegate, StoreAddedToastDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if stores.isEmpty {
            return 1
        }
        return stores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        if stores.isEmpty {
            cell.backgroundColor = .systemGray4
            cell.textLabel?.text = "No stores are available. Add a store!"
        } else {
            cell.backgroundColor = stores[indexPath.row].color.color
            cell.textLabel?.text = stores[indexPath.row].name
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont(name: "DIN Alternate Bold", size: 22)
            cell.layer.borderWidth = 4
            cell.layer.borderColor = UIColor.systemBackground.cgColor
            cell.layer.cornerRadius = 10
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !stores.isEmpty {
            let vc = storyboard?.instantiateViewController(identifier: "Store Manage Screen") as! StoreManageVC
            vc.storeName = stores[indexPath.row].name
            navigationController?.pushViewController(vc, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            //Launch Add Store Screen
            let gotoVC = (UIStoryboard(name: "AddStore", bundle: nil).instantiateViewController(withIdentifier: "AddItem")) as! AddStoreVC
            gotoVC.successDelegate = self
            gotoVC.modalPresentationStyle = .fullScreen
            gotoVC.navigationItem.backButtonTitle = " "
            navigationController?.pushViewController(gotoVC, animated: true)
        }
    }
    
    func showMessage(message: String, type: SuccessToastEnum) {
        switch type {
        case .success:
            self.showSuccessToast(message: message)
        case .failure:
            self.showFailureToast(message: message)
        case .normal:
            self.showToast(message: message)
        }
    }
    
}
