//
//  LocationCoordinator.swift
//  Pro-Tracker
//
//  Created by Chijioke Ndubisi on 6/10/16.
//  Copyright © 2016 andela-cj. All rights reserved.
//

import CoreLocation

struct LocationCoordinator{
    lazy var locationManager: CLLocationManager! = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter  = kCLLocationAccuracyBest
        return manager
    }()
    
    static func validateLocationManagerAuthorization() -> Int {
        switch CLLocationManager.authorizationStatus(){
        case .Denied: return -2
        case .NotDetermined: return -1
        case .AuthorizedWhenInUse: return 1
        case .AuthorizedAlways: return 1
        case .Restricted: return -3
        }
    }
}