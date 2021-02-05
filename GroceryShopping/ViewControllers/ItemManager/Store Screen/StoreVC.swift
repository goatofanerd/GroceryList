//
//  StoreVC.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 2/4/21.
//

import UIKit

class StoreVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backToHomeScreen(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    

}
