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
    class func getView(name:String, charmaPoint:Int, withMessage:Bool,frame:CGRect,charmaAction:MarkerInfoViewCharmaAction) -> MarkerInfoView {
        let markerView =  UINib(nibName: "MarkerInfoView", bundle: NSBundle.mainBundle()).instantiateWithOwner(self, options: nil).first as! MarkerInfoView
        markerView.action = charmaAction
        markerView.withMessage = withMessage
        markerView.nameLabel.text = name
        markerView.messageLabel.text = "Press the charma button to thank \(name)"
        markerView.charmaPoint = charmaPoint
        markerView.charmaLabel.text = "\(charmaPoint) charma"
        markerView.messageHeight.constant = withMessage ? MESSAGE_HEIGHT : 0

        
        let configuredFrame = withMessage ? frame : CGRect(x: 0, y: 0, width: frame.width, height: frame.height - MESSAGE_HEIGHT)
        markerView.frame = configuredFrame
        return markerView
    }
    
    
    override func awakeFromNib() {
        self.nameLabel.adjustsFontSizeToFitWidth = true
        self.messageLabel.adjustsFontSizeToFitWidth = true
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 4
        containerView.layer.borderColor = UIColor(red: 247/255, green: 156/255, blue: 29/255, alpha: 1).CGColor
//        self.messageHeight.constant = withMessage! ? MESSAGE_HEIGHT : 0
    }
    @IBAction func didClickCharma(sender: AnyObject) {
        self.charmaLabel.text = "\(charmaPoint) charma"
        action?()
    }
    

}