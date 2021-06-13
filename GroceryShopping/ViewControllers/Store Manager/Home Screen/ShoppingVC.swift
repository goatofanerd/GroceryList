//
//  ShoppingVC.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 1/28/21.
//

import UIKit
import ViewAnimator
import GoogleSignIn
import FirebaseDatabase
class ShoppingVC: UIViewController {
    @IBOutlet weak var storeCollectionView: UICollectionView!
    @IBOutlet weak var profilePicture: UIBarButtonItem!
    var stores: [Store] = []
    var items: [Item] = []
    var boughtItems: [Item] = []
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let layout = UICollectionViewFlowLayout()
        storeCollectionView.collectionViewLayout = layout
        storeCollectionView.register(StoreCell.nib(), forCellWithReuseIdentifier: StoreCell.identifier)
        self.storeCollectionView.contentInsetAdjustmentBehavior = .never
        UIView.animate(views: storeCollectionView.visibleCells, animations: [AnimationType.from(direction: .top, offset: 300)])
        ref = Database.database().reference()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let user = GIDSignIn.sharedInstance()?.currentUser?.profile?.givenName {
                self.showAnimationToast(animationName: "LoginSuccess", message: "Welcome, " + user, color: .systemBlue, fontColor: .systemBlue)
            }
        }
        
        addObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkFirstLaunch()
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(storesChanged), name: .newStoreAdded, object: nil)
    }
    
    @objc func storesChanged() {
        
        Family.getMostRecentChange(familyRef: self.ref.child("families").child(Family.id!)) { [self] (message, user) in
            print("hehehehehe")
            guard user != GIDSignIn.sharedInstance()!.currentUser.profile.email else {
                return
            }
            
            guard message != "" else {
                return
            }
            
            self.showAnimationNotification(animationName: "EnvelopeSharing", message: message, duration: 2.5 ,color: .systemBlue, fontColor: .systemBlue)
            checkFirstLaunch()
            self.storeCollectionView.reloadData()
        }
    }
}


//MARK: -Collection View Methods
extension ShoppingVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stores.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //collectionViewHeight.constant = CGFloat(75 * ((indexPath.row / 2) + 1))
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoreCell.identifier, for: indexPath) as! StoreCell
        
        cell.storeName.textColor = .white

        
        if indexPath.row == stores.count{
            cell.configure(storeName: "Add Store", backgroundColor: UIColor(named: "AddStoreColor")!)
        } else {
            cell.configure(storeName: stores[indexPath.row].name, backgroundColor: stores[indexPath.row].color.color)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if indexPath.row == stores.count {
            //Launch Add Store Screen
            var gotoVC: AddStoreVC
            gotoVC = (UIStoryboard(name: "AddStore", bundle: nil).instantiateViewController(withIdentifier: "AddItem")) as! AddStoreVC
            gotoVC.modalPresentationStyle = .fullScreen
            gotoVC.navigationItem.backButtonTitle = " "
            navigationController?.pushViewController(gotoVC, animated: true)
        } else {
            //Launch user store screen
            var gotoVC: UIViewController
            gotoVC = (UIStoryboard(name: "StoreScreen", bundle: nil).instantiateViewController(withIdentifier: "StoreScreen"))
            gotoVC.navigationItem.title = stores[indexPath.row].name
            gotoVC.modalPresentationStyle = .fullScreen
            gotoVC.navigationItem.backButtonTitle = " "
            navigationController?.pushViewController(gotoVC, animated: true)
            
        }
    }
}

extension ShoppingVC: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 10
        return CGSize(width: (collectionView.frame.size.width - padding) / 2, height: (collectionView.frame.size.width - padding)/4)
    }
    
    
}

//MARK: -First Launch
extension ShoppingVC {
    func checkFirstLaunch() {
        let hasLaunched = UserDefaults.standard.bool(forKey: "hasLaunched")
        if !hasLaunched {
            //Launch Sign Up Screen
            print("new launch")
            let storyboard = UIStoryboard(name: "InitialLaunch", bundle: nil)
            let signUpScreen = storyboard.instantiateViewController(withIdentifier: "signUp") as! SignUpController
            signUpScreen.modalPresentationStyle = .fullScreen
            UserDefaults.standard.set(true, forKey: "hasLaunched")
            self.present(signUpScreen, animated: true, completion: nil)
        }
        else {
            storeCollectionView.delegate = self
            storeCollectionView.dataSource = self
            loadUserItems()
        }
    }
    
    func loadUserItems() {
        do {
            if userIsLoggedIn() {
                let loadingScreen = createLoadingScreen(frame: view.frame, message: "Loading stores, please wait.", animation: "Loading")
                view.addSubview(loadingScreen)
                let user = GIDSignIn.sharedInstance().currentUser!
                Family.getFamily(email: user.profile.email) { (familyID) in
                    Family.id = familyID
                    
                    
                    self.getAllUserData(user: user) { stores, items, boughtItems in
                        
                        self.stores = stores
                        self.items = items
                        self.boughtItems = boughtItems
                        
                        self.storeCollectionView.reloadData()
                        loadingScreen.removeFromSuperview()
                        
                        Family.stores = stores
                        Family.items = items
                        Family.boughtItems = boughtItems
                    }
                    
                    if !Family.hasAddedNotifications, let id = familyID {
                        print("adding notifications")
                        Family.addNotificationsForStorageUpdates(familyRef: self.ref.child("families").child(id), user: GIDSignIn.sharedInstance().currentUser)
                    }
                    
                }
                
                //TODO: Get profile picture
//                if user.profile.hasImage {
//                    let url = user.profile.imageURL(withDimension: 50)
//                    DispatchQueue.global().async {
//                        let data = try? Data(contentsOf: url!)
//                        DispatchQueue.main.async {
//                            self.profilePicture.image = UIImage(data: data!)
//                        }
//                    }
//                } else {
//                    print("no image")
//                }
                
            } else {
                stores = try UserDefaults.standard.get(objectType: [Store].self, forKey: "stores") ?? []
                items = try UserDefaults.standard.get(objectType: [Item].self, forKey: "items") ?? []
            }
        } catch {
            print("error getting stores/items")
        }
        
        storeCollectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Family.stores = stores
        Family.items = items
        Family.boughtItems = boughtItems
//        if userIsLoggedIn() {
//            uploadUserStuffToDatabase() { (completion) in
//                if !completion {
//                    print("error saving")
//                }
//            }
//        }
    }
}

extension UIImage {
    
  convenience init?(url: URL?) {
    
    guard let url = url else {
        print("error with url")
        return nil
    }
            
    do {
      self.init(data: try Data(contentsOf: url))
    } catch {
      print("Cannot load image from url: \(url) with error: \(error)")
      return nil
    }
    
  }
    
}
