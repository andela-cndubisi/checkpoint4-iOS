//
//  Productivity+CoreDataProperties.swift
//  pro-tracker
//
//  Created by Chijioke Ndubisi on 01/12/2015.
//  Copyright © 2015 cjay. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Productivity {

    @NSManaged var date: NSDate?
    @NSManaged var location: NSSet?

}
