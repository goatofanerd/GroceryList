//
//  ItemCell.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 2/5/21.
//

import UIKit

class ItemCell: UITableViewCell {

    static let identifier = "Item Cell"
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var lastBought: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
