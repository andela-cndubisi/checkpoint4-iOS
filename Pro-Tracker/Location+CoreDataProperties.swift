//
//  Location+CoreDataProperties.swift
//  pro-tracker
//
//  Created by Chijioke Ndubisi on 01/12/2015.
//  Copyright © 2015 andela-cj. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Location {

    @NSManaged var address: String?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var productivity: Productivity?

}
