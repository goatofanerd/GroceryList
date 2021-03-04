//
//  AddItemVC.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 1/29/21.
//

import UIKit

class AddStoreVC: UIViewController {
    
    @IBOutlet weak var storeColorView: UIView!
    @IBOutlet weak var colorPreview: UIImageView!
    @IBOutlet weak var createButton: UIBarButtonItem!
    @IBOutlet weak var storeName: UIButton!
    var color: UIColor = .systemBlue
    public var successDelegate: StoreAddedToastDelegate!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        storeName.layer.borderWidth = 2
        storeName.layer.borderColor = UIColor.gray.cgColor
        createButton.tintColor = .gray
        
        storeColorView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.launchColorPicker(sender:))))
    }
    
    @objc func launchColorPicker(sender: UITapGestureRecognizer) {
        storeColorView.backgroundColor = .systemGray4
        let colorPicker = UIColorPickerViewController()
        colorPicker.selectedColor = color
        colorPicker.delegate = self
        present(colorPicker, animated: true, completion: nil)
    }
    
}

extension AddStoreVC: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        storeColorView.backgroundColor = .systemGray6
        color = viewController.selectedColor
        colorPreview.tintColor = color
    }
}

extension AddStoreVC {
    
    @IBAction func cancel(_ sender: Any) {
        if let store = storeName.title(for: .normal)?.trimmingCharacters(in: .whitespacesAndNewlines) {
            
            let alert = UIAlertController(title: "You have saved data.", message: "You have some saved data, are you sure you want to discard your store?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { [self]_ in
                do {
                    var stores = try UserDefaults.standard.get(objectType: [Store].self, forKey: "stores") ?? []
                    stores.append(Store(name: store, color: color))
                    try UserDefaults.standard.set(object: stores, forKey: "stores")
                    self.successDelegate.showMessage(message: "Successfully added \(store)!", type: .success)
                    navigationController?.popViewController(animated: true)
                } catch {
                    showFailureToast(message: "Error, try rebooting the application.")
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Discard", style: .destructive, handler: {_ in
                self.navigationController?.popViewController(animated: true)
                self.successDelegate.showMessage(message: "Discarded store.", type: .normal)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
        }
        else {
            successDelegate.showMessage(message: "Discarded store.", type: .normal)
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func createStoreAndExit(_ sender: Any) {
        guard let store = storeName.title(for: .normal)?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            showFailureToast(message: "No name entered!")
            return
        }
        
        guard createButton.tintColor != .gray else {
            showFailureToast(message: "No name entered!")
            return
        }
        
        do {
            var stores = try UserDefaults.standard.get(objectType: [Store].self, forKey: "stores") ?? []
            stores.append(Store(name: store, color: color))
            try UserDefaults.standard.set(object: stores, forKey: "stores")
            self.successDelegate.showMessage(message: "Successfully added \(store)!", type: .success)
            navigationController?.popViewController(animated: true)
        } catch {
            showFailureToast(message: "Error, try rebooting the application.")
        }
    }
    @IBAction func addStoreButtonTapped(_ sender: Any) {
        
        let newStoreVC = storyboard?.instantiateViewController(identifier: "StoreAdder") as! StoreNameEnterVC
        newStoreVC.itemDelegate = self
        newStoreVC.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(newStoreVC, animated: true)
    }
    
    @IBAction func addItemsButtonTapped(_ sender: Any) {
        guard let title = storeName.title(for: .normal)?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            Alert.regularAlert(title: "Enter store name first", message: "Please enter the store name before you can add items", vc: self)
            return
            
        }
        let newItemVC = storyboard?.instantiateViewController(identifier: "AddItemsNew") as! AddItemsVC
        let navController = UINavigationController(rootViewController: newItemVC) // Creating a navigation controller with VC1 at the root of the navigation stack.
        if let title = storeName.title(for: .normal)?.trimmingCharacters(in: .whitespacesAndNewlines) {
            newItemVC.navigationItem.title = title + " List"
        } else {
            newItemVC.navigationItem.title = "Add Items"
        }
        
        newItemVC.storeName = title
        self.present(navController, animated: true, completion: nil)
    }
    
}

protocol StoreAddedToastDelegate {
    func showMessage(message: String, type: SuccessToastEnum)
}
extension AddStoreVC: StoreDelegate {
    func addStore(_ store: String) {
        storeName.setTitleColor(UIColor.label, for: .normal)
        storeName.setTitle("   " + store.trimmingCharacters(in: .whitespacesAndNewlines), for: .normal)
        createButton.tintColor = .label
    }
}
