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
    var charma = RealmOptional<Int>()
//    dynamic var user:User?
    var types = List<RealmString>()
    dynamic var state:String?
    dynamic var country:String?
    dynamic var city:String?
    
    override init(value: AnyObject) {
        let sighting = value as! PFObject
        let geopoint = sighting["location"] as! PFGeoPoint
        latitude = RealmOptional<Double>()
        latitude.value = geopoint.latitude
        longitude = RealmOptional<Double>()
        longitude.value = geopoint.longitude
        pokemon = RealmPokemon(value: sighting["pokemon"] as! Pokemon)
        charma = RealmOptional<Int>()
        charma.value = (sighting["charma"] as? NSNumber)?.integerValue
//        user = sighting["user"] as? User
        types.appendContentsOf((pokemon["types"] as! [String]).map{RealmString(value: $0)})
        state = sighting["state"] as? String
        country = sighting["country"] as? String
        city = sighting["city"] as? String

        super.init()
    }
    required init() {
        super.init()
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        fatalError("init(realm:schema:) has not been implemented")
    }
    
    
    
    required init(value: AnyObject, schema: RLMSchema) {
        fatalError("init(value:schema:) has not been implemented")
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

        types.appendContentsOf((pokemon["types"] as! [String]).map{RealmString(value: $0)})
        pid = pokemon["pid"] as? String
        sound = pokemon["sound"] as? String
        rarity.value = pokemon["rarity"] as? Int
        super.init()
    }
    required init() {
        super.init()
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        fatalError("init(realm:schema:) has not been implemented")
    }
    
    required init(value: AnyObject, schema: RLMSchema) {
        fatalError("init(value:schema:) has not been implemented")
    }

}


class RealmString:Object {
    dynamic var value:String?
    override init(value: AnyObject) {
        self.value = (value as! String)
        super.init(value: value)
    }
    required init() {
        super.init()
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        fatalError("init(realm:schema:) has not been implemented")
    }
    
    required init(value: AnyObject, schema: RLMSchema) {
        fatalError("init(value:schema:) has not been implemented")
    }

}