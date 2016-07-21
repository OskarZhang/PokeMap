//
//  PopupView.swift
//  PokeMap
//
//  Created by Oskar Zhang on 7/13/16.
//  Copyright © 2016 OskarZhang. All rights reserved.
//

import Foundation
import UIKit
class PopupView:UIView {
    
    @IBOutlet weak var tipsLabel:UILabel!
    var tips:String!
    static let LEADING_PADDING:CGFloat = 30
    static let HEIGHT:CGFloat = 200
    class func showView(text:String) -> PopupView {
        let popupView =  UINib(nibName: "PopupView", bundle: NSBundle.mainBundle()).instantiateWithOwner(self, options: nil).first as! PopupView
        popupView.tipsLabel.text = text
        let screenWidth = UIScreen.mainScreen().bounds.width
        let screenHeight = UIScreen.mainScreen().bounds.height
        popupView.frame = CGRect(x: LEADING_PADDING, y: 0, width: screenWidth - LEADING_PADDING*2, height: HEIGHT)
        popupView.center = CGPoint(x: screenWidth/2, y: screenHeight/2)
        popupView.transform = CGAffineTransformMakeScale(0.1, 0.1)
        UIApplication.sharedApplication().keyWindow?.addSubview(popupView)
        UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.2, options: .CurveEaseIn , animations: {
            popupView.transform = CGAffineTransformMakeScale(1, 1)
            
        }) { (finished) in
            UIView.animateWithDuration(1, animations: { () -> Void in
                popupView.transform = CGAffineTransformIdentity
            })
        }
        
        
        return popupView
    }
    override func awakeFromNib() {
        tipsLabel.adjustsFontSizeToFitWidth = true
    }
    
    
    @IBAction func didClickGotIt(sender:UIButton) {
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