//
//  LocationManager.swift
//  PokeMap
//
//  Created by Oskar Zhang on 7/13/16.
//  Copyright © 2016 OskarZhang. All rights reserved.
//

import Foundation
import UIKit
import Parse
import CoreLocation
class LocationManager: NSObject,CLLocationManagerDelegate {
    static var sharedLocationManager = LocationManager()
    private var locationManager: CLLocationManager
    var currentLocation: CLLocation!
    
    override init() {
        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        super.init()
        locationManager.delegate = self
        
    }
    
    func startLocationRecording() {
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if ((UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0) {
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startUpdatingLocation()
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if currentLocation == nil {
            currentLocation = locations.first
            let notification = NSNotification(name: "didUpdateLocation", object: currentLocation)
            NSNotificationCenter.defaultCenter().postNotification(notification)
            
        }
        currentLocation = locations.first
        if UIApplication.sharedApplication().applicationState == .Inactive {
//            PMClient.sharedClient.getPokemonNearby(currentLocation.coordinate, range: 1, completion: { (sightings, error) in
//                for sighting in sightings {
//                    if sighting.pokemon!.name! != "Zubat" {
//                        let notification = UILocalNotification()
//                        notification.fireDate = NSDate(timeIntervalSinceNow: 5)
//                        notification.alertBody = "There is a \(sighting.pokemon!.name!) nearby!"
//                        UIApplication.sharedApplication().scheduleLocalNotification(notification)
//                    }
//                }
//            })
        }
    }
    
    func startMonitoringSignificantChanges(yes:Bool) {
        if yes {
            locationManager.startMonitoringSignificantLocationChanges()
        }
        else {
            locationManager.stopMonitoringSignificantLocationChanges()
            locationManager.startUpdatingLocation()
        }
    }
    
    static func locationToCityName(location:CLLocation,completion:((String,String,String)?,Bool)->Void)//magic
    {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            if error == nil {
                if let place = placemarks?.first {
                    let state = place.addressDictionary!["State"] as? String
                    let country = place.country
                    let locality = place.locality
    
                    if locality == nil && country == nil && state == nil {
                        completion(nil,false)
                    } else {
                        completion((locality!,state!,country!),true)
                    }
                }
                else {
                    completion(nil,false)
                }
                
            }
            else {
                completion(nil,false)
            }
        })
    }
    
    func subscribeToLocationChange(observer:AnyObject,selector:Selector) {
        NSNotificationCenter.defaultCenter().addObserver(observer, selector: selector, name: "didUpdateLocation", object: nil)
    }
    
    
    
}
