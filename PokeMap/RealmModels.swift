//
//  RealmModels.swift
//  PokeMap
//
//  Created by Oskar Zhang on 7/27/16.
//  Copyright © 2016 OskarZhang. All rights reserved.
//

import Foundation
import RealmSwift
import Realm
import CoreLocation
import Parse
class RealmSighting:Object {
    
    var latitude = RealmOptional<Double>()
    var longitude = RealmOptional<Double>()
    dynamic var pokemon:RealmPokemon!
    dynamic var hasUpvoted: Bool = false
    dynamic var charma = 0
    var types = List<RealmString>()
    dynamic var state:String?
    dynamic var country:String?
    dynamic var city:String?
    dynamic var fetchedAt = NSDate()
    dynamic var expirationTime:NSDate?
    dynamic var id:String?
    dynamic var name:String?
    
    override init(value: AnyObject) {
        let sighting = value as! PFObject
        let geopoint = sighting["location"] as! PFGeoPoint
        latitude.value = geopoint.latitude
        longitude.value = geopoint.longitude
        pokemon = RealmPokemon(value: sighting["pokemon"] as! Pokemon)
        charma = (sighting["charma"] as? NSNumber)?.integerValue ?? 0 
        name = (sighting["user"] as? User)?.nickname
        id = sighting.objectId!
        types.appendContentsOf(pokemon.types)
        expirationTime = sighting["expirationTime"] as? NSDate
        state = sighting["state"] as? String
        country = sighting["country"] as? String
        city = sighting["city"] as? String
        

        super.init()
    }
    required init() {
        super.init()
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    
    
    required init(value: AnyObject, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
}


class RealmPokemon: Object {
    var types = List<RealmString>()
    dynamic var name:String?
    var rarity = RealmOptional<Int>()
    dynamic var pid:String?
    dynamic var sound:String?
    override init(value: AnyObject) {
        let pokemon = value as! PFObject
        if let typesStr = pokemon["types"] as? [String] {
            types.appendContentsOf(typesStr.map{ RealmString(value: ["value":$0])})
        }
        pid = pokemon["pid"] as? String
        sound = pokemon["sound"] as? String
        rarity.value = pokemon["rarity"] as? Int
        super.init()
    }
    required init() {
        super.init()
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    required init(value: AnyObject, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }

}


class RealmString:Object {
    dynamic var value:String?


}