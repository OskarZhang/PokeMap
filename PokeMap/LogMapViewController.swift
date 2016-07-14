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
    @IBOutlet weak var keyboardConstraint:NSLayoutConstraint!
    
    @IBOutlet weak var pokemonIconView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    var pokemonIcon:UIImage!
    var submissionCoordinator:SubmissionCoordinator?

    override func viewDidLoad() {
        mapView = GMSMapView()
        mapView.delegate = self
        pokemonIconView.image = pokemonIcon
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(self.willShowKeyboard(_:)),
                                                         name: "UIKeyboardWillShowNotification",
                                                         object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(self.willHideKeyboard(_:)),
                                                         name: "UIKeyboardWillHideNotification",
                                                         object: nil)
        
        if let location = LocationManager.sharedLocationManager.currentLocation {
            
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 10, bearing: 30, viewingAngle: 45);
            
        }
        mapView.myLocationEnabled = true
        dropButton.setBackgroundImage(UIImage.fromColor(UIColor(hex: 0xfddc49)), forState: .Normal)
        dropButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.mapContainerView.insertSubview(mapView, atIndex: 0)
        NSLayoutConstraint.setupConstraint(mapView, rootview: mapContainerView)
        dropButton.setTitle("Loading", forState: .Disabled)
        
        mapContainerView.clipsToBounds = false
        mapView.clipsToBounds = false
        mapView.layer.shadowColor = UIColor.blackColor().colorWithAlphaComponent(0.2).CGColor
        mapView.layer.shadowRadius = 2
        mapView.layer.shadowOpacity = 0.7
        

    }
    
    func willHideKeyboard(note:NSNotification) {
        UIView.animateWithDuration(0.2, animations: {
            self.keyboardConstraint.constant = 0
            self.view.layoutSubviews()
        })
    }

    func willShowKeyboard(note:NSNotification) {
        let keyboardSize = note.userInfo![UIKeyboardFrameEndUserInfoKey]!.CGRectValue()

        UIView.animateWithDuration(0.2, animations: {
            self.keyboardConstraint.constant = keyboardSize.height
            self.view.layoutSubviews()
        })
    }
    
    @IBAction func didClickCancel(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didClickAdd(sender: AnyObject) {
        let location = CLLocation(latitude: mapView.camera.target.latitude, longitude: mapView.camera.target.longitude)
        submissionCoordinator?.finishSubmission(location)
    }
    
    func startLoading() {
        dropButton.enabled = true
    }
    func stopLoading() {
        dropButton.enabled = false
    }
    
    @IBAction func dismissView(sender: AnyObject) {
        self.view.endEditing(true)
        submissionCoordinator?.dismissViewController(self)
        
    }
}


extension LogMapViewController:GMSMapViewDelegate {
    func mapView(mapView: GMSMapView, didChangeCameraPosition position: GMSCameraPosition) {
        
        GMSGeocoder().reverseGeocodeCoordinate(mapView.camera.target) { (response, error) in
            if error == nil {
                self.addressLabel.text = response?.firstResult()?.addressLine1()
            }
        }
        
    }
}