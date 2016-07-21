//
//  FilterCoordinator.swift
//  PokeMap
//
//  Created by Oskar Zhang on 7/16/16.
//  Copyright © 2016 OskarZhang. All rights reserved.
//

import Foundation
import UIKit
class SearchCoordinator:NSObject {
    var searchVC:PokemonSearchViewController!
    weak var mainVC:MainMapViewController!
    
    init(mainVC:MainMapViewController) {
        super.init()
        self.mainVC = mainVC
        self.searchVC = UIStoryboard(name: "SearchScene", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("pokemonSearchViewController") as! PokemonSearchViewController
        searchVC.coordinator = self
    }
    func showSearchView() {
        searchVC.modalPresentationStyle = .OverCurrentContext
        mainVC.turnOnBlur {
            self.mainVC.titleLabel.text = "Search"
            self.mainVC.presentViewController(self.searchVC, animated: true, completion: nil)
        }
        
    }
    
    func dismissSearchView() {
        mainVC.titleLabel.text = nil
        mainVC.updateSearchButton()
        searchVC.dismissViewControllerAnimated(true) {
            self.mainVC.turnOffBlur()
            self.mainVC.didUpdateFilter()
        }
    }
}