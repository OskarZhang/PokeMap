//
//  PMClient.swift
//  PokeMap
//
//  Created by Oskar Zhang on 7/13/16.
//  Copyright © 2016 OskarZhang. All rights reserved.
//

import Foundation
import Parse
import CoreLocation
import RealmSwift
import Realm
class PMClient {
    static var sharedClient: PMClient = PMClient()
    var types:[Type] = []
    var latestGetPokemonTime:NSDate!
    var rarityTargeted:Int = 0
    var livemodeTimer:NSTimer?
    var timerInfo:LiveModeData?
    var pokemonInSearch:[Pokemon] = [] {
        didSet {
            print("pokemon set")
        }
    }
    var filterApplied:Bool {
        get {
            return types.count > 0
        }
    }
    
    func getPokemonNearby(location:CLLocationCoordinate2D,range:Double,live:Bool = false,completion:([RealmSighting]!,NSError?)->()) {
        let getPokemonNearby = {
            let currentTime = NSDate()
            self.latestGetPokemonTime = currentTime
            let sightingQuery = Sighting.getNearbyQuery(location, range: range)
            
            if live {
                sightingQuery.whereKey("createdAt", greaterThan: NSDate().dateByAddingTimeInterval(-60*30))
            }
            let realm = try! Realm()

            let currentLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            let predicate = NSPredicate(block: { (sighting, binding) -> Bool in
                    let latitude = (sighting as! RealmSighting).latitude.value!
                    let longitude = (sighting as! RealmSighting).longitude.value!
                    let newLocation = CLLocation(latitude: latitude, longitude: longitude)
                    return newLocation.distanceFromLocation(currentLocation) <= range
            })

            let cachedObjects = realm.objects(RealmSighting.self).filter("latitude")
            if cachedObjects.count > 0 {
                completion(Array(cachedObjects),nil)
                return
            }
            sightingQuery.findObjectsInBackgroundWithBlock({ (sightings, error) in
                
                if (self.latestGetPokemonTime == currentTime && sightings != nil) {
                    let cached = sightings!.map {
                        RealmSighting(value: $0)
                    }
                    completion(cached,error)
                    try! realm.write({
                        realm.add(cached)
                    })
                    
                    }
                })
//                return nil
//            })
            
        }

        if !NSUserDefaults.standardUserDefaults().boolForKey("hasCachedPokemons") {
            downloadPokemons()?.continueWithBlock({ (task) -> AnyObject? in
                getPokemonNearby()
                return nil
            })
        } else {
            getPokemonNearby()
        }
    }
    
    
    
    func getPokemonNearbyAllTime(location:CLLocationCoordinate2D,range:Double,completion:([RealmSighting]!,NSError?)->()) {
        livemodeTimer?.invalidate()
        timerInfo = nil
        getPokemonNearby(location, range: range, completion: completion)
    }
    
