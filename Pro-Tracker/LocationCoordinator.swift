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
        case .denied: return -2
        case .notDetermined: return -1
        case .authorizedWhenInUse: return 1
        case .authorizedAlways: return 1
        case .restricted: return -3
        }
    }
}
