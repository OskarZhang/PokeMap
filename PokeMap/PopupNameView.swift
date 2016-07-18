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
class PopupNameView:UIView {
    @IBOutlet weak var nameField: UITextField!
    var action:PopupCompletion?
    static let LEADING_PADDING:CGFloat = 30
    static let HEIGHT:CGFloat = 200
    
    class func getView(completion:PopupCompletion) -> PopupNameView {
        let popupView =  UINib(nibName: "PopupNameView", bundle: NSBundle.mainBundle()).instantiateWithOwner(self, options: nil).first as! PopupNameView
        popupView.action = completion
        
        let screenWidth = UIScreen.mainScreen().bounds.width
        let screenHeight = UIScreen.mainScreen().bounds.height
        let frame = CGRect(x: LEADING_PADDING, y: 0, width: screenWidth - LEADING_PADDING*2, height: HEIGHT)
        popupView.frame = frame
        popupView.center = CGPoint(x: screenWidth/2, y: screenHeight/2)
        popupView.transform = CGAffineTransformMakeScale(0.1, 0.1)
        UIApplication.sharedApplication().keyWindow?.addSubview(popupView)
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.2, options: .CurveEaseIn , animations: {
            popupView.transform = CGAffineTransformMakeScale(1, 1)
            
        }) { (finished) in
            UIView.animateWithDuration(1, animations: { () -> Void in
                popupView.transform = CGAffineTransformIdentity
            })
        }
        
        
        return popupView
    }
    
    
    @IBAction func didClickConfirm(sender: AnyObject) {
        action?(nameField.text)
        dismiss()
    }
    
    func dismiss() {
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