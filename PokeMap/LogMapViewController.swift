//
//  LogMapViewController.swift
//  PokeMap
//
//  Created by Oskar Zhang on 7/13/16.
//  Copyright © 2016 OskarZhang. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
class LogMapViewController:UIViewController,UITextFieldDelegate {
    var mapView:GMSMapView!
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var dropButton: UIButton!
    @IBOutlet weak var pokemonIconView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    var pokemonIcon:UIImage!
    var submissionCoordinator:SubmissionCoordinator?
    
    override func viewDidLoad() {
        pokemonIconView.image = pokemonIcon
        setupMapView()
        configureButtons()
        setMapLocation()
        LocationManager.sharedLocationManager.subscribeToLocationChange(self, selector: #selector(self.setMapLocation))
    }
    
    override func awakeFromNib() {
        self.title = "Set Location"
    }
    
    func configureButtons() {
        dropButton.setBackgroundImage(UIImage.fromColor(UIColor(hex: 0xfddc49)), forState: .Normal)
        dropButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        dropButton.setTitle("Loading", forState: .Disabled)
    }
    
    override func viewDidAppear(animated: Bool) {
        showTipsIfNeeded()
    }
    
    
    func showTipsIfNeeded() {
        if !NSUserDefaults.standardUserDefaults().boolForKey("hasShownMapTips") {
            PopupView.showView("Move the map to mark a new pokémon sighting.")
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "hasShownMapTips")
        }
    }
    
    func setupMapView() {
        mapView = GMSMapView()
        mapView.delegate = self
        mapView.myLocationEnabled = true
        self.mapContainerView.insertSubview(mapView, atIndex: 0)
        NSLayoutConstraint.setupConstraint(mapView, rootview: mapContainerView)
        mapContainerView.clipsToBounds = false
        mapView.clipsToBounds = false
        mapView.layer.shadowColor = UIColor.blackColor().colorWithAlphaComponent(0.2).CGColor
        mapView.layer.shadowRadius = 2
        mapView.layer.shadowOpacity = 0.7
    }
    
    func setMapLocation() {
        if let location = LocationManager.sharedLocationManager.currentLocation {
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 16, bearing: 0, viewingAngle: 0);
        }
    }
    
    func startLoading() {
        dropButton.enabled = true
    }
    func stopLoading() {
        dropButton.enabled = false
    }
    
    @IBAction func didClickAdd(sender: AnyObject) {
        let location = CLLocation(latitude: mapView.camera.target.latitude, longitude: mapView.camera.target.longitude)
        submissionCoordinator?.finishSubmission(location)
    }
    
    @IBAction func dismissView(sender: AnyObject) {
        self.view.endEditing(true)
        submissionCoordinator?.dismissViewController(self)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}


extension LogMapViewController:GMSMapViewDelegate {
    func mapView(mapView: GMSMapView, didChangeCameraPosition position: GMSCameraPosition) {
        GMSGeocoder().reverseGeocodeCoordinate(mapView.camera.target) { (response, error) in
            if error == nil {
                self.addressLabel.text = response?.firstResult()?.lines?.first
            }
        }
    }
}