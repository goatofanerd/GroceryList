//
//  BaseSettingsVC.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 3/2/21.
//

import UIKit
import GoogleSignIn
class BaseSettingsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func logIn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "InitialLaunch", bundle: nil)
        let signUpScreen = storyboard.instantiateViewController(withIdentifier: "signUp") as! SignUpController
        signUpScreen.modalPresentationStyle = .fullScreen
        self.present(signUpScreen, animated: true, completion: nil)
    }
    
}
