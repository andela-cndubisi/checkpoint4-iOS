//
//  LocationCoordinator.swift
//  Pro-Tracker
//
//  Created by Chijioke Ndubisi on 6/10/16.
//  Copyright © 2016 andela-cj. All rights reserved.
//

import CoreLocation
import UIKit
class LocationCoordinator{
    lazy var locationManager: CLLocationManager! = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter  = kCLLocationAccuracyBest
        return manager
    }()
    
    lazy var authorized:Bool = {
        let status  = LocationCoordinator.validateLocationManagerAuthorization()
        switch  status {
        case 1:
            return true
        case -1:
            self.locationManager.requestAlwaysAuthorization()
            return false
        default:
            return false
        }
    }()
    
    static func validateLocationManagerAuthorization() -> Int {
        switch CLLocationManager.authorizationStatus(){
        case .denied: return -2
        case .notDetermined: return -1
        case .authorizedWhenInUse, .authorizedAlways: return 1
        case .restricted: return -3
        }
    }
    

    
    func showLocationSettingAlert() -> UIAlertController {
        let LocationAlert =  UIAlertController(title: "Location Services Disabled",
                                               message: "Enable Location Services in Setting to Continue",
                                               preferredStyle: .alert)
        
        LocationAlert.addAction(UIAlertAction(title: "Settings",
                                              style: .default,
                                              handler: { (actionview) -> Void in
                                                UIApplication.shared().openURL(URL(string:UIApplicationOpenSettingsURLString)!)
        }))
        
        LocationAlert.addAction(UIAlertAction(title: "OK",
                                              style: .default,
                                              handler: { (actionview) -> Void in
                                                LocationAlert.dismiss(animated: true, completion: nil)
        }))
        
        return LocationAlert
    }
}
