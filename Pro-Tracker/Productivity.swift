//
//  Productivity.swift
//  pro-tracker
//
//  Created by Chijioke Ndubisi on 27/11/2015.
//  Copyright © 2015 cjay. All rights reserved.
//

import Foundation
import CoreData


class Productivity: NSManagedObject {
// Insert code here to add functionality to your managed object subclass
    
    static let ENTITY_NAME = "Productivity"
    convenience init(date:NSDate){
        let managedObjectContext = appDelegate().managedObjectContext
        let entity =  NSEntityDescription.entityForName("Productivity", inManagedObjectContext: managedObjectContext)
        self.init(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)
        self.date = date
    }
    
    class func getAllProductivity() -> [Productivity]{
        let managedObjectContext = appDelegate().managedObjectContext
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName(ENTITY_NAME, inManagedObjectContext: managedObjectContext)
        fetchRequest.entity = entity
        
        do {
            let result = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Productivity]
            return result
            
        } catch {
            let fetchError = error as NSError
            print("Error!!! ", fetchError)
        }
        return []
    }
    
    class func productivityWithDate(date:NSDate) -> Productivity?{
        let fetchRequest = NSFetchRequest(entityName: "Productivity")
        fetchRequest.predicate = NSPredicate(format: "date == %@", argumentArray: [date])
        do {
            let result = try appDelegate().managedObjectContext.executeFetchRequest(fetchRequest)
            if result.count > 0 {
                return result.first! as? Productivity
            }
        }catch {
            return nil
        }
        return nil
    }
}
