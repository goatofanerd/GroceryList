//
//  SignUpController.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 1/17/21.
//

import UIKit
import Firebase
import GoogleSignIn
import FirebaseDatabase
class SignUpController: UIViewController {

    @IBOutlet weak var googleSignIn: GIDSignInButton!
    @IBOutlet weak var useWithoutAccount: UIButton!
    var ref: DatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        ref = Database.database().reference()
        googleSignIn.colorScheme = (overrideUserInterfaceStyle == .light) ? .dark : .light
        googleSignIn.style = .wide
        GIDSignIn.sharedInstance().presentingViewController = self
        
        // Register notification to update screen after user successfully signed in
        NotificationCenter.default.addObserver(self, selector: #selector(userDidSignIn), name: .signInGoogleCompleted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userDidJoinFamily), name: .signedIntoFamily, object: nil)
    }
    
    @objc func userDidJoinFamily() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func userDidSignIn() {
        //Update UI
        let loadingView = createLoadingScreen(frame: view.frame)
        view.addSubview(loadingView)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
            if let user = GIDSignIn.sharedInstance()?.currentUser {
                ref.child("user_emails").child(user.profile.email.toLegalStorageEmail()).child("uid").setValue(user.userID)
                showAnimationToast(animationName: "LoginSuccess", message: "Welcome, " + user.profile.givenName, color: .systemBlue, fontColor: .systemBlue)
                
                //Clear User Data
                UserDefaults.standard.removeObject(forKey: "items")
                UserDefaults.standard.removeObject(forKey: "stores")
                Family.reset()
                loadingView.removeFromSuperview()
            }
            
            //Launch Family Code
            let familyVC = storyboard!.instantiateViewController(identifier: "Family Code Screen") as! FamilyCodeVC
            present(familyVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func useAsGuest(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signOut()
        self.dismiss(animated: true, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .signInGoogleCompleted, object: nil)
        NotificationCenter.default.removeObserver(self, name: .signedIntoFamily, object: nil)
    }
}
