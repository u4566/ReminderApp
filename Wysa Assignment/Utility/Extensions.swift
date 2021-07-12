//
//  Extensions.swift
//  Wysa Assignment
//
//  Created by Vaibhav on 11/07/21.
//

import Foundation
import UIKit
import CoreData

extension UITableView {
    func setBackground(isEmpty : Bool = false) {
        let label = UILabel(frame: CGRect(x: 20, y: 50, width: 150, height: 20))
        label.font = .systemFont(ofSize: 18)
        label.textColor = .black
        label.text = isEmpty ? "No Reminders!!!" : ""
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 200))
        view.addSubview(label)
        self.backgroundView = view
    }
}

extension UIView {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        if #available(iOS 11, *) {
            var cornerMask = CACornerMask()
            if(corners.contains(.topLeft)){
                cornerMask.insert(.layerMinXMinYCorner)
            }
            if(corners.contains(.topRight)){
                cornerMask.insert(.layerMaxXMinYCorner)
            }
            if(corners.contains(.bottomLeft)){
                cornerMask.insert(.layerMinXMaxYCorner)
            }
            if(corners.contains(.bottomRight)){
                cornerMask.insert(.layerMaxXMaxYCorner)
            }
            self.layer.cornerRadius = radius
            self.layer.maskedCorners = cornerMask

        } else {
            let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.layer.mask = mask
        }
    }
}

extension UIViewController {
    
    var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    var topDistance: CGFloat {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.windows.first
            let bottomPadding = window?.safeAreaInsets.top ?? .zero
            return bottomPadding
        }
        return .zero
    }
    
    var navBarHeight: CGFloat {
        return self.navigationController?.navigationBar.frame.height ?? .zero
    }
    
    func isValid<T>(array: [T], index: Int) -> Bool {
        return index >= 0 && index < array.count
    }
    
    func handleCardState(cardHelper: BottomCardHelper) {
        if cardHelper.currentCardState == .collapsed {
            UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.9, options: .curveLinear, animations: {
                let frame = cardHelper.bottomCard.view.frame
                let y = self.screenHeight - cardHelper.cardHeight
                let newFrame = CGRect(x: 0, y: y, width: frame.width, height: cardHelper.cardHeight)
                cardHelper.bottomCard.view.frame = newFrame
                
                let subViewCount = self.view.subviews.count
                if self.isValid(array: self.view.subviews, index: subViewCount - 1) {
                    self.view.insertSubview(cardHelper.visualEffectView, at: subViewCount - 1)
                }
            })
            cardHelper.currentCardState = .expanded
        }else{
            UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.9, options: .curveEaseOut, animations: {                
                var newFrame = cardHelper.bottomCard.view.frame
                newFrame.origin.y = self.view.frame.size.height
                cardHelper.bottomCard.view.frame = newFrame
            })
            removeCard(cardHelper: cardHelper)
        }
    }
    
    func addCard(cardHelper: BottomCardHelper) {
        self.addChild(cardHelper.bottomCard)
        self.view.addSubview(cardHelper.bottomCard.view)
        cardHelper.bottomCard.didMove(toParent: self)
    }
    
    func removeCard(cardHelper: BottomCardHelper) {
        cardHelper.currentCardState = .collapsed
        willMove(toParent: nil)
        cardHelper.visualEffectView.removeFromSuperview()
        cardHelper.bottomCard.removeFromParent()
    }
}

extension UITextField {
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        done.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.systemBlue], for: .normal)
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        self.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction(){
        self.resignFirstResponder()
    }
}

extension UITextView {
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        done.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.systemBlue], for: .normal)
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        self.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction(){
        self.resignFirstResponder()
    }
}

extension String {
    func getFormattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd HH':'mm':'ss Z"

        guard let date = dateFormatter.date(from: self) else { return "_:_" }

        dateFormatter.dateFormat = "MMMM dd, YYYY HH:mm a"
        return dateFormatter.string(from: date)
    }
}

extension NSManagedObject {
    var primaryKey : String {
        guard objectID.uriRepresentation().lastPathComponent.count > 1 else { return "" }
        return objectID.uriRepresentation().lastPathComponent
    }
}
