//
//  SignUpController.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 1/17/21.
//

import UIKit

class SignUpController: UIViewController {

    @IBOutlet weak var doneButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton.layer.cornerRadius = 10
        // Do any additional setup after loading the view.
    }

    @IBAction func nextPage(_ sender: Any) {
        let storyboard = UIStoryboard(name: "InitialLaunch", bundle: nil)
        let createStoresScreen = storyboard.instantiateViewController(withIdentifier: "createStoresInitial")
        createStoresScreen.modalPresentationStyle = .fullScreen
        self.present(createStoresScreen, animated: true, completion: nil)
    }
}
