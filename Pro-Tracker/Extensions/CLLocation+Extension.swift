//
//  CLLocation+Extension.swift
//  Pro-Tracker
//
//  Created by Chijioke Ndubisi on 6/17/16.
//  Copyright © 2016 andela-cj. All rights reserved.
//

import CoreLocation
import CoreData

extension CLLocation {
    func save(_ inContext:NSManagedObjectContext){
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(self, completionHandler: { (placemark, error) in
            do {
                var address = ""
                
                if error == nil && placemark?.count > 0 {
                    if let thoroughfare = placemark!.first!.thoroughfare {
                        address += thoroughfare + " "
                    }
                    if let subAdministrativeArea = placemark!.first!.subAdministrativeArea {
                        address += subAdministrativeArea + " "
                    }
                    if let country = placemark!.first!.country {
                        address += country + " "
                    }
                }else {
                    address = "Unknown"
                }
                let location = Location(lat:self.coordinate.latitude, long:self.coordinate.latitude,address:  address, context:  inContext)
                try location.managedObjectContext?.save()
            } catch {
                print(error)
            }
            
        })
    }
}
