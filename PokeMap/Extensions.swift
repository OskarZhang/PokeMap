//
//  Extensions.swift
//  Pokemap
//
//  Created by Oskar Zhang on 2/22/16.
//  Copyright © 2016 Pokemap. All rights reserved.
//

import Foundation
import UIKit
extension UIImage {
    static func fromColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    func resize (sizeChange:CGSize)-> UIImage{
        
        let hasAlpha = true
        let scale: CGFloat = 0.0 // Use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        self.drawInRect(CGRect(origin: CGPointZero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage
    }
}

extension UITableView {
    func reloadData(animated: Bool) {
        if animated {
            self.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
            
        }
        else {
            self.reloadData()
        }
    }
}


extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue = CGFloat((hex & 0xFF)) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}



extension NSLayoutConstraint{
    static func setupConstraint(subview:UIView, rootview:UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        rootview.addConstraint(NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: rootview, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0))
        rootview.addConstraint(NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: rootview, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0))
        rootview.addConstraint(NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: rootview, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        rootview.addConstraint(NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: rootview, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
    }
}

func debounce( delay:NSTimeInterval, queue:dispatch_queue_t, action: (()->()) ) -> ()->() {
    
    var lastFireTime:dispatch_time_t = 0
    let dispatchDelay = Int64(delay * Double(NSEC_PER_SEC))
    
    return {
        lastFireTime = dispatch_time(DISPATCH_TIME_NOW,0)
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                dispatchDelay
            ),
            queue) {
                let now = dispatch_time(DISPATCH_TIME_NOW,0)
                let when = dispatch_time(lastFireTime, dispatchDelay)
                if now >= when {
                    action()
                }
        }
    }
}


