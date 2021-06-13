//
//  StorageHelpers.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 3/30/21.
//

import UIKit
import FirebaseDatabase
import GoogleSignIn
import Lottie
extension String {
    //MARK: -Email
    func toLegalStorageEmail() -> String {
        return self.replacingOccurrences(of: ".", with: "||", options: .literal)
    }
    
    func fromStorageEmail() -> String {
        return self.replacingOccurrences(of: "||", with: ".", options: .literal)
    }
}

extension Color {
    func toLegalStorageColor() -> String {
        return "\(red) \(green) \(blue)"
    }
    
    static func toColor(from string: String) -> Color {
        let rgb = string.components(separatedBy: " ")
        return Color(color: UIColor(red: CGFloat(Int(rgb[0])!), green: CGFloat(Int(rgb[1])!), blue: CGFloat(Int(rgb[2])!), alpha: 1))
    }
    
}

extension UIViewController {
    func uploadUserStuffToDatabase(completion: @escaping(Bool) -> Void) {
        
        let items = Family.items
        let stores = Family.stores
        let boughtItems = Family.boughtItems
        
        let ref = Database.database().reference()
        
        do {
            let storesEncoded = try HelperFunctions.encodeToJSON(stores)
            let itemsEncoded = try HelperFunctions.encodeToJSON(items)
            let boughtItemsEncoded = try HelperFunctions.encodeToJSON(boughtItems)
            if let familyID = Family.id {
                ref.child("families").child(familyID).child("stores").setValue(storesEncoded)
                ref.child("families").child(familyID).child("items").setValue(itemsEncoded)
                ref.child("families").child(familyID).child("bought_items").setValue(boughtItemsEncoded)
            }
            
            completion(true)
        } catch {
            completion(false)
            return
        }
    }
    
    func getStores(user: GIDGoogleUser, completion: @escaping([Store]) -> Void) {
        guard let familyID = Family.id else {
            completion([])
            return
        }
        let ref = Database.database().reference().child("families").child(familyID).child("stores")
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                do {
                    completion(try HelperFunctions.decodeFromString(snapshot.value as! String, objectType: [Store].self))
                } catch {
                    completion([])
                }
            } else {
                completion([])
            }
        }
    }
    
    func getItems(user: GIDGoogleUser, completion: @escaping([Item]) -> Void) {
        guard let familyID = Family.id else {
            completion([])
            return
        }
        let ref = Database.database().reference().child("families").child(familyID).child("items")
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                do {
                    completion(try HelperFunctions.decodeFromString(snapshot.value as! String, objectType: [Item].self))
                } catch {
                    print("error")
                    completion([])
                }
            } else {
                print("doesnt exist")
                completion([])
            }
        }
    }
    
    func getBoughtItems(user: GIDGoogleUser, completion: @escaping([Item]) -> Void) {
        guard let familyID = Family.id else {
            completion([])
            return
        }
        let ref = Database.database().reference().child("families").child(familyID).child("bought_items")
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                do {
                    completion(try HelperFunctions.decodeFromString(snapshot.value as! String, objectType: [Item].self))
                } catch {
                    print("error")
                    completion([])
                }
            } else {
                print("doesnt exist")
                completion([])
            }
        }
    }
    
    func getAllUserData(user: GIDGoogleUser, completion: @escaping([Store], [Item], [Item]) -> Void) {
        guard let familyID = Family.id else {
            completion([], [], [])
            return
        }
        let ref = Database.database().reference().child("families").child(familyID)
        
        ref.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                do {
                    let storesSnapshot = snapshot.childSnapshot(forPath: "stores")
                    let itemsSnapshot = snapshot.childSnapshot(forPath: "items")
                    let boughtItemsSnapshot = snapshot.childSnapshot(forPath: "bought_items")
                    
                    if storesSnapshot.exists() && itemsSnapshot.exists() && boughtItemsSnapshot.exists() {
                        
                        let stores = try HelperFunctions.decodeFromString(storesSnapshot.value as! String, objectType: [Store].self)
                        let items = try HelperFunctions.decodeFromString(itemsSnapshot.value as! String, objectType: [Item].self)
                        let boughtItems = try HelperFunctions.decodeFromString(boughtItemsSnapshot.value as! String, objectType: [Item].self)
                        
                        completion(stores, items, boughtItems)
                    } else {
                        print("doesnt exist")
                        completion([], [], [])
                    }
                } catch {
                    print("error")
                    completion([], [], [])
                }
            } else {
                print("doesnt exist")
                completion([], [], [])
            }
        }
        
        
    }
    func userIsLoggedIn() -> Bool {
        if GIDSignIn.sharedInstance()?.currentUser == nil {
            return false
        }
        return true
    }
    
    func createLoadingScreen(frame: CGRect, message: String = "", animation: String? = nil) -> UIView {
        
        let loadingScreen = UIView(frame: frame)
        loadingScreen.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
        if let animation = animation{
            let animationView = AnimationView(name: animation)
            animationView.center = view.center
            animationView.contentMode = .scaleAspectFill
            animationView.loopMode = .loop
            animationView.play()
            loadingScreen.addSubview(animationView)
        }
        else {
            let loadingIndicator = UIActivityIndicatorView(frame: view.frame)
            loadingIndicator.style = .large
            loadingIndicator.startAnimating()
            loadingScreen.addSubview(loadingIndicator)
        }
        
        let messageView = UILabel(frame: CGRect(x: view.center.x - 100, y: view.center.y + 60, width: 200, height: 50))
        messageView.textAlignment = .center
        messageView.font = UIFont(name: "DIN Alternate Bold", size: 20)
        messageView.text = message
        loadingScreen.addSubview(messageView)
        
        return loadingScreen
    }
    
    func uploadMostRecentChange(message: String) {
        guard let familyID = Family.id else {
            print("no family ID")
            return
        }
        
        let familyRef = Database.database().reference().child("families").child(familyID)
        familyRef.child("recent_change").child("message").setValue(message)
        familyRef.child("recent_change").child("user").setValue(GIDSignIn.sharedInstance()?.currentUser.profile.email)
    }
}

struct HelperFunctions {
    static func encodeToJSON<T: Codable>(_ object: T) throws -> String {
        let data = try JSONEncoder().encode(object)
        return String(decoding: data, as: UTF8.self)
    }
    
    static func decodeFromString<T: Codable>(_ string: String, objectType: T.Type) throws -> T {
        return try JSONDecoder().decode(objectType, from: string.data(using: .utf8)!)
    }
}


