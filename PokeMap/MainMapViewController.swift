//
//  ViewController.swift
//  PokeMap
//
//  Created by Oskar Zhang on 7/13/16.
//  Copyright © 2016 OskarZhang. All rights reserved.
//

import UIKit
import GoogleMaps
import Parse
var PMColor = UIColor(hex: 0xE45C38)
class MainMapViewController: UIViewController,GMSMapViewDelegate {
    var mapView:GMSMapView!
    let ADD_BUTTON_WIDTH:CGFloat = 80
    let ADD_BUTTON_HEIGHT:CGFloat = 80 * 1.21
    let ADD_BUTTON_PADDING:CGFloat = 35
    let HOME_BUTTON_LEADING_PADDING:CGFloat = 20
    let HOME_BUTTON_TOP_PADDING:CGFloat = 30
    let HOME_BUTTON_WIDTH:CGFloat = 90
    let MODE_BUTTON_LEADING_PADDING:CGFloat = 20
    let MODE_BUTTON_WIDTH:CGFloat = 80
    let MODE_BUTTON_BOTTOM_PADDING:CGFloat = 40
    
    let FILTER_BUTTON_TRAILING_PADDING:CGFloat = 20
    let FILTER_BUTTON_WIDTH:CGFloat = 80
    let FILTER_BUTTON_BOTTOM_PADDING:CGFloat = 40
    
    var LABEL_PADDING:CGFloat = 10
    var LABEL_TRAILING_PADDING:CGFloat = 110 //because of filter apply button
    
    var charmaLabel = UILabel()
    var markerView:MarkerInfoView!
    var titleLabel = UILabel()
    
    var addButton:UIButton = UIButton()
    var homeButton = UIButton()
    var filterButton = UIButton()
    var modeSwitchButton = UIButton()
    var filterSearchButton = UIButton()
    var searchButton = UIButton()
    
    
    
