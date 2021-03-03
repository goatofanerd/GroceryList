//
//  TextFieldItemManagerCell.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 2/28/21.
//

import UIKit

class TextFieldItemManagerCell: UITableViewCell {
    
    static let identifier = "TextFieldCell"
    @IBOutlet weak var textField: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(withText text: String, delegate: UITextFieldDelegate, tag: Int, placeholder: String = "Name of item...") {
        textField.returnKeyType = .done
        textField.delegate = delegate
        textField.text = text
        textField.tag = tag
        textField.borderStyle = .none
        textField.font = UIFont(name: "Sinhala Sangam MN", size: 21)
        textField.placeholder = placeholder
        
        //Separator full line
        preservesSuperviewLayoutMargins = false
        separatorInset = .zero
        layoutMargins = .zero
    }

}
