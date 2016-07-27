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
    static let TOP_PADDING:CGFloat = 200
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
    class func getView(name:String, charmaPoint:Int, withMessage:Bool,hasUpvoted:Bool,charmaAction:MarkerInfoViewCharmaAction) -> MarkerInfoView {
        let markerView =  UINib(nibName: "MarkerInfoView", bundle: NSBundle.mainBundle()).instantiateWithOwner(self, options: nil).first as! MarkerInfoView
        markerView.action = charmaAction
        markerView.withMessage = withMessage
        markerView.nameLabel.text = name
        markerView.messageLabel.text = "Press the charma button to thank \(name)"
        markerView.charmaPoint = charmaPoint
        markerView.charmaLabel.text = "\(charmaPoint) charma"
        markerView.messageHeight.constant = withMessage ? MESSAGE_HEIGHT : 0
        
        
        markerView.charmaButton.enabled = !hasUpvoted
        
        let screenWidth = UIScreen.mainScreen().bounds.width
        let frame = CGRect(x: LEADING_PADDING, y: -HEIGHT, width: screenWidth - LEADING_PADDING*2, height: HEIGHT)
        
        
        let configuredFrame = withMessage ? frame : CGRect(x: 0, y: MESSAGE_HEIGHT - frame.height, width: frame.width, height: frame.height - MESSAGE_HEIGHT)
        markerView.frame = configuredFrame
        markerView.center.x = screenWidth/2
        UIApplication.sharedApplication().keyWindow?.addSubview(markerView)
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: .CurveEaseIn , animations: {
            markerView.center.y = TOP_PADDING
            
        }) { (finished) in
        
        }
        
        return markerView
    }
    
    
    
    override func awakeFromNib() {
        self.nameLabel.adjustsFontSizeToFitWidth = true
        self.messageLabel.adjustsFontSizeToFitWidth = true
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 4
        containerView.layer.borderColor = PMColor.CGColor
        charmaButton.setBackgroundImage(UIImage(named:"CharmaUpvoted"), forState: .Disabled)
        charmaButton.setBackgroundImage(UIImage(named:"CharmaUpvoted"), forState: .Highlighted)
        
    }
    @IBAction func didClickCharma(sender: AnyObject) {
        action?()
        charmaPoint! += 1
        charmaButton.enabled = false
        let numberCharma = NSUserDefaults.standardUserDefaults().integerForKey("numberCharmaAdded") + 1
        
        NSUserDefaults.standardUserDefaults().setInteger(numberCharma, forKey: "numberCharmaAdded")
        self.charmaLabel.text = "\(charmaPoint) charma"
        
    }
    
    
    func dismiss() {
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: .CurveEaseIn , animations: {
            self.frame = CGRectMake(self.frame.origin.x, -self.frame.height, self.frame.width, self.frame.height)
        }) { (finished) in
            
        }
    }
    
    
    @IBAction func didClickCloseButton(sender: AnyObject) {
        dismiss()
    }
    
}