//
//  ItemManagerVC.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 1/28/21.
//

import UIKit

class ItemManagerVC: UIViewController {
    @IBOutlet weak var storeCollectionView: UICollectionView!
    var stores: [Store] = []
    var items: [Item] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        checkFirstLaunch()
    }
}


//MARK: -Collection View Methods
extension ItemManagerVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        print("tapped")
    }
}

extension ItemManagerVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stores.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "storeCell", for: indexPath)
        
        return cell
    }
    
    
}

extension ItemManagerVC: UICollectionViewDelegateFlowLayout {

}


//MARK: -First Launch
extension ItemManagerVC {
    func checkFirstLaunch() {
        let hasLaunched = UserDefaults.standard.bool(forKey: "hasLaunched")
        if !hasLaunched{
            //Launch Sign Up Screen
            print("new launch")
            let storyboard = UIStoryboard(name: "InitialLaunch", bundle: nil)
            let signUpScreen = storyboard.instantiateViewController(withIdentifier: "signUp")
            signUpScreen.modalPresentationStyle = .fullScreen
            UserDefaults.standard.set(true, forKey: "hasLaunched")
            self.present(signUpScreen, animated: false, completion: nil)
        }
        else {
            print("already launched")
            storeCollectionView.delegate = self
            //storeCollectionView.dataSource = self
            loadUserItems()
        }
    }
    
    func loadUserItems() {
        do {
            stores = try UserDefaults.standard.get(objectType: [Store].self, forKey: "stores") ?? []
            items = try UserDefaults.standard.get(objectType: [Item].self, forKey: "items") ?? []
        } catch {
            print("error getting stores/items")
        }
    }
}
