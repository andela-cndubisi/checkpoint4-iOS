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
    convenience init(date:Date, context:NSManagedObjectContext){
        let managedObjectContext = context
        let entity =  NSEntityDescription.entity(forEntityName: "Productivity", in: managedObjectContext)
        self.init(entity: entity!, insertInto: managedObjectContext)
        self.date = date
    }
    
    class func getAllProductivity(_ inContext:NSManagedObjectContext) -> [Productivity]{
        let managedObjectContext = inContext
        let fetchRequest = NSFetchRequest<Productivity>()
        let entity = NSEntityDescription.entity(forEntityName: ENTITY_NAME, in: managedObjectContext)
        fetchRequest.entity = entity
        
        do {
            let result = try managedObjectContext.fetch(fetchRequest)
            return result
            
        } catch {
            let fetchError = error as NSError
            print("Error!!! ", fetchError)
        }
        return []
    }
    
    class func productivityWithDate(_ date:Date, inContext:NSManagedObjectContext) -> Productivity?{
        let fetchRequest = NSFetchRequest<Productivity>(entityName: "Productivity")
        fetchRequest.predicate = Predicate(format: "date == %@", argumentArray: [date])
        do {
            let result = try inContext.fetch(fetchRequest)
            if result.count > 0 {
                return result.first!
            }
        }catch {
            return nil
        }
        return nil
    }
}
