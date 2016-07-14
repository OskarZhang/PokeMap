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
    class func loadView(text:String) -> PopupView {
        let retVal =  UINib(nibName: "PopupView", bundle: NSBundle.mainBundle()).instantiateWithOwner(self, options: nil).first as! PopupView
        retVal.tips = text
        return retVal
    }
    
    override func awakeFromNib() {
        tipsLabel.text = tips
    }
    
    @IBAction func didClickGotIt(sender:UIButton) {
        self.removeFromSuperview()
    }
}