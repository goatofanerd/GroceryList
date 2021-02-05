//
//  StoreCell.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 1/28/21.
//

import UIKit

class StoreCell: UICollectionViewCell {
    @IBOutlet var storeName: UILabel!
    static let identifier = "StoreCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func configure(storeName: String, backgroundColor: UIColor) {
        self.layer.cornerRadius = 5
        self.backgroundColor = backgroundColor
        self.storeName.text = storeName
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "StoreCell", bundle: nil)
    }
    

}
