//
//  User.swift
//  PokeMap
//
//  Created by Oskar Zhang on 7/13/16.
//  Copyright © 2016 OskarZhang. All rights reserved.
//

import Foundation
import Parse


class User:PFUser {
    @NSManaged var team:String?
    @NSManaged var nickname:String?
    @NSManaged var charma:NSNumber?
    @NSManaged var location:PFGeoPoint?
    override class func initialize() {
        struct Static {
            static var onceToken: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    override static func query() -> PFQuery? {
        let query = super.query()
        return query
    }
}

class Pokemon: PFObject,PFSubclassing {
    @NSManaged var types:[String]?
    @NSManaged var name:String?
    @NSManaged var infos: NSArray?
    @NSManaged var rarity:NSNumber?
    @NSManaged var pid:String?
    @NSManaged var sound:String?
    static func parseClassName() -> String {
        return "Pokemon"
    }
    override class func initialize() {
        struct Static {
            static var onceToken: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    override static func query() -> PFQuery? {
        let query = super.query()
        
        return query
    }
}

class Sighting: PFObject,PFSubclassing {
    @NSManaged var location:PFGeoPoint?
    @NSManaged var pokemon:Pokemon?
    var hasUpvoted: Bool = false
    @NSManaged var charma:NSNumber?
    @NSManaged var user:User?
    @NSManaged var types:[String]?
    @NSManaged var state:String?
    @NSManaged var country:String?
    @NSManaged var city:String?
    static func parseClassName() -> String {
        return "Sighting"
    }
    override class func initialize() {
        
        struct Static {
            static var onceToken: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    override static func query() -> PFQuery? {
        let query = super.query()
        return query
    }
    
    static func getNearbyQuery(location:CLLocationCoordinate2D,range:Double) -> PFQuery {
        let sightingQuery = query()!
        sightingQuery.limit = 200
        sightingQuery.includeKey("pokemon")
        sightingQuery.includeKey("user")

        let parseLocation = PFGeoPoint(latitude: location.latitude, longitude: location.longitude)
        sightingQuery.whereKey("location", nearGeoPoint: parseLocation, withinKilometers : range)
        return sightingQuery
    }
    
    class func filterByTypes(types:[Type],sightings:[PFObject],pokemonsInSearch:[Pokemon]) ->[PFObject] {
        if types.count == 0 && pokemonsInSearch.count == 0 {
            return sightings
        }
        let typesStr = types.flatMap { (type) -> String in
            return type.name!
        }
        let typeSet = Set<String>(typesStr)
        return sightings.filter({ (sighting) -> Bool in
            let types = sighting["types"] as? [String]
            
            if types == nil {
                return false
            }
            
            //as! [String]
            
            var matchByType = false
            if typeSet.count > 0 {
                for poketype in types! {
                    if typeSet.contains(poketype as String) {
                        matchByType =  true
                    }
                }
            } else {
                matchByType = true
            }

            var matchByPokemon = false
            if pokemonsInSearch.count > 0 {
                if let pokemon = sighting["pokemon"] as? Pokemon where pokemonsInSearch.contains(pokemon) {
                    matchByPokemon = true
                }
            } else {
                matchByPokemon = true
            }
            
            return matchByType && matchByPokemon
        })
        
    }
}


class Type: PFObject,PFSubclassing {
    @NSManaged var name:String?
    @NSManaged var color:NSNumber?
    
    static func parseClassName() -> String {
        return "Type"
    }
    override class func initialize() {
        
        struct Static {
            static var onceToken: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    override static func query() -> PFQuery? {
        let query = super.query()
        return query
    }
}
