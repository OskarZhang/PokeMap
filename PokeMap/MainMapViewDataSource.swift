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
    var allTimeSightings:[Sighting] = []
    var recentSightings:[Sighting] = []
    var recentFetchedAt:NSDate!
    var allTimeFetchedAt:NSDate!
    var realTimeSocket:Subscription<Sighting>!
    var realTimeMode:Bool = true
    weak var mapView:GMSMapView!
    var lastFetchedLocation:CLLocation!
    
    init(mapView:GMSMapView!) {
        self.mapView = mapView
    }
    
    var sightings:[Sighting]! {
        didSet {
            var toAdd:[Sighting] = []
            var toDelete:[Sighting] = []
            if oldValue != nil {
                let oldSet = Set(oldValue)
                let newSet = Set(sightings)
                toDelete = Array<Sighting>(oldSet.subtract(newSet))
                toAdd = Array<Sighting>(newSet.subtract(oldSet))
                
                
            } else {
                toAdd = sightings
            }
            
            print("new: \(sightings.count)")
            print("old: \(oldValue == nil ? 0 : oldValue.count)")
            
            print("sets:")
            print(toAdd.count)
            print(toDelete.count)
            
            
            print("Camera Zoom:\(mapView.camera.zoom * 5)")
            markers = markers.filter { (marker) -> Bool in
                for removed in toDelete {
                    if (marker.userData as! Sighting).objectId == removed.objectId {
                        marker.map = nil
                        return false
                    }
                }
                return true
            }
            
            for sighting in toAdd {
                if let pokemon = sighting.pokemon {
                    let position = CLLocationCoordinate2D(latitude: sighting.location!.latitude,longitude: sighting.location!.longitude)
                    let marker = GMSMarker(position: position)
                    marker.title = pokemon.sound ?? "Hey"
                    marker.userData = sighting
                    marker.icon = UIImage(named: pokemon.pid!)!.resize(CGSize(width: 40, height: 40))
                    marker.map = self.mapView
                    markers.append(marker)
                }
            }
        }
    }
    
    func fetchPokemons(location:CLLocationCoordinate2D,zoomLevel:Int,modeSwitch:Bool) {
        let cllocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        if let lastLocation = lastFetchedLocation where cllocation.distanceFromLocation(lastLocation) <= 1000 && !modeSwitch {
            return
        }
        lastFetchedLocation = cllocation
        
        let left = mapView.projection.visibleRegion().nearLeft
        let right = mapView.projection.visibleRegion().nearRight
        let distance:Double = CLLocation(latitude: left.latitude, longitude: left.longitude).distanceFromLocation(CLLocation(latitude: right.latitude, longitude: right.longitude))/1000/2
        
        if !realTimeMode {
            self.allTimeFetchedAt = NSDate()
            PMClient.sharedClient.getPokemonNearby(location, range: distance, completion: { (sightings, error) in
                if error == nil {
                    self.allTimeSightings = sightings
                    self.updateViews()
                }
            })
            
            
        } else {
            self.recentFetchedAt = NSDate()
            recentSightings = []
            PMClient.sharedClient.getPokemonNearbyLive(location, range: distance, callback: { (sightings, error) in
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
        //        if recentFetchedAt != nil && allTimeFetchedAt != nil {
        //            if (realTimeMode && recentFetchedAt?.compare(allTimeFetchedAt) == .OrderedAscending) ||
        //                (!realTimeMode && allTimeFetchedAt.compare(recentFetchedAt) == .OrderedAscending) {
        //                updateViews()
        //                return
        //            }
        //        }
        fetchPokemons(mapView.camera.target, zoomLevel: Int(mapView.camera.zoom), modeSwitch: true)
    }
    
    func updateViews() {
        sightings = realTimeMode ? recentSightings : allTimeSightings
    }
    
}

