//
//  RaritySelectorView.xib.swift
//  PokeMap
//
//  Created by Oskar Zhang on 7/26/16.
//  Copyright © 2016 OskarZhang. All rights reserved.
//

import Foundation
import UIKit
class RaritySelectorView:UIView {
    static let LEADING_PADDING:CGFloat = 10
    static let HEIGHT:CGFloat = 100
    
    class func showView() {
        let view =  UINib(nibName: "RaritySelectorView", bundle: NSBundle.mainBundle()).instantiateWithOwner(self, options: nil).first as! RaritySelectorView
        
        let screenWidth = UIScreen.mainScreen().bounds.width
        let screenHeight = UIScreen.mainScreen().bounds.height
        let frame = CGRect(x: LEADING_PADDING, y: -HEIGHT, width: screenWidth - LEADING_PADDING*2, height: HEIGHT)
        
        view.frame = frame
        UIApplication.sharedApplication().keyWindow?.addSubview(view)
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.2, options: .CurveEaseIn , animations: {
            view.center = CGPoint(x: screenWidth/2, y: screenHeight/2)
        }) { (finished) in
        }
        
    }
}