//
//  Notification.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 3/4/21.
//

import UIKit
import Lottie

extension UIViewController {
    func showNotification(message: String, duration: Double = 3, image: UIImage = UIImage(systemName: "cart")!, color: UIColor = .label, fontColor: UIColor = .label) {
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first!
        let notificationView = UIView(frame: CGRect(x: 10, y: -50, width: view.frame.size.width - 20, height: 125))
        notificationView.addLeftBorder(with: color, andWidth: 1)
        notificationView.addBottomBorder(with: color, andWidth: 1)
        notificationView.addRightBorder(with: color, andWidth: 1)
        
        let shoppingCartImage = UIImageView(frame: CGRect(x: 10, y: 10, width: notificationView.frame.size.height - 20, height: notificationView.frame.size.height - 20))
        
        shoppingCartImage.image = image
        shoppingCartImage.tintColor = color
        notificationView.addSubview(shoppingCartImage)
        
        let messageLabel = UILabel(frame: CGRect(x: notificationView.frame.size.height, y: 0, width: notificationView.frame.size.width - notificationView.frame.size.height, height: notificationView.frame.size.height))
        messageLabel.textAlignment = .left
        messageLabel.text = message
        messageLabel.font = UIFont(name: "DIN Alternate Bold", size: 20)
        messageLabel.textColor = fontColor
        messageLabel.numberOfLines = 0
        notificationView.addSubview(messageLabel)
        window.addSubview(notificationView)
        
        notificationView.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.2, delay: 0, animations: {
            notificationView.frame.origin.y = 50
        })
        
        UIView.animate(withDuration: 0.2, delay: duration, animations: {
            notificationView.center.y = -50
        }, completion: {_ in
            notificationView.removeFromSuperview()
        })
    }
    
    func showAnimationNotification(animationName: String, message: String, duration: Double = 3, color: UIColor = .label, fontColor: UIColor = .label, playbackSpeed: CGFloat = 1, loop: LottieLoopMode = .playOnce) {
        view.endEditing(true)
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first!
        let notificationView = UIView(frame: CGRect(x: 10, y: -50, width: view.frame.size.width - 20, height: 100))
        notificationView.addLeftBorder(with: color, andWidth: 1)
        notificationView.addBottomBorder(with: color, andWidth: 1)
        notificationView.addRightBorder(with: color, andWidth: 1)
        
        notificationView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.86)
        
        let animationView = AnimationView(name: animationName)
        animationView.frame = CGRect(x: 5, y: 10, width: notificationView.frame.size.height - 20, height: notificationView.frame.size.height - 20)
        animationView.contentMode = .scaleAspectFill
        animationView.animationSpeed = playbackSpeed
        animationView.loopMode = loop
        notificationView.addSubview(animationView)
        
        let messageLabel = UILabel(frame: CGRect(x: notificationView.frame.size.height, y: 0, width: notificationView.frame.size.width - notificationView.frame.size.height, height: notificationView.frame.size.height))
        messageLabel.textAlignment = .left
        messageLabel.text = message
        messageLabel.font = UIFont(name: "DIN Alternate Bold", size: 20)
        messageLabel.textColor = fontColor
        messageLabel.numberOfLines = 0
        notificationView.addSubview(messageLabel)
        window.addSubview(notificationView)
        
        
        notificationView.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.2, delay: 0, animations: {
            notificationView.frame.origin.y = 50
        }, completion: {_ in
            animationView.play()
        })
        
        UIView.animate(withDuration: 0.2, delay: duration, animations: {
            notificationView.center.y = -50
        }, completion: {_ in
            notificationView.removeFromSuperview()
        })
    }
    
    func showErrorNotification(message: String) {
        showAnimationNotification(animationName: "CrossX", message: message, color: .red, fontColor: .red)
    }
    
    func showSuccessNotification(message: String) {
        showAnimationNotification(animationName: "CheckMark", message: message, color: .systemGreen, fontColor: .systemGreen)
    }
}

//MARK: -Single Border
extension UIView {
    
    func addTopBorder(with color: UIColor?, andWidth borderWidth: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        border.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: borderWidth)
        addSubview(border)
    }

    func addBottomBorder(with color: UIColor?, andWidth borderWidth: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        border.frame = CGRect(x: 0, y: frame.size.height - borderWidth, width: frame.size.width, height: borderWidth)
        addSubview(border)
    }

    func addLeftBorder(with color: UIColor?, andWidth borderWidth: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.frame = CGRect(x: 0, y: 0, width: borderWidth, height: frame.size.height)
        border.autoresizingMask = [.flexibleHeight, .flexibleRightMargin]
        addSubview(border)
    }

    func addRightBorder(with color: UIColor?, andWidth borderWidth: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleHeight, .flexibleLeftMargin]
        border.frame = CGRect(x: frame.size.width - borderWidth, y: 0, width: borderWidth, height: frame.size.height)
        addSubview(border)
    }
}
