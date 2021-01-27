//
//  Alert.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 1/23/21.
//

import Foundation
import UIKit
struct Alert {
    
    static func regularAlert(title: String, message: String, vc: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
}
