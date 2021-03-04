//
//  SignUpController.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 1/17/21.
//

import UIKit
import Firebase
import GoogleSignIn
class SignUpController: UIViewController {

    @IBOutlet weak var googleSignIn: GIDSignInButton!
    @IBOutlet weak var useWithoutAccount: UIButton!
    var presentingVC: UIViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        googleSignIn.colorScheme = (overrideUserInterfaceStyle == .light) ? .dark : .light
        googleSignIn.style = .wide
        GIDSignIn.sharedInstance().presentingViewController = self
        
        // Register notification to update screen after user successfully signed in
        NotificationCenter.default.addObserver(self, selector: #selector(userDidSignIn), name: .signInGoogleCompleted, object: nil)
    }
    
    @objc func userDidSignIn() {
        //Update UI
        let grayView = UIView(frame: view.frame)
        grayView.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        view.addSubview(grayView)
        showAnimationToast(animationName: "LoggingIn", message: "Logging in...", duration: 1.1)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if GIDSignIn.sharedInstance()?.currentUser.profile != nil {
                self.presentingVC.viewDidLoad()
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func useAsGuest(_ sender: Any) {
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .signInGoogleCompleted, object: nil)
    }
}
