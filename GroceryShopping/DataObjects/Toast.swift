//
//  Toast.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 2/4/21.
//

import UIKit

extension UIViewController {
    func showToast(message: String, duration: Double = 2, image: UIImage = UIImage(systemName: "cart")!, color: UIColor = .label, fontColor: UIColor = .label) {
        view.endEditing(true)
        let toastView = UIView(frame: CGRect(x: 10, y: view.frame.size.height - view.safeAreaInsets.bottom, width: view.frame.size.width - 20, height: 50))
        toastView.layer.borderWidth = 2
        toastView.layer.borderColor = color.cgColor
        toastView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.6)
        
        let shoppingCartImage = UIImageView(frame: CGRect(x: 10, y: 10, width: toastView.frame.size.height - 20, height: toastView.frame.size.height - 20))
        
        shoppingCartImage.image = image
        shoppingCartImage.tintColor = color
        toastView.addSubview(shoppingCartImage)
        
        let messageLabel = UILabel(frame: CGRect(x: toastView.frame.size.height, y: 5, width: toastView.frame.size.width - toastView.frame.size.height, height: 40))
        messageLabel.text = message
        messageLabel.font = UIFont(name: "DIN Alternate Bold", size: 20)
        messageLabel.textColor = fontColor
        toastView.addSubview(messageLabel)
        view.addSubview(toastView)
        
        UIView.animate(withDuration: 0.2, delay: 0, animations: {
            toastView.frame.origin.y = self.view.frame.size.height - self.view.safeAreaInsets.bottom - 70
        })
        
        UIView.animate(withDuration: 0.2, delay: duration, animations: {
            toastView.center.y = self.view.frame.size.height + 50
        }, completion: {_ in
            toastView.removeFromSuperview()
        })
    }
    
    
    ///Shows a green toast
    func showSuccessToast(message: String) {
        showToast(message: message, image: UIImage(systemName: "checkmark")!, color: .green, fontColor: .green)
    }
    
    ///Shows a red toast
    func showFailureToast(message: String) {
        showToast(message: message, image: UIImage(systemName: "multiply")!, color: .red, fontColor: .red)
    }
}
