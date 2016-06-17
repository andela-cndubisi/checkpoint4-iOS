//
//  Location.swift
//  pro-tracker
//
//  Created by Chijioke Ndubisi on 27/11/2015.
//  Copyright © 2015 cjay. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

class Location: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    convenience init(lat:Double, long:Double, address:String, context:NSManagedObjectContext){
        let managedObjectContext = context
        let entity = NSEntityDescription.entity(forEntityName: "Location", in: managedObjectContext)
        self.init(entity: entity!, insertInto: managedObjectContext)
        self.latitude = lat
        self.longitude = long
        self.address = address
        let date = Calendar.current().startOfDay(for: Date())
        let productivity = Productivity.productivityWithDate(date, inContext: context)
        self.productivity = (productivity != nil) ? productivity : Productivity(date:date, context: context)
    }
}

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
