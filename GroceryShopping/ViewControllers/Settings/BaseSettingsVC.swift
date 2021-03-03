//
//  BaseSettingsVC.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 3/2/21.
//

import UIKit
import GoogleSignIn
class BaseSettingsVC: UIViewController {

    var shouldShowToast = false
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if shouldShowToast {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let user = GIDSignIn.sharedInstance()?.currentUser?.profile?.name {
                    self.showAnimationToast(animationName: "LoginSuccess", message: "Welcome " + user, color: .systemBlue, fontColor: .systemBlue)
                }
            }
        }
        shouldShowToast = true
    }
    
    @IBAction func logIn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "InitialLaunch", bundle: nil)
        let signUpScreen = storyboard.instantiateViewController(withIdentifier: "signUp") as! SignUpController
        signUpScreen.modalPresentationStyle = .fullScreen
        signUpScreen.presentingVC = self
        self.present(signUpScreen, animated: true, completion: nil)
    }
    
}
