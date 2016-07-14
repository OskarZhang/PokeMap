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
    @NSManaged var types:PFRelation?
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
    @NSManaged var user:User?
    @NSManaged var types:PFRelation?
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
}


class Type: PFObject,PFSubclassing {
    @NSManaged var name:String?
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
