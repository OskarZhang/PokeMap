//
//  PopupNameView.swift
//  PokeMap
//
//  Created by Oskar Zhang on 7/17/16.
//  Copyright © 2016 OskarZhang. All rights reserved.
//

import Foundation
import UIKit
typealias PopupCompletion = (String?)->()
class PopupNameView:UIView,UITextFieldDelegate {
    @IBOutlet weak var nameField: UITextField!
    var action:PopupCompletion?
    static let LEADING_PADDING:CGFloat = 30
    static let HEIGHT:CGFloat = 210
    
    @IBOutlet weak var containerView: UIView!
    class func getView(name:String?,completion:PopupCompletion) -> PopupNameView {
        let popupView =  UINib(nibName: "PopupNameView", bundle: NSBundle.mainBundle()).instantiateWithOwner(self, options: nil).first as! PopupNameView
        popupView.action = completion
        popupView.nameField.text = name
        let screenWidth = UIScreen.mainScreen().bounds.width
        let screenHeight = UIScreen.mainScreen().bounds.height
        let frame = CGRect(x: LEADING_PADDING, y: 0, width: screenWidth - LEADING_PADDING*2, height: HEIGHT)
        popupView.frame = frame
        popupView.center = CGPoint(x: screenWidth/2, y: screenHeight/2 - 100)
        popupView.transform = CGAffineTransformMakeScale(0.1, 0.1)
        if popupView.nameField.text != nil {
            popupView.confirmButton.setTitle("Confirm", forState: .Normal)
        }
        UIApplication.sharedApplication().keyWindow?.addSubview(popupView)
        UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.2, options: .CurveEaseIn , animations: {
            popupView.transform = CGAffineTransformMakeScale(1, 1)
            
        }) { (finished) in
            UIView.animateWithDuration(1, animations: { () -> Void in
                popupView.transform = CGAffineTransformIdentity
            })
            popupView.nameField.becomeFirstResponder()
        }
        

        return popupView
    }
    
    
    @IBAction func didClickConfirm(sender: AnyObject) {
        if nameField.text != nil && nameField.text?.characters.count == 0 {
            action?(nil)
        } else {
            action?(nameField.text)
        }
        dismiss()
    }
    
    @IBOutlet weak var confirmButton: UIButton!
    override func awakeFromNib() {
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 4
        containerView.layer.borderColor = PMColor.CGColor
        confirmButton.setBackgroundImage(UIImage.fromColor(PMColor), forState: .Normal)
        confirmButton.layer.cornerRadius = 4
        confirmButton.clipsToBounds = true
        nameField.delegate = self
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let buffer = textField.text?.stringByAppendingString(string)
        if buffer?.characters.count == 1 {
            confirmButton.setTitle("Confirm", forState: .Normal)
        } else if buffer?.characters.count == 0{
            confirmButton.setTitle("No", forState: .Normal)
        }
        return true
    }
    
    func dismiss() {
        self.endEditing(true)
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.2, options: .CurveEaseOut , animations: {
            self.transform = CGAffineTransformMakeScale(0.01, 0.01)
        }) { (finished) in
            UIView.animateWithDuration(1, animations: { () -> Void in
                self.transform = CGAffineTransformIdentity
                self.removeFromSuperview()
            })
            
        }
    }
}