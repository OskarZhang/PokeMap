//
//  MarkerInfoView.swift
//  PokeMap
//
//  Created by Oskar Zhang on 7/17/16.
//  Copyright © 2016 OskarZhang. All rights reserved.
//

import Foundation
import UIKit

typealias MarkerInfoViewCharmaAction = ()->()
class MarkerInfoView:UIView {
    static let LEADING_PADDING:CGFloat = 30
    static let HEIGHT:CGFloat = 200
    
    @IBOutlet weak var containerView: UIView!
    
    
    static let MESSAGE_HEIGHT:CGFloat = 49
    var action:MarkerInfoViewCharmaAction?
    var withMessage:Bool!
    var charmaPoint:Int!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var messageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var charmaButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var charmaLabel: UILabel!
    class func getView(name:String, charmaPoint:Int, withMessage:Bool,charmaAction:MarkerInfoViewCharmaAction) -> MarkerInfoView {
        let markerView =  UINib(nibName: "MarkerInfoView", bundle: NSBundle.mainBundle()).instantiateWithOwner(self, options: nil).first as! MarkerInfoView
        markerView.action = charmaAction
        markerView.withMessage = withMessage
        markerView.nameLabel.text = name
        markerView.messageLabel.text = "Press the charma button to thank \(name)"
        markerView.charmaPoint = charmaPoint
        markerView.charmaLabel.text = "\(charmaPoint) charma"
        markerView.messageHeight.constant = withMessage ? MESSAGE_HEIGHT : 0

        
        
        
        let screenWidth = UIScreen.mainScreen().bounds.width
        let screenHeight = UIScreen.mainScreen().bounds.height
        let frame = CGRect(x: LEADING_PADDING, y: 0, width: screenWidth - LEADING_PADDING*2, height: HEIGHT)
        
        
        let configuredFrame = withMessage ? frame : CGRect(x: 0, y: 0, width: frame.width, height: frame.height - MESSAGE_HEIGHT)
        markerView.frame = configuredFrame
        
        markerView.center = CGPoint(x: screenWidth/2, y: screenHeight/2)
        markerView.transform = CGAffineTransformMakeScale(0.1, 0.1)
        UIApplication.sharedApplication().keyWindow?.addSubview(markerView)
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.2, options: .CurveEaseIn , animations: {
            markerView.transform = CGAffineTransformMakeScale(1, 1)
            
        }) { (finished) in
            UIView.animateWithDuration(1, animations: { () -> Void in
                markerView.transform = CGAffineTransformIdentity
            })
        }
        
        
        return markerView
    }
    
    
    
    override func awakeFromNib() {
        self.nameLabel.adjustsFontSizeToFitWidth = true
        self.messageLabel.adjustsFontSizeToFitWidth = true
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 4
        containerView.layer.borderColor = UIColor(red: 247/255, green: 156/255, blue: 29/255, alpha: 1).CGColor
//        charmaButton.setBackgroundImage(UIImage(named:""), forState: <#T##UIControlState#>)
    }
    @IBAction func didClickCharma(sender: AnyObject) {
        action?()
        charmaPoint! += 1
        
        self.charmaLabel.text = "\(charmaPoint) charma"
        
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

    
    @IBAction func didClickCloseButton(sender: AnyObject) {
        dismiss()
    }

}