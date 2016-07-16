//
//  ViewCoordinator.swift
//  PokeMap
//
//  Created by Oskar Zhang on 7/14/16.
//  Copyright © 2016 OskarZhang. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
class SubmissionCoordinator:NSObject {
    weak var mainVC:MainMapViewController!
    var pokemonVC:LogPokemonViewController!
    var mapVC:LogMapViewController!
    var pokemonSelected:Pokemon!
    var locationSelected:CLLocation!
    var city:String!
    var state:String!
    var country:String!
    init(mainVC:MainMapViewController,pokemonVC:LogPokemonViewController,mapVC:LogMapViewController) {
        super.init()
        self.mainVC = mainVC
        self.pokemonVC = pokemonVC
        self.mapVC = mapVC
        pokemonVC.submissionCoordinator = self
        mapVC.submissionCoordinator = self
    }
    func moveToLocationVC(pokemon:Pokemon) {
        pokemonVC.view.endEditing(true)
        pokemonVC.dismissViewControllerAnimated(true) {
            self.mapVC.modalPresentationStyle = .OverCurrentContext
            self.pokemonSelected = pokemon
            let fileName = "\(pokemon.pid!)"
            self.mapVC.pokemonIcon = UIImage(named: fileName)
            self.mainVC.presentViewController(self.mapVC, animated: true, completion: nil)
        }
    }
    func dismissLocationVC() {
        
        mapVC.dismissViewControllerAnimated(true, completion: {
            self.mainVC.turnOffBlur()
        })
    }
    func finishSubmission(location:CLLocation) {
        locationSelected = location
        LocationManager.locationToCityName(location) {
            locationNames, success in
            if success {
                self.city = locationNames!.0
                self.state = locationNames!.1
                self.country = locationNames!.2
                PMClient.sharedClient.addPokemon(self.pokemonSelected, location: self.locationSelected, city: self.city, state: self.state, country: self.country, completion: { (error) in
                    if error == nil {
                        self.dismissLocationVC()
                    }
                })
            }
        }
    }
    
    func startSubmission() {
        pokemonVC.modalPresentationStyle = .OverCurrentContext
        mainVC.turnOnBlur { 
            self.mainVC.presentViewController(self.pokemonVC, animated: true, completion: nil)
        }
    }
    
    func dismissViewController(viewController:UIViewController) {
    
        viewController.dismissViewControllerAnimated(true, completion: {
            self.mainVC.turnOffBlur()
        })
    }
    
}