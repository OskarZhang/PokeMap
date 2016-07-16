//
//  PMClient.swift
//  PokeMap
//
//  Created by Oskar Zhang on 7/13/16.
//  Copyright © 2016 OskarZhang. All rights reserved.
//

import Foundation
import Parse
class PMClient {
    static var sharedClient: PMClient = PMClient()
    func getPokemonNearby(location:CLLocationCoordinate2D,range:Int,completion:([Sighting]!,NSError?)->()) {
        let sightingQuery = Sighting.query()!
        sightingQuery.includeKey("pokemon")
        let parseLocation = PFGeoPoint(latitude: location.latitude, longitude: location.longitude)
        sightingQuery.whereKey("location", nearGeoPoint: parseLocation, withinMiles: Double(range))
        sightingQuery.findObjectsInBackgroundWithBlock({ (sightings, error) in
            completion(sightings as? [Sighting],error)
        })
    }
    func autocompletePokemonByName(keywords:String,page:Int,completion:([Pokemon]!,NSError?)->()) {
        let pokemonQuery = Pokemon.query()!
        pokemonQuery.fromLocalDatastore()
        pokemonQuery.whereKey("name", containsString: keywords.capitalizedString)
        pokemonQuery.limit = 20
        pokemonQuery.skip = 20 * page
        if !NSUserDefaults.standardUserDefaults().boolForKey("hasCachedPokemons") {
            downloadPokemons()?.continueWithSuccessBlock({ (task) -> AnyObject? in
                pokemonQuery.findObjectsInBackgroundWithBlock { (pokemons, error) in
                    completion(pokemons as! [Pokemon],error)
                }
                return nil
            })
        } else {
            pokemonQuery.findObjectsInBackgroundWithBlock { (pokemons , error) in
                completion(pokemons as! [Pokemon],error)
            }
        }
    }

    func addPokemon(pokemon:Pokemon,location:CLLocation,city:String,state:String,country:String,completion:(NSError?)->()) {
        let parseLocation = PFGeoPoint(location: location)
        let user = PFUser.currentUser()
        let dict:Dictionary = ["pokemon":pokemon,"location":parseLocation,"state":state,"country":country,"city":city]
        let sighting = PFObject(className: "Sighting",dictionary: dict)
        sighting["user"] = user
        sighting.saveInBackgroundWithBlock { (success, error) in
            completion(error)
        }
    }
    
    func downloadPokemons() -> BFTask? {
        return Pokemon.query()?.findObjectsInBackground().continueWithBlock({ (task) -> AnyObject? in
            let pokemons = task.result as! [Pokemon]
            return PFObject.pinAllInBackground(pokemons)
        }).continueWithBlock({ (task) -> AnyObject? in
            if task.error == nil {
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: ("hasCachedPokemons"))
            }
            return nil
        })
    }
    
}