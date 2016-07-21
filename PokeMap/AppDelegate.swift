//
//  AppDelegate.swift
//  PokeMap
//
//  Created by Oskar Zhang on 7/13/16.
//  Copyright © 2016 OskarZhang. All rights reserved.
//
import Parse
import UIKit
import GoogleMaps
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        configureAppearance()
        let mainViewController = MainMapViewController()
        GMSServices.provideAPIKey("AIzaSyBqswxb7GNM581_-WBYaLz4f2g2DbVluEw")
        let configuration = ParseClientConfiguration {
            $0.applicationId = "JVMtSD7ymDBYOnXyuS5TMiovgqjmGBQqdULbTQK0"
            $0.clientKey = nil
            $0.server = "http://parseserver-g27mn-env.us-east-1.elasticbeanstalk.com/parse"
            $0.localDatastoreEnabled = true
        }
        
        Parse.enableLocalDatastore()
        Parse.initializeWithConfiguration(configuration)
        
        
        User.registerSubclass()
        Pokemon.registerSubclass()
        Type.registerSubclass()
        Sighting.registerSubclass()
        window?.rootViewController = mainViewController
        window?.makeKeyAndVisible()
        LocationManager.sharedLocationManager.startLocationRecording()
        if PFUser.currentUser() == nil {
            PFAnonymousUtils.logInInBackground()
            
        }
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        return true
    }
    
    func configureAppearance() {

        
        var preferences = EasyTipView.Preferences()
        preferences.drawing.font = UIFont(name: "Futura-Medium", size: 13)!
        preferences.drawing.foregroundColor = UIColor.whiteColor()
        preferences.drawing.backgroundColor = PMColor
        preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.Top
        EasyTipView.globalPreferences = preferences
        
    }
    
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.addUniqueObject("global", forKey: "channels")
        if let user = PFUser.currentUser() {
            
            installation.setObject(user, forKey: "user")
        }
        installation.saveInBackground()
    }
    
    

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print(error)
    }
    
//    
//    func applicationDidBecomeActive(application: UIApplication) {
//        LocationManager.sharedLocationManager.startMonitoringSignificantChanges(false)
//        
//    }
//    func applicationDidEnterBackground(application: UIApplication) {
//        LocationManager.sharedLocationManager.startMonitoringSignificantChanges(true)
//    }
//    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