    var completedLoadingLiveMode:Bool = true
    func getPokemonNearbyLive(location:CLLocationCoordinate2D,range:Double,callback:([RealmSighting]!,NSError?)->()) {
        livemodeTimer?.invalidate()
        let injectedCallback:([RealmSighting]!,NSError?)->() = {
            (sightings,error) in
            self.completedLoadingLiveMode = true
            callback(sightings,error)
        }
        timerInfo = LiveModeData(location: location, range: range, callback: injectedCallback)
        livemodeTimer = NSTimer.scheduledTimerWithTimeInterval(7, target: self, selector: #selector(self.handleLiveModeTimer), userInfo: nil, repeats: true)
        handleLiveModeTimer()
    }
    
    @objc func handleLiveModeTimer() {
        if completedLoadingLiveMode {
            completedLoadingLiveMode = false
            getPokemonNearby(timerInfo!.location, range: timerInfo!.range, live:true, completion: timerInfo!.callback)
        }
    }
    
    
    func autocompletePokemonByName(keywords:String?,page:Int,completion:([Pokemon]!,NSError?)->()) {
        let pokemonQuery = Pokemon.query()!
        pokemonQuery.fromLocalDatastore()
        pokemonQuery.addAscendingOrder("name")
        if let keywords = keywords {
            pokemonQuery.whereKey("name", containsString: keywords.capitalizedString)
        }
        pokemonQuery.limit = 100
        
        if !NSUserDefaults.standardUserDefaults().boolForKey("hasCachedPokemons") {
            downloadPokemons()?.continueWithSuccessBlock({ (task) -> AnyObject? in
                pokemonQuery.findObjectsInBackgroundWithBlock { (pokemons, error) in
                    completion(pokemons as! [Pokemon],error)
                }
                return nil
            })
        } else {

            pokemonQuery.findObjectsInBackgroundWithBlock { (pokemons, error) in
                completion(pokemons as! [Pokemon],error)
            }
            
        }

    }
    
    
    
    func applySearches(pokemon:Pokemon) {
        pokemonInSearch = [pokemon]
    }
    
    func applyRarity(rarity:Int){
        rarityTargeted = rarity
    }
    
    
    func getTypes(completion:([Type],[Type],NSError?)->Void) {
        let typesQuery = Type.query()!
        typesQuery.fromLocalDatastore()
        typesQuery.addAscendingOrder("name")
        if !NSUserDefaults.standardUserDefaults().boolForKey("hasCachedTypes") {
            downloadTypes()?.continueWithSuccessBlock({ (task) -> AnyObject? in
                typesQuery.findObjectsInBackgroundWithBlock { (objects, error) in
                    completion(objects as! [Type],self.types,error)
                }
                return nil
            })
        } else {
            typesQuery.findObjectsInBackgroundWithBlock { (objects , error) in
                completion(objects as! [Type],self.types,error)
            }
        }
    }
    
    func addPokemon(pokemon:Pokemon,location:CLLocation,city:String?,state:String?,country:String?,name:String? = nil,completion:(NSError?)->()) {
        let parseLocation = PFGeoPoint(location: location)
        let user = PFUser.currentUser() as! User
        var dict:[String:AnyObject] = ["pokemon":pokemon,"location":parseLocation]
        if let state = state {
            dict["state"] = state
        }
        if let city = city {
            dict["city"] = city
        }
        if let country = country {
            dict["country"] = country
        }
        
        let sighting = PFObject(className: "Sighting",dictionary: dict)
        
        sighting["user"] = user
        sighting["types"] = pokemon["types"]
        user.nickname = name
        user.saveInBackground()
        sighting.saveInBackgroundWithBlock { (success, error) in
            completion(error)
        }
    }
    
    func downloadPokemons() -> BFTask? {
        let query = Pokemon.query()!
        query.limit = 200
        return query.findObjectsInBackground().continueWithBlock({ (task) -> AnyObject? in
            let pokemons = task.result as! [Pokemon]
            return PFObject.pinAllInBackground(pokemons)
        }).continueWithBlock({ (task) -> AnyObject? in
            if task.error == nil {
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: ("hasCachedPokemons"))
                
            }
            return nil
        })
    }
    
    func downloadTypes() -> BFTask? {
        return Type.query()?.findObjectsInBackground().continueWithBlock({ (task) -> AnyObject? in
            let types = task.result as! [Type]
            return PFObject.pinAllInBackground(types)
        }).continueWithBlock({ (task) -> AnyObject? in
            if task.error == nil {
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: ("hasCachedTypess"))
            }
            return nil
        })
    }
    
    func applyFilters(types:[Type]!) {
        self.types = types
    }
    
    func updateUserLocation(location:CLLocation) {
        let user = PFUser.currentUser() as? User
        user?.location = PFGeoPoint(location: location)
        user?.saveInBackground()
    }
    
}


struct LiveModeData {
    var location:CLLocationCoordinate2D
    var range:Double
    var callback:([RealmSighting]!,NSError?)->()
}