    var blurView:UIVisualEffectView!
    var dataSource:MainMapViewControllerDataSource?
    var submissionCoordinator:SubmissionCoordinator?
    var filterCoordinator:FilterCoordinator?
    var searchCoordinator:SearchCoordinator?
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
        showTooltips()
    }
    
    
    func showTooltips() {
        if !NSUserDefaults.standardUserDefaults().boolForKey("hasShownTooltips") {
            EasyTipView.show(animated: true, forView: modeSwitchButton, withinSuperview: self.view, text: "This is live view. It shows you real time sightings within the last 30 minutes. Tap it to switch it off", preferences: EasyTipView.globalPreferences, delegate: self)
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "hasShownTooltips")
        }
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
        
        
        filterSearchButton.addTarget(self, action: #selector(self.didClickExpand), forControlEvents: .TouchUpInside)
        
        filterSearchButton.setBackgroundImage(UIImage(named:"FilterButtonNotpressed"), forState: .Normal)
        filterSearchButton.clipsToBounds = true

        
        searchButton.setBackgroundImage(UIImage(named:"SearchFilter"), forState: .Normal)
        searchButton.addTarget(self, action: #selector(self.didClickSearch), forControlEvents: .TouchUpInside)
        searchButton.clipsToBounds = true
        searchButton.hidden = true
        filterButton.imageView?.contentMode = .ScaleAspectFit
        filterButton.setBackgroundImage(UIImage(named: "TypeFilter")!, forState: .Normal)
        filterButton.addTarget(self, action: #selector(self.initiateFilterScene), forControlEvents: .TouchUpInside)
        filterButton.hidden = true
        
        
        
        
        
        
        homeButton.setBackgroundImage(UIImage(named: "charmacounterLogo")!, forState: .Normal)
        homeButton.addTarget(self, action: #selector(didClickHomeButton), forControlEvents: .TouchUpInside)
        homeButton.imageView?.contentMode = .ScaleAspectFit
        
        charmaLabel.backgroundColor = PMColor
        charmaLabel.font = UIFont(name: "Pocket Monk",size:25)
        charmaLabel.textColor = UIColor.whiteColor()
        charmaLabel.layer.shadowRadius = 1
        charmaLabel.layer.shadowColor = UIColor.blackColor().CGColor
        charmaLabel.layer.shadowOpacity = 0.3
        charmaLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        updateCharmaPoints()
        
        titleLabel.text = nil
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.font = UIFont(name: "Pocket Monk", size: 25)
        titleLabel.textColor = UIColor.whiteColor()
        
        
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        self.blurView.alpha = 0
        
        
        self.view.addSubview(mapView)

        
        self.view.insertSubview(addButton, aboveSubview: mapView)
        self.view.insertSubview(modeSwitchButton, aboveSubview: mapView)
        self.view.addSubview(homeButton)
        self.view.insertSubview(blurView, belowSubview: homeButton)
        
        self.view.insertSubview(filterButton, aboveSubview: mapView)
        self.view.insertSubview(searchButton, aboveSubview: filterButton)
        self.view.insertSubview(filterSearchButton, aboveSubview: searchButton)
        
        self.view.addSubview(titleLabel)
        self.view.insertSubview(charmaLabel,atIndex: 1)
        NSLayoutConstraint.setupConstraint(blurView, rootview: self.view)
        
        self.view.backgroundColor = UIColor.clearColor()
    }
    
    func updateCharmaPoints() {
        let charma = (PFUser.currentUser() as? User)?.charma ?? 0
        
        charmaLabel.text = ("    \(charma.integerValue) charma")
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.frame = self.view.bounds
        addButton.frame = CGRect(x: self.view.frame.width - ADD_BUTTON_WIDTH - ADD_BUTTON_PADDING, y: self.view.frame.height - ADD_BUTTON_WIDTH - ADD_BUTTON_PADDING, width: ADD_BUTTON_WIDTH, height: ADD_BUTTON_HEIGHT)
        addButton.center.x = self.view.frame.width/2
        
        homeButton.frame = CGRect(x: HOME_BUTTON_LEADING_PADDING, y: HOME_BUTTON_TOP_PADDING, width: HOME_BUTTON_WIDTH, height: HOME_BUTTON_WIDTH/1.11429)
        
        modeSwitchButton.frame = CGRect(x: MODE_BUTTON_LEADING_PADDING, y: self.view.frame.height - MODE_BUTTON_WIDTH - MODE_BUTTON_BOTTOM_PADDING, width: MODE_BUTTON_WIDTH, height: MODE_BUTTON_WIDTH)
        modeSwitchButton.center.y = addButton.center.y + 5
        
        filterButton.frame = CGRect(x: self.view.frame.width - FILTER_BUTTON_TRAILING_PADDING - FILTER_BUTTON_WIDTH, y: 0, width: FILTER_BUTTON_WIDTH, height: FILTER_BUTTON_WIDTH)
        filterButton.center.y = addButton.center.y + 5
        
        let titleLabelX = homeButton.frame.width + HOME_BUTTON_LEADING_PADDING + LABEL_PADDING
        titleLabel.frame = CGRect(x: titleLabelX, y: 0, width: self.view.frame.width - titleLabelX - LABEL_TRAILING_PADDING, height: homeButton.frame.height)
        titleLabel.center.y = homeButton.center.y - 10
        
         charmaLabel.sizeToFit()
        let frame = charmaLabel.frame
        charmaLabel.frame = CGRect(x: homeButton.frame.width + homeButton.frame.origin.x - 50, y: 0, width: frame.width + 30, height: 25)
        charmaLabel.center.y = homeButton.center.y - 5
        
        
        
        filterSearchButton.frame = filterButton.frame
        searchButton.frame = filterButton.frame
        filterSearchButton.layer.cornerRadius = FILTER_BUTTON_WIDTH/2
        searchButton.layer.cornerRadius = FILTER_BUTTON_WIDTH/2
        

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
    
    var hasExpanded = false
    func didClickExpand() {
        if hasExpanded {
            UIView.animateWithDuration(0.3, animations: { 
                self.searchButton.frame.origin.y += 90
                self.filterButton.frame.origin.y += 180
                self.filterButton.alpha = 0
                self.searchButton.alpha = 0
                }, completion: nil)
        } else {
            filterButton.hidden = false
            searchButton.hidden = false
            UIView.animateWithDuration(0.3) {
                self.searchButton.frame.origin.y -= 90
                self.filterButton.frame.origin.y -= 180
                self.filterButton.alpha = 1
                self.searchButton.alpha = 1
            }
        }
        hasExpanded = !hasExpanded
        
    }
    
    func didClickSearch() {
        let noSearch = PMClient.sharedClient.pokemonInSearch.count == 0
        if !noSearch {
            PMClient.sharedClient.pokemonInSearch = []
            updateSearchButton()
        } else {
            searchCoordinator = SearchCoordinator(mainVC: self)
            searchCoordinator?.showSearchView()
                
        }

    }
    
    
    
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        let sighting = (marker.userData as! Sighting)
        
        var name = sighting.user?.nickname
        if name == nil {
            name = "uniorns"
        }
        
        let numCharma = NSUserDefaults.standardUserDefaults().integerForKey("numberCharmaAdded")
        
        let showMessage = numCharma <= 5
        
        markerView = MarkerInfoView.getView(name!, charmaPoint: sighting.charma?.integerValue ?? 0, withMessage: showMessage,hasUpvoted: sighting.hasUpvoted, charmaAction: {
            let orgCharma = sighting.charma?.integerValue ?? 0
            sighting.charma = NSNumber(integer: orgCharma+1)
            sighting.hasUpvoted = true
            sighting.saveInBackground()
        })
        enableTouchToDismiss()
        return true
    }
    
    func enableTouchToDismiss() {
        blurView.userInteractionEnabled = true
        let gestureRecognizer = UIGestureRecognizer(target: self, action: #selector(self.didTapBlurView))
        blurView.addGestureRecognizer(gestureRecognizer)
    }
    func didTapBlurView() {
        if let infoview = markerView {
            infoview.removeFromSuperview()
            markerView = nil
            blurView.userInteractionEnabled = false
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
    
    func updateFilterButton() {
        let noFilter = PMClient.sharedClient.types.count == 0
        
        filterButton.setBackgroundImage(UIImage(named: noFilter ? "TypeFilter" : "TypeFilterActive")!, forState:  .Normal )
    }
    
    func updateSearchButton() {
        let noSearch = PMClient.sharedClient.pokemonInSearch.count == 0
        searchButton.setBackgroundImage(UIImage(named: noSearch ? "SearchFilter" : "SearchFilterActive")!, forState:  .Normal )
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

extension MainMapViewController:EasyTipViewDelegate {
    func easyTipViewDidDismiss(tipView: EasyTipView) {
        
            EasyTipView.show(animated: true, forView: charmaLabel, withinSuperview: self.view, text: "You can gain charmas when other trainers thank you for your sightings.", preferences: EasyTipView.globalPreferences, delegate: nil)
    }
}
