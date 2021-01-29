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
    var storeColors = [UIColor(named: "Blue")!, UIColor(named: "Green")!, UIColor(named: "Red")!, UIColor(named: "Orange")!, UIColor(named: "Lime")!, UIColor(named: "LightBlue")!]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let layout = UICollectionViewFlowLayout()
        storeCollectionView.collectionViewLayout = layout
        storeCollectionView.register(StoreCell.nib(), forCellWithReuseIdentifier: StoreCell.identifier)
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
        //collectionViewHeight.constant = CGFloat(75 * ((indexPath.row / 2) + 1))
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoreCell.identifier, for: indexPath) as! StoreCell
        
        let dividend = storeColors.count
        
        if indexPath.row == stores.count{
            cell.configure(storeName: "Add Store", backgroundColor: .darkGray)
        } else {
            cell.configure(storeName: stores[indexPath.row].name, backgroundColor: storeColors[indexPath.row % dividend])
        }
        
        return cell
    }
    
    
}

extension ItemManagerVC: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 10
        return CGSize(width: (collectionView.frame.size.width - padding) / 2, height: 75)
    }
    
    
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
            storeCollectionView.dataSource = self
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
