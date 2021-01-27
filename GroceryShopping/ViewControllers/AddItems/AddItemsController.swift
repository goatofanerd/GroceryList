//
//  AddItemsController.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 1/17/21.
//

import UIKit

class ManageItemsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var stores: [Store] = []
    var items: [[String]]?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    func addStoresToTableView() {
        var indexPath: [IndexPath] = []
        for (section, store) in stores.enumerated() {
            
            for row in 0...store.items.count {
                indexPath.append(IndexPath(row: row, section: section))
            }
        }
        
        var isEmpty = true
        
        for index in indexPath {
            if index.row != 0 {
                isEmpty = false
            }
        }
        if !isEmpty {
            tableView.insertRows(at: indexPath, with: .none)
        }
    }
    
    func loadUserItems() {
        //TODO: Retrieve data from user's database
        do {
            stores = try UserDefaults.standard.get(objectType: [Store].self, forKey: "stores") ?? []
        } catch {
            print("error retrieving stores")
        }
    }
}

extension ManageItemsVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return stores[section].name
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return stores.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stores[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = stores[indexPath.section].getItem(atIndex: indexPath.row).0
        return cell
    }
    
    
}
//MARK: First Launch
extension ManageItemsVC {
    override func viewWillAppear(_ animated: Bool) {
        checkAppLaunch();
    }
    
    func checkAppLaunch() {
        let hasLaunched = UserDefaults.standard.bool(forKey: "hasLaunched")
        if !hasLaunched{
            //Launch Sign Up Screen
            print("new launch")
            let storyboard = UIStoryboard(name: "InitialLaunch", bundle: nil)
            let signUpScreen = storyboard.instantiateViewController(withIdentifier: "signUp")
            signUpScreen.modalPresentationStyle = .fullScreen
            self.present(signUpScreen, animated: false, completion: nil)
        }
        else {
            print("already launched")
            tableView.dataSource = self
            loadUserItems()
            addStoresToTableView()
        }
    }
}
