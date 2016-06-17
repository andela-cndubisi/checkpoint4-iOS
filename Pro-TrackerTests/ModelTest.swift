//
//  ModelTest.swift
//  pro-tracker
//
//  Created by Chijioke Ndubisi on 03/12/2015.
//  Copyright © 2015 cjay. All rights reserved.
//

import XCTest
import CoreData
import CoreLocation
@testable import Pro_Tracker

class ModelTest: XCTestCase {
    
    lazy var locationManager: CLLocationManager! = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter  = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        return manager
    }()
    
//    private lazy var applicationDocumentsDirectory: NSURL = {
//        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
//        return urls[urls.count-1]
//    }()
//    
//    lazy var managedObjectContext: NSManagedObjectContext = {
//        let coordinator = self.persistentStoreCoordinator
//        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
//        managedObjectContext.persistentStoreCoordinator = coordinator
//        return managedObjectContext
//    }()
//    
//    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
//        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
//        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("pro-tracker.sqlite")
//        var failureReason = "There was an error creating or loading the application's saved data."
//        do {
//            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
//        } catch {
//            var dict = [String: AnyObject]()
//            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
//            dict[NSLocalizedFailureReasonErrorKey] = failureReason
//            
//            dict[NSUnderlyingErrorKey] = error as NSError
//            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
//            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
//            abort()
//        }
//        
//        return coordinator
//    }()
//    
//    private lazy var managedObjectModel: NSManagedObjectModel = {
//        let modelURL = NSBundle.mainBundle().URLForResource("ProductivityModel", withExtension: "momd")!
//        return NSManagedObjectModel(contentsOfURL: modelURL)!
//    }()
//    
    func testSaveLocation(){
        do {
            let location = Location(lat: 6.52438, long: 3.37921, address: "Lagos")
            try location.managedObjectContext?.save()
        }catch {
            print (error)
            XCTFail()
        }
    }
    
    func testLocationFetch(){
        let fetch = NSFetchRequest(entityName: "Location")
//        fetch.mpo
//        fetch.entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: self.managedObjectContext)
        do{
            let result =  try appDelegate().managedObjectContext.executeFetchRequest(fetch)
            print(result)
            for location in result {
                let loca = location as! Location
                XCTAssertNotNil(loca.latitude!)
                XCTAssertNotNil(loca.longitude!)
                XCTAssertNotNil(loca.address!)
                XCTAssertNotNil(loca.productivity!)
            }
        }catch  {
            print(error)
        }
    }
    
    func testGetLocationByDate(){
        let locations = Productivity.getAllProductivity()
        XCTAssertNotNil(locations)
        for productivity in locations {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .MediumStyle
            let str = dateFormatter.stringFromDate(productivity.date!)
            print(str)
            
        }
    }
    
    
    
}
