//
//  FilterCoordinator.swift
//  PokeMap
//
//  Created by Oskar Zhang on 7/16/16.
//  Copyright © 2016 OskarZhang. All rights reserved.
//

import Foundation
import UIKit
class FilterCoordinator:NSObject {
    var filterVC:FilterViewController!
    weak var mainVC:MainMapViewController!
    
    init(mainVC:MainMapViewController) {
        super.init()
        self.mainVC = mainVC
        self.filterVC = UIStoryboard(name: "FilterScene", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("filterViewController") as! FilterViewController
        filterVC.coordinator = self
    }
    func showFilterView() {
        filterVC.modalPresentationStyle = .OverCurrentContext
        mainVC.turnOnBlur {
            self.mainVC.titleLabel.text = "Filter"
            self.mainVC.presentViewController(self.filterVC, animated: true, completion: nil)
        }
        
        
    }
    
    func dismissFilterView() {
        mainVC.titleLabel.text = nil
        mainVC.updateFilterButton()
        filterVC.dismissViewControllerAnimated(true) { 
            self.mainVC.turnOffBlur()
            self.mainVC.didUpdateFilter()
        }
    }
}