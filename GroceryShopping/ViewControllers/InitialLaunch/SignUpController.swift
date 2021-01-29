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
        dismiss(animated: true, completion: nil)
    }
}
