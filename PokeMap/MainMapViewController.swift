//
//  ViewController.swift
//  PokeMap
//
//  Created by Oskar Zhang on 7/13/16.
//  Copyright © 2016 OskarZhang. All rights reserved.
//

import UIKit
import GoogleMaps

var PMColor = UIColor(hex: 0xe74c3c)
class MainMapViewController: UIViewController,GMSMapViewDelegate {
    var mapView:GMSMapView!
    let BUTTON_WIDTH:CGFloat = 70
    let BUTTON_HEIGHT:CGFloat = 86
    let BUTTON_PADDING:CGFloat = 20
    let IMAGE_LEADING_PADDING:CGFloat = 50
    let IMAGE_TOP_PADDING:CGFloat = 42
    var button:UIButton = UIButton()
    var imageView = UIImageView()
    
    var blurView:UIVisualEffectView!
    
    var submissionCoordinator:SubmissionCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()
        configrueViews()
        LocationManager.sharedLocationManager.subscribeToLocationChange(self, selector: #selector(self.updateLocation))
        updateLocation()
        
        
    }
    
    func showWelcomeMessageIfNeeded() {
        if !NSUserDefaults.standardUserDefaults().boolForKey("hasShownWelcomeMessage") {
            PopupView.showView("Welcome to PokéMap! Move around to discover nearby pokémons.")
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "hasShownWelcomeMessage")
        }
    }
    override func viewDidAppear(animated: Bool) {
        showWelcomeMessageIfNeeded()
    }
    
    func configrueViews() {
        mapView = GMSMapView(frame: self.view.bounds)
        mapView.delegate = self
        self.view.addSubview(mapView)
        mapView.myLocationEnabled = true
        self.view.insertSubview(button, aboveSubview: mapView)
        button.setBackgroundImage(UIImage(named: "AddButton.png"), forState: .Normal)
        button.layer.cornerRadius = BUTTON_WIDTH/2
        button.titleLabel?.font = UIFont.systemFontOfSize(20)
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(self.initiateSubmission), forControlEvents: .TouchUpInside)
        self.view.addSubview(imageView)
        imageView.image = UIImage(named: "PokeMap.png")!
        imageView.contentMode = .ScaleAspectFit
        
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        self.blurView.alpha = 0
        self.view.insertSubview(blurView, belowSubview: imageView)
        NSLayoutConstraint.setupConstraint(blurView, rootview: self.view)
        self.view.backgroundColor = UIColor.clearColor()
        
        
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.frame = self.view.bounds
        button.frame = CGRect(x: self.view.frame.width - BUTTON_WIDTH - BUTTON_PADDING, y: self.view.frame.height - BUTTON_WIDTH - BUTTON_PADDING, width: BUTTON_WIDTH, height: BUTTON_HEIGHT)
        button.center.x = self.view.frame.width/2
        let width = UIScreen.mainScreen().bounds.width - IMAGE_LEADING_PADDING * 2
        imageView.frame = CGRect(x: IMAGE_LEADING_PADDING, y: IMAGE_TOP_PADDING, width: width, height: CGFloat(width/5.71))
    }
    var markers:[GMSMarker] = []
    var sightings:[Sighting]! {
        didSet {
            var newSightings:Array<Sighting> = []
            var toBeRemoved:[Sighting] = []
            if oldValue != nil {
                let oldSet = Set(oldValue)
                let newSet = Set(sightings)
                let union = newSet.union(oldSet)
                newSightings = Array<Sighting>(newSet.intersect(union))
                toBeRemoved = Array<Sighting>(oldSet.intersect(union))
                
            } else {
                newSightings = sightings
            }
            
            markers = markers.filter { (marker) -> Bool in
                for removed in toBeRemoved {
                    if (marker.userData as! Sighting).objectId == removed.objectId {
                        marker.map = nil
                        return false
                    }
                }
                return true
            }
            
            for sighting in newSightings {
                if let pokemon = sighting.pokemon {
                    let position = CLLocationCoordinate2D(latitude: sighting.location!.latitude,longitude: sighting.location!.longitude)
                    let marker = GMSMarker(position: position)
                    marker.title = pokemon.sound ?? "Hey"
                    marker.userData = sighting
                    marker.icon = UIImage(named: pokemon.pid!)!.resize(CGSize(width: 40, height: 40))//["pid"] as! String)!
                    marker.map = self.mapView
                    markers.append(marker)
                }
            }
            

            
        }
    }
    
    
    func mapView(mapView: GMSMapView, idleAtCameraPosition position: GMSCameraPosition) {
        PMClient.sharedClient.getPokemonNearby(mapView.camera.target, range: 100, completion: { (sightings, error) in
            if error == nil {
                self.sightings = sightings
            }
        })
        
    }
    
    func updateLocation() {
        if let location = LocationManager.sharedLocationManager.currentLocation {
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 13, bearing: 30, viewingAngle: 30);
        }
    }
    
    func initiateSubmission() {
        let logVC = UIStoryboard(name: "LogScene", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("logPokemonViewController") as! LogPokemonViewController
        let mapVC = UIStoryboard(name: "LogScene", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("logMapViewController") as! LogMapViewController
        submissionCoordinator = SubmissionCoordinator(mainVC: self, pokemonVC: logVC, mapVC: mapVC)
        submissionCoordinator?.startSubmission()
    }
    
    func turnOffBlur() {
        UIView.animateWithDuration(0.2, animations: {
            self.blurView.alpha = 0
        })
    }
    
    func turnOnBlur(completion:(()->())? = nil) {
        UIView.animateWithDuration(0.2, animations: {
            self.blurView.alpha = 1
        }) { success in
            if success {
                completion?()
            }
            
        }
    }


}

