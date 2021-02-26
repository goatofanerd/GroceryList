//
//  StoreManageVC.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 2/25/21.
//

import UIKit

class StoreManageVC: UIViewController {

    @IBOutlet weak var colorPreviewView: UIView!
    @IBOutlet weak var colorPreview: UIImageView!
    var storeName: String!
    var store: Store!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setNavBarItems()
        
        //Change Store Color
        let tapGestureRecognizerColor = UITapGestureRecognizer(target: self, action: #selector(launchPickerView))
        colorPreviewView.addGestureRecognizer(tapGestureRecognizerColor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getStore()
        
        colorPreview.tintColor = store.color.color
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        save()
    }
    
    func save() {
        do {
            var stores = try UserDefaults.standard.get(objectType: [Store].self, forKey: "stores")
            if let existingStore = stores?.firstStore(name: storeName) {
                stores![existingStore].color = Color(color: colorPreview.tintColor)
            } else {
                showFailureToast(message: "Error saving color.")
            }
            
            
            try UserDefaults.standard.set(object: stores, forKey: "stores")
        } catch {
            print("error saving")
        }
    }

}

//MARK: -Initial Setup
extension StoreManageVC {
    func setNavBarItems() {
        self.navigationItem.title = storeName
        
        //X Button
        let xButton = UIBarButtonItem(image: UIImage(systemName: "multiply"), style: .plain, target: self, action: #selector(dismissScreen))
        xButton.tintColor = .label
        self.navigationItem.leftBarButtonItem = xButton
        
        //Trash Button
        let trashButton = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: #selector(deleteStore))
        trashButton.tintColor = .systemRed
        self.navigationItem.rightBarButtonItem = trashButton
    }
    
    @objc func dismissScreen() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func deleteStore() {
        let alert = UIAlertController(title: "Are you sure you want to delete?", message: "This action is irreversible!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [self]_ in
            do {
                var tempItems: [Item] = []
                let items = try UserDefaults.standard.get(objectType: [Item].self, forKey: "items")!
                for var item in items {
                    if item.stores.containsStore(Store(name: storeName)) {
                        try item.stores.removeStore(withStore: storeName)
                    }
                    tempItems.append(item)
                }
                
                try UserDefaults.standard.set(object: tempItems, forKey: "items")
                var stores = try UserDefaults.standard.get(objectType: [Store].self, forKey: "stores")!
                try stores.removeStore(withStore: storeName)
                try UserDefaults.standard.set(object: stores, forKey: "stores")
                self.navigationController?.viewControllers[0].showSuccessToast(message: "Successfully deleted!")
                self.navigationController?.popViewController(animated: true)
            } catch {
                self.showFailureToast(message: "Error deleting!")
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func getStore() {
        do {
            let stores = try UserDefaults.standard.get(objectType: [Store].self, forKey: "stores")!
            store = stores[stores.firstStore(name: storeName)!]
        } catch {
            showFailureToast(message: "Error getting store.")
        }
    }
}

extension StoreManageVC: UIColorPickerViewControllerDelegate {
    @objc func launchPickerView() {
        colorPreviewView.backgroundColor = .systemGray4
        let colorPicker = UIColorPickerViewController()
        colorPicker.selectedColor = colorPreview.tintColor
        colorPicker.delegate = self
        present(colorPicker, animated: true, completion: nil)
    }
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        colorPreviewView.backgroundColor = .systemGray6
        colorPreview.tintColor = viewController.selectedColor
    }
}
