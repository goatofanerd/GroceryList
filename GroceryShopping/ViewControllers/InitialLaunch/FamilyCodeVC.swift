//
//  FamilyCodeVC.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 4/11/21.
//

import UIKit
import FirebaseDatabase
import GoogleSignIn

class FamilyCodeVC: UIViewController {
    
    @IBOutlet weak var familyField: UITextField!
    var ref: DatabaseReference!
    var existingFamilies: NSDictionary!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        ref = Database.database().reference()
        ref.child("families").observeSingleEvent(of: .value) { (snap) in
            if snap.exists() {
                self.existingFamilies = (snap.value as! NSDictionary)
            } else {
                self.existingFamilies = NSDictionary()
            }
        }
        
        hideKeyboardWhenTappedAround()
        
        familyField.delegate = self
    }
    
    @IBAction func doneButton(_ sender: Any) {
        joinFamily(familyField.text!)
    }
    
    @IBAction func createButton(_ sender: Any) {
        let loadingScreen = createLoadingScreen(frame: view.frame, message: "Creating, please wait.", animation: "Loading")
        view.addSubview(loadingScreen)
        let currentUser = GIDSignIn.sharedInstance()!.currentUser!.profile
        var hasFound = false
        var number = 0
        var familyID: String!
        while !hasFound {
            familyID = "\(currentUser!.familyName!)\(number)"
            if !familyIDExists(familyID) {
                hasFound = true
                createFamily(with: familyID)
                loadingScreen.removeFromSuperview()
                showSuccessNotification(message: "Created family and logged in!")
            } else {
                number += 1
            }
        }
    }
    
    func familyIDExists(_ id: String) -> Bool {
        let allKeys = existingFamilies.allKeys as! [String]
        if (allKeys.contains(id)) {
            return true
        }
        return false
    }
    
    func createFamily(with id: String) {
        let currentUser = GIDSignIn.sharedInstance()!.currentUser
        ref.child("families").child(id).child("people").setValue(currentUser?.profile.email)
        ref.child("user_emails").child(currentUser!.profile.email.toLegalStorageEmail()).child("family").setValue(id)
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: .signedIntoFamily, object: nil)
    }
    
    func joinFamily(_ family: String) {
        let currentUser = GIDSignIn.sharedInstance()!.currentUser
        
        let familyRef = ref.child("families").child(family).child("people")
        
        familyRef.observeSingleEvent(of: .value) { (snap) in
            guard snap.exists() else {
                Alert.regularAlert(title: "This family doesn't exist", message: "Create a new family or re enter the old one!", vc: self)
                return
            }
            self.ref.child("user_emails").child(currentUser!.profile.email.toLegalStorageEmail()).child("family").setValue(family)
            var existingPeople: [String] = []
            if (snap.value as? String) != nil {
                existingPeople.append(snap.value as! String)
            }
            for email in snap.children {
                existingPeople.append((email as! DataSnapshot).value as! String)
            }
            existingPeople.append(currentUser!.profile.email)
            familyRef.setValue(existingPeople)
            NotificationCenter.default.post(name: .signedIntoFamily, object: nil)
            self.showSuccessNotification(message: "Signed into family successfully!")
            self.dismiss(animated: true, completion: nil)
            
        }
    }
}


extension FamilyCodeVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        joinFamily(textField.text!)
        return true
    }
}
