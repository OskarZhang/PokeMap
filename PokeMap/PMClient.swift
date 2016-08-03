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
    
    
    func getPokemonNearby(location:CLLocationCoordinate2D,range:(Double,Double,Double,Double),zoomLevel:Float,live:Bool = false,completion:([RealmSighting]!,NSError?)->()) {
        let getPokemonNearby = {
            let currentTime = NSDate()
            self.latestGetPokemonTime = currentTime
            let realm = try! Realm()
            let minLat = range.0
            let minLong = range.1
            let maxLat = range.2
            let maxLong = range.3
            
            let min = CLLocation(latitude: minLat, longitude: minLong)
            let max = CLLocation(latitude: maxLat, longitude: maxLong)
            let distance = min.distanceFromLocation(max) / 1000 / 2
            
            let minLatpredicate = NSPredicate(format: "latitude >= %f", minLat)
            let maxLatpredicate = NSPredicate(format: "latitude <= %f", maxLat)
            let minLongpredicate = NSPredicate(format: "longitude >= %f", minLong)
            let maxLongpredicate = NSPredicate(format: "longitude <= %f", maxLong)
            
//            let predicate = NSCompoundPredicate.init(andPredicateWithSubpredicates: [minLatpredicate,maxLatpredicate,minLongpredicate,maxLongpredicate])
//            
//            var cachedObjects = realm.objects(RealmSighting.self).filter(predicate)
//            if cachedObjects.count >= 100  && !live {
//                var res:[RealmSighting] = []
//                for i in 0..<100 {
//                    res.append(cachedObjects[i])
//                }
//                let newPredicate = self.detectCluster(&res,zoom: zoomLevel)
//                //block cluster area, requery
//                let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate,newPredicate])
//                cachedObjects = realm.objects(RealmSighting.self).filter(compoundPredicate)
//                    if cachedObjects.count > 0 {
//                    res = []
//                    for i in 0..<cachedObjects.count - 1 {
//                        res.append(cachedObjects[i])
//                    }
//                }
//                completion(res,nil)
//                return
//            }
//            
            let sightingQuery = Sighting.getNearbyQuery(location, range: distance)
            if live {
                sightingQuery.whereKey("createdAt", greaterThan: NSDate().dateByAddingTimeInterval(-60*30))
            }
            
            sightingQuery.findObjectsInBackgroundWithBlock({ (sightings, error) in
                
                
                if (self.latestGetPokemonTime == currentTime && sightings != nil) {
                    var cached = sightings!.map {
                        RealmSighting(value: $0)
                    }
                    self.detectCluster(&cached,zoom: zoomLevel)
                    
                    completion(cached,error)
                    try! realm.write({
                        realm.add(cached)
                    })
                    
                    }
                })
            
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
    
    
    func detectCluster(inout sightings:[RealmSighting],zoom:Float) -> NSPredicate {
        let clusterItems = sightings.enumerate().map{ (index,element) in ClusterItem(position: CLLocationCoordinate2D(latitude: element.latitude.underlyingValue as! Double, longitude: element.longitude.underlyingValue as! Double), index: index)}
        let algo = GMUGridBasedClusterAlgorithm()
        algo.addItems(clusterItems)
        let clusters = algo.clustersAtZoom(zoom)
        var predicate:[NSPredicate] = []
        var newSightings:[RealmSighting] = []
        for cluster in clusters
        {
            if cluster.count >= 10 {
                print("pos : \(cluster.position) ")
                let lats = cluster.items.map {$0.position.latitude}
                let maxLat = lats.maxElement()
                let minLat = lats.minElement()
                let lons = cluster.items.map {$0.position.longitude}
                let maxLon = lons.maxElement()
                let minLon = lons.minElement()
                
                
                print("minX \(minLat)")
                print("maxX \(maxLat)")
                print("minY \(minLon)")
                print("maxY \(maxLon)")
                let minLatpredicate = NSPredicate(format: "latitude <= %f", minLat!)
                let maxLatpredicate = NSPredicate(format: "latitude >= %f", maxLat!)
                let minLongpredicate = NSPredicate(format: "longitude <= %f", minLon!)
                let maxLongpredicate = NSPredicate(format: "longitude >= %f", maxLon!)
                
                let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [minLatpredicate,maxLatpredicate,minLongpredicate,maxLongpredicate])
                predicate.append(compound)
                
                //clean
                for i in 1..<10 /**(cluster.items as! [ClusterItem])**/ {
                    let index = (cluster.items[i] as! ClusterItem).index
                    newSightings.append(sightings[index])
                }
            }
            
        }
        sightings = newSightings
        return NSCompoundPredicate(orPredicateWithSubpredicates: predicate)
    }
    
    
    func getPokemonNearbyAllTime(location:CLLocationCoordinate2D,range:(Double,Double,Double,Double),zoomLevel:Float,completion:([RealmSighting]!,NSError?)->()) {
        livemodeTimer?.invalidate()
        timerInfo = nil
        getPokemonNearby(location, range: range, zoomLevel: zoomLevel,completion: completion)
    }
    
    var completedLoadingLiveMode:Bool = true
    func getPokemonNearbyLive(location:CLLocationCoordinate2D,range:(Double,Double,Double,Double),zoomLevel:Float,callback:([RealmSighting]!,NSError?)->()) {
        livemodeTimer?.invalidate()
        let injectedCallback:([RealmSighting]!,NSError?)->() = {
            (sightings,error) in
            self.completedLoadingLiveMode = true
            callback(sightings,error)
        }
        timerInfo = LiveModeData(location: location, range: range, zoomLevel: zoomLevel ,callback: injectedCallback)
        livemodeTimer = NSTimer.scheduledTimerWithTimeInterval(7, target: self, selector: #selector(self.handleLiveModeTimer), userInfo: nil, repeats: true)
        handleLiveModeTimer()
    }
    
    @objc func handleLiveModeTimer() {
        if completedLoadingLiveMode {
            completedLoadingLiveMode = false
            getPokemonNearby(timerInfo!.location, range: timerInfo!.range, zoomLevel: timerInfo!.zoomLevel, live:true, completion: timerInfo!.callback)
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

class ClusterItem: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var index:Int
    init(position: CLLocationCoordinate2D,index:Int) {
        self.position = position
        self.index = index
    }
}


struct LiveModeData {
    var location:CLLocationCoordinate2D
    var range:(Double,Double,Double,Double)
    var zoomLevel:Float
    var callback:([RealmSighting]!,NSError?)->()
}