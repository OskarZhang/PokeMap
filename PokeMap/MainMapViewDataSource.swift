//
//  MainMapViewDataSource.swift
//  PokeMap
//
//  Created by Oskar Zhang on 7/17/16.
//  Copyright © 2016 OskarZhang. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps

class MainMapViewControllerDataSource:NSObject {
    var markers:[GMSMarker] = []
    var allTimeSightings:[RealmSighting] = []
    var recentSightings:[RealmSighting] = []
    var recentFetchedAt:NSDate!
    var allTimeFetchedAt:NSDate!
    var realTimeMode:Bool = true
    weak var mapView:GMSMapView!
    var lastFetchedLocation:CLLocation!
    var dataFetchingDelegate:MainMapViewControllerDataFetchingDelegate?
    init(mapView:GMSMapView!) {
        self.mapView = mapView
    }
    
    var sightings:[RealmSighting]! {
        didSet {
            dataFetchingDelegate?.didFinishLoading()
            var toAdd:[RealmSighting] = []
            var toDelete:[RealmSighting] = []
            if oldValue != nil {
                let oldSet = Set(oldValue)
                let newSet = Set(sightings)
                toDelete = Array<RealmSighting>(oldSet.subtract(newSet))
                toAdd = Array<RealmSighting>(newSet.subtract(oldSet))
                
            } else {
                toAdd = sightings
            }
            
            markers = markers.filter { (marker) -> Bool in
                for removed in toDelete {
                    if (marker.userData as! RealmSighting) == removed {
                        marker.map = nil
                        return false
                    }
                }
                return true
            }
            
            for sighting in toAdd {
//                if let pokemon = sighting.pokemon {
                    let position = CLLocation(latitude: sighting.latitude.value!, longitude: sighting.longitude.value!).coordinate
                    let marker = GMSMarker(position: position)
                    marker.title = sighting.pokemon.sound ?? "Hey"
                    marker.userData = sighting
                    marker.icon = UIImage(named: sighting.pokemon.pid!)!.resize(CGSize(width: 40, height: 40))
                    marker.map = self.mapView
                    markers.append(marker)
//                }
            }
        }
    }
    
    func fetchPokemons(location:CLLocationCoordinate2D,zoomLevel:Int,modeSwitch:Bool) {
        let cllocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
//        if let lastLocation = lastFetchedLocation where cllocation.distanceFromLocation(lastLocation) <= 1000 && !modeSwitch {
//            return
//        }
        lastFetchedLocation = cllocation
        
        let nearLeft = mapView.projection.visibleRegion().nearLeft
        let farLeft = mapView.projection.visibleRegion().farLeft
        let farRight = mapView.projection.visibleRegion().farRight
        let nearRight = mapView.projection.visibleRegion().nearRight
        let longitudeRange = (nearLeft.longitude - nearRight.longitude)/2
        let latitudeRange = (farLeft.latitude - nearLeft.latitude)/2
        
        let minLat = min(nearLeft.latitude,nearRight.latitude,farLeft.latitude,farRight.latitude)
        let maxLat = max(nearLeft.latitude,nearRight.latitude,farLeft.latitude,farRight.latitude)
        let minLong = min(nearLeft.longitude,nearRight.longitude,farLeft.longitude,farRight.longitude)
        let maxLong = max(nearLeft.longitude,nearRight.longitude,farLeft.longitude,farRight.longitude)
        
        
        
//        let distance:Double = CLLocation(latitude: left.latitude, longitude: left.longitude).distanceFromLocation(CLLocation(latitude: right.latitude, longitude: right.longitude))/1000.00/2.00
        
        
        
        
        dataFetchingDelegate?.didStartLoading()
        if !realTimeMode {
            self.allTimeFetchedAt = NSDate()
            PMClient.sharedClient.getPokemonNearbyAllTime(location, range: (minLat,minLong,maxLat,maxLong), zoomLevel: mapView.camera.zoom, completion: { (sightings, error) in
                if error == nil {
                    self.allTimeSightings = sightings
                    self.updateViews()
                }
            })
            
        } else {
            self.recentFetchedAt = NSDate()
            recentSightings = []
            PMClient.sharedClient.getPokemonNearbyLive(location, range: (minLat,minLong,maxLat,maxLong), zoomLevel: mapView.camera.zoom, callback: { (sightings, error) in
                if error == nil {
                    self.recentSightings = sightings
                    self.updateViews()
                }
            })
        }
    }
 

    
    func switchMode() {
        realTimeMode = !realTimeMode
        mapView.clear()
        sightings = []
        fetchPokemons(mapView.camera.target, zoomLevel: Int(mapView.camera.zoom), modeSwitch: true)
    }

    func updateViews() {
        let allSightings = realTimeMode ? recentSightings : allTimeSightings
//        if PMClient.sharedClient.types.count == 0 && PMClient.sharedClient.pokemonInSearch.count == 0 {
//            sightings = allSightings
//        } else {
        
        if allSightings.count == 0 && realTimeMode {
            self.dataFetchingDelegate?.didFindNoData()
        }
        
        sightings = Sighting.filterByTypes(PMClient.sharedClient.types, allSightings, PMClient.sharedClient.pokemonInSearch, PMClient.sharedClient.rarityTargeted) //as! [RealmSighting]
        
    }
    
}

protocol MainMapViewControllerDataFetchingDelegate {
    func didFinishLoading()
    func didStartLoading()
    func didFindNoData()
}

