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
    func autocompletePokemonByName(keywords:String,page:Int,completion:([PFObject]!,NSError?)->()) {
        let pokemonQuery = Pokemon.query()!
//        pokemonQuery.whereKey("name", matchesRegex: keywords, modifiers: "i")
        pokemonQuery.whereKey("name", containsString: keywords.capitalizedString)
        pokemonQuery.limit = 20
        pokemonQuery.skip = 20 * page
        pokemonQuery.findObjectsInBackgroundWithBlock { (pokemons, error) in
            completion(pokemons,error)
        }
    }

    func addPokemon(pokemon:Pokemon,location:CLLocation,city:String,state:String,country:String,completion:(NSError?)->()) {
        let parseLocation = PFGeoPoint(location: location)
        let dict:Dictionary = ["pokemon":pokemon,"location":parseLocation,"state":state,"country":country,"city":city]
        let sighting = PFObject(className: "Sighting",dictionary: dict)
        sighting.saveInBackgroundWithBlock { (success, error) in
            completion(error)
        }
    }
    
    
    
}