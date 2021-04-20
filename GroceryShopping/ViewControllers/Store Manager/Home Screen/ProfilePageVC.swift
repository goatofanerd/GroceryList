//
//  ProfilePageVC.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 4/13/21.
//

import UIKit
import FirebaseDatabase
import GoogleSignIn

class ProfilePageVC: UIViewController {
    
    @IBOutlet weak var familyCode: UILabel!
    @IBOutlet weak var currentUsersTableView: UITableView!
    @IBOutlet weak var currentlySignedInAs: UILabel!
    var ref: DatabaseReference!
    var loadingScreen: UIView!
    var users: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ref = Database.database().reference()
        
        loadingScreen = createLoadingScreen(frame: view.frame, message: "Loading data", animation: "Loading")
        
        //Table view
        currentUsersTableView.dataSource = self
        currentUsersTableView.tableFooterView = UIView()
        currentUsersTableView.rowHeight = 50
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.addSubview(loadingScreen)
        
        familyCode.text = "Loading..."
        
        loadUserInfo()
    }
    
    @IBAction func logOut(_ sender: Any?) {
        GIDSignIn.sharedInstance().signOut()
        navigationController?.popViewController(animated: true)
    }
}

extension ProfilePageVC {
    
    func loadUserInfo() {
        guard let currentUser = GIDSignIn.sharedInstance()?.currentUser?.profile?.email else {
            let alertView = UIAlertController(title: "Error", message: "You are not signed in, please sign in to view this page", preferredStyle: .alert)
            
            let exitButton = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                self.navigationController?.popViewController(animated: true)
            }
            
            alertView.addAction(exitButton)
            
            present(alertView, animated: true, completion: nil)
            return
        }
        users = []
        
        guard let familyID = Family.id else {
            let alertView = UIAlertController(title: "Error", message: "Error retrieving family, please sign in again!", preferredStyle: .alert)
            
            let exitButton = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                self.navigationController?.popViewController(animated: true)
            }
            
            alertView.addAction(exitButton)
            
            present(alertView, animated: true, completion: nil)
            return
        }
        
        getUsersInFamily(familyID) { (familyUsers) in
            self.users = familyUsers
            self.updateUI(familyID: familyID, currentUser: currentUser, users: self.users)
        }
    }
    
    func updateUI(familyID: String, currentUser: String, users: [String]) {
        
        familyCode.text = "\(familyID)"
        currentlySignedInAs.text = "Currently signed in as: \(currentUser)"
        currentUsersTableView.reloadData()
        loadingScreen.removeFromSuperview()
        
    }
    func getUsersInFamily(_ family: String, completion: @escaping(([String]) -> Void))  {
        var users: [String] = []
        
        ref.child("families").child(family).child("people").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                users = snapshot.value as? [String] ?? [(snapshot.value as! String)]
                completion(users)
            } else {
                completion([])
            }
        }
    }
    
}

extension ProfilePageVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.font = UIFont(name: "Kohinoor Telugu Medium", size: 20)
        cell.textLabel?.text = users[indexPath.row]
        
        //Separator Full Line
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
        return cell
    }
    
    
}
