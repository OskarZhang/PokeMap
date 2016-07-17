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
    let ADD_BUTTON_WIDTH:CGFloat = 80
    let ADD_BUTTON_HEIGHT:CGFloat = 80 * 1.21
    let ADD_BUTTON_PADDING:CGFloat = 40
    let HOME_BUTTON_LEADING_PADDING:CGFloat = 20
    let HOME_BUTTON_TOP_PADDING:CGFloat = 30
    let HOME_BUTTON_WIDTH:CGFloat = 65
    let MODE_BUTTON_LEADING_PADDING:CGFloat = 20
    let MODE_BUTTON_WIDTH:CGFloat = 80
    let MODE_BUTTON_BOTTOM_PADDING:CGFloat = 40
    
    let FILTER_BUTTON_TRAILING_PADDING:CGFloat = 20
    let FILTER_BUTTON_WIDTH:CGFloat = 80
    let FILTER_BUTTON_BOTTOM_PADDING:CGFloat = 40
    
    var LABEL_PADDING:CGFloat = 10
    var LABEL_TRAILING_PADDING:CGFloat = 110 //because of filter apply button
    
    
    
    var titleLabel = UILabel()
    
    var addButton:UIButton = UIButton()
    var homeButton = UIButton()
    var filterButton = UIButton()
    var modeSwitchButton = UIButton()
    var blurView:UIVisualEffectView!
    var dataSource:MainMapViewControllerDataSource?
    var submissionCoordinator:SubmissionCoordinator?
    var filterCoordinator:FilterCoordinator?
    override func viewDidLoad() {
        super.viewDidLoad()
        configrueViews()
        LocationManager.sharedLocationManager.subscribeToLocationChange(self, selector: #selector(self.updateLocation))
        updateLocation()
        dataSource = MainMapViewControllerDataSource(mapView: self.mapView)
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
        mapView.myLocationEnabled = true
        
        modeSwitchButton.addTarget(self, action: #selector(self.didClickSwitchMode), forControlEvents: .TouchUpInside)
        modeSwitchButton.setBackgroundImage(UIImage(named: "Live Button")!, forState: .Normal)
        modeSwitchButton.setBackgroundImage(UIImage(named: "Live Button Off")!, forState: .Selected)
        
        
        addButton.imageView?.contentMode = .ScaleAspectFit
        addButton.setBackgroundImage(UIImage(named: "AddButtonNeutral"), forState: .Normal)
        addButton.setBackgroundImage(UIImage(named: "AddButtonPressed"), forState: .Highlighted)
        addButton.addTarget(self, action: #selector(self.initiateSubmissionScene), forControlEvents: .TouchUpInside)
        
        filterButton.imageView?.contentMode = .ScaleAspectFit
        filterButton.setBackgroundImage(UIImage(named: "FilterButtonNotpressed")!, forState: .Normal)
        filterButton.setBackgroundImage(UIImage(named: "FilterbuttonPressed")!, forState: .Highlighted)
        filterButton.addTarget(self, action: #selector(self.initiateFilterScene), forControlEvents: .TouchUpInside)

        
        homeButton.setBackgroundImage(UIImage(named: "CharmaHomeButton")!, forState: .Normal)
        homeButton.addTarget(self, action: #selector(didClickHomeButton), forControlEvents: .TouchUpInside)
        homeButton.imageView?.contentMode = .ScaleAspectFit
        
        
        titleLabel.text = nil
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.font = UIFont(name: "Pocket Monk", size: 25)
        titleLabel.textColor = UIColor.whiteColor()
        
        
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        self.blurView.alpha = 0
        
        
        self.view.addSubview(mapView)
        self.view.insertSubview(filterButton, aboveSubview: mapView)
        self.view.insertSubview(addButton, aboveSubview: mapView)
        self.view.insertSubview(modeSwitchButton, aboveSubview: mapView)
        self.view.addSubview(homeButton)
        self.view.insertSubview(blurView, belowSubview: homeButton)
        self.view.addSubview(titleLabel)
        
        NSLayoutConstraint.setupConstraint(blurView, rootview: self.view)
        
        self.view.backgroundColor = UIColor.clearColor()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.frame = self.view.bounds
        addButton.frame = CGRect(x: self.view.frame.width - ADD_BUTTON_WIDTH - ADD_BUTTON_PADDING, y: self.view.frame.height - ADD_BUTTON_WIDTH - ADD_BUTTON_PADDING, width: ADD_BUTTON_WIDTH, height: ADD_BUTTON_HEIGHT)
        addButton.center.x = self.view.frame.width/2
        
        homeButton.frame = CGRect(x: HOME_BUTTON_LEADING_PADDING, y: HOME_BUTTON_TOP_PADDING, width: HOME_BUTTON_WIDTH, height: 83)
        
        
        modeSwitchButton.frame = CGRect(x: MODE_BUTTON_LEADING_PADDING, y: self.view.frame.height - MODE_BUTTON_WIDTH - MODE_BUTTON_BOTTOM_PADDING, width: MODE_BUTTON_WIDTH, height: MODE_BUTTON_WIDTH)
        modeSwitchButton.center.y = addButton.center.y + 15
        
        filterButton.frame = CGRect(x: self.view.frame.width - FILTER_BUTTON_TRAILING_PADDING - FILTER_BUTTON_WIDTH, y: 0, width: FILTER_BUTTON_WIDTH, height: FILTER_BUTTON_WIDTH)
        filterButton.center.y = addButton.center.y + 15
        
        let titleLabelX = homeButton.frame.width + HOME_BUTTON_LEADING_PADDING + LABEL_PADDING
        titleLabel.frame = CGRect(x: titleLabelX, y: 0, width: self.view.frame.width - titleLabelX - LABEL_TRAILING_PADDING, height: homeButton.frame.height)
        titleLabel.center.y = homeButton.center.y

    }
    
    func mapView(mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView?{
        
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width/4*3, height: 180)
        let sighting = (marker.userData as! Sighting)
        var name = sighting.user?.nickname
        if name == nil {
            name = "uniorns"
        }
        
        
        return MarkerInfoView.getView(name!, charmaPoint: sighting.charma?.integerValue ?? 0, withMessage: true, frame: frame, charmaAction: {
                let orgCharma = sighting.charma?.integerValue ?? 0
                sighting.charma = NSNumber(integer: orgCharma+1)
                sighting.hasUpvoted = true
                
                sighting.saveInBackground()
        })
    }
    var zoom:Float = 0
    var inModalPresentation = false
    func didClickHomeButton() {
        if inModalPresentation {
            submissionCoordinator?.dismissViewController(submissionCoordinator!.activeVC)
        } else {
            updateLocation()
        }
    }
    
    func mapView(mapView: GMSMapView, idleAtCameraPosition position: GMSCameraPosition) {
        dataSource?.fetchPokemons(position.target, zoomLevel: Int(position.zoom),modeSwitch: false)
     }
    func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker) {
        let sighting = (marker.userData as! Sighting)

        let orgCharma = sighting.charma?.integerValue ?? 0
        sighting.charma = NSNumber(integer: orgCharma+1)
        sighting.hasUpvoted = true
//        marker.
        sighting.saveInBackground()
    }
    func didClickSwitchMode() {
        dataSource?.switchMode()
        modeSwitchButton.selected = !modeSwitchButton.selected
    }
    
    func updateLocation() {
        if let location = LocationManager.sharedLocationManager.currentLocation {
            mapView.animateToCameraPosition(GMSCameraPosition(target: location.coordinate, zoom: 13, bearing: 30, viewingAngle: 30))
        }
        
    }
    
    func initiateSubmissionScene() {
        let logVC = UIStoryboard(name: "LogScene", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("logPokemonViewController") as! LogPokemonViewController
        let mapVC = UIStoryboard(name: "LogScene", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("logMapViewController") as! LogMapViewController
        submissionCoordinator = SubmissionCoordinator(mainVC: self, pokemonVC: logVC, mapVC: mapVC)
        submissionCoordinator?.startSubmission()
    }
    
    func turnOffBlur() {
        inModalPresentation = false
        UIView.animateWithDuration(0.2, animations: {
            self.blurView.alpha = 0
            
        }) {
            finished in
            if finished {
                UIApplication.sharedApplication().statusBarStyle = .Default
            }
        }
    }
    
    
    
    func initiateFilterScene()  {
        filterCoordinator = FilterCoordinator(mainVC: self)
        filterCoordinator?.showFilterView()
    }
    
    func didUpdateFilter() {
        dataSource?.fetchPokemons(mapView.camera.target, zoomLevel: Int(mapView.camera.zoom), modeSwitch: true)
    }
    
    func turnOnBlur(completion:(()->())? = nil) {
        inModalPresentation = true
        UIView.animateWithDuration(0.2, animations: {
            self.blurView.alpha = 1
        }) { success in
            if success {
                completion?()
                UIApplication.sharedApplication().statusBarStyle = .LightContent
            }
            
        }
        
    }
    
    
    
}

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
        //clllocation
        let cllocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        if let lastLocation = lastFetchedLocation where cllocation.distanceFromLocation(lastLocation) <= 1000 && !modeSwitch {
            return
        }
        lastFetchedLocation = cllocation
        if !realTimeMode {
            self.allTimeFetchedAt = NSDate()
            PMClient.sharedClient.getPokemonNearby(location, zoomLevel: zoomLevel, completion: { (sightings, error) in
                if error == nil {
                    self.allTimeSightings = sightings
                    self.updateViews()
                }
            })
            
        } else {
            self.recentFetchedAt = NSDate()
            allTimeSightings = []
            realTimeSocket = PMClient.sharedClient.getPokemonNearbyLive(lastFetchedLocation.coordinate, zoomLevel: zoomLevel)
            realTimeSocket.handle(Event.Created) { query, object in
                print(object.objectId)
                self.allTimeSightings.append(object)
                self.updateViews()
            }
            
        }
    }
    
    func switchMode() {
        realTimeMode = !realTimeMode
        mapView.clear()
        if recentFetchedAt != nil && allTimeFetchedAt != nil {
            if (realTimeMode && recentFetchedAt?.compare(allTimeFetchedAt) == .OrderedAscending) ||
                (!realTimeMode && allTimeFetchedAt.compare(recentFetchedAt) == .OrderedAscending) {
                updateViews()
                return
            }
        }
        fetchPokemons(mapView.camera.target, zoomLevel: Int(mapView.camera.zoom), modeSwitch: true)
    }
    
    func updateViews() {
        sightings = realTimeMode ? recentSightings : allTimeSightings
    }
    
}

