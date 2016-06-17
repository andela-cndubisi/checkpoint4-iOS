//
//  Location.swift
//  pro-tracker
//
//  Created by Chijioke Ndubisi on 27/11/2015.
//  Copyright © 2015 cjay. All rights reserved.
//

import Foundation
import CoreData

class Location: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    convenience init(lat:Double, long:Double, address:String, context:NSManagedObjectContext){
        let managedObjectContext = context
        let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: managedObjectContext)
        self.init(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)
        self.latitude = lat
        self.longitude = long
        self.address = address
        let date = NSCalendar.currentCalendar().startOfDayForDate(NSDate())
        let productivity = Productivity.productivityWithDate(date, inContext: context)
        self.productivity = (productivity != nil) ? productivity : Productivity(date:date, context: context)
    }
}
