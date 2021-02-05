//
//  ItemsCheckboxCell.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 2/1/21.
//

import UIKit

class ItemsCheckboxCell: UITableViewCell {
    static let reuseIdentifier = "Item Cell"
    @IBOutlet var checkBox: UIButton!
    @IBOutlet var itemName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(itemName: String) {
        self.itemName.text = itemName
    }

}
