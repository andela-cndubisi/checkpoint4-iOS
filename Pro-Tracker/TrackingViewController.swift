//
//  TrackingViewController.swift
//  pro-tracker
//
//  Created by Chijioke Ndubisi on 24/11/2015.
//  Copyright © 2015 cjay. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import CoreData
import Contacts

class TrackingViewController: UIViewController, CLLocationManagerDelegate, TimeTrackerDelegate {
    
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var recordedLocations: UIButton!
    @IBOutlet weak var locationCount: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var minuteLabel: UILabel!
    @IBOutlet weak var secondsLabel: UILabel!
    
    private var currentLocation: CLLocation?
    private let timeTracker = TimeTracker()
    private var recordedLocationsCount = 0 {
        didSet{
            locationCount.text = String(recordedLocationsCount)
        }
    }
    private var hasSavedLocation = false {
        didSet{
            if (oldValue == false){
                currentLocation?.save()
            }
        }
    }
    
    var intervalToSave:Int!
    var locationManager:CLLocationManager!

    
    @IBAction func showHistory(sender: UIBarButtonItem) {

    }
    
    @IBAction func pauseTracking(sender: UIButton) {
        if !timeTracker.isPaused() {
            timeTracker.pause()
        }else{
            timeTracker.resume()
        }
    }
    // MARK -
    // MARK: TimeTrackerDelegate
    func handleTime(milliseconds:Double){
        //calculate the minutes in elapsed time.
        var elapsedTime = milliseconds
        let minutes = UInt8(elapsedTime / 60.0)
        //calculate the seconds in elapsed time.
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        let seconds = UInt32(elapsedTime)
        elapsedTime -= NSTimeInterval(seconds)
        //find out the fraction of milliseconds to be displayed.
        secondsLabel.text = String(format: "%02d", seconds)
        minuteLabel.text = String(format: "%02d", minutes)
    }
    
    // MARK -
    // MARK: View Life Cycle
    override func viewDidLoad() {
        self.navigationItem.hidesBackButton = true
        timeTracker.delegate = self
        timeTracker.start()
        
        // customizeView
        addCornerRadiusViews(pauseButton)
        addCornerRadiusViews(locationCount)
        recordedLocations.layer.cornerRadius = 20
        
        // setup LocationManager
        locationManager = appDelegate().locationManager
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    private func addCornerRadiusViews(view:UIView){
        view.layer.cornerRadius = view.frame.width/2
        view.clipsToBounds = true
    }
    
    // MARK -
    // MARK: LocationManger Delegete
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if currentLocation == nil {
            currentLocation = locations.last!
        }
        if timeTracker.hasReachedMax(intervalToSave) && !hasSavedLocation {
            recordedLocationsCount++
            hasSavedLocation = true
        }

        print("distance", currentLocation!.distanceFromLocation(locations.last!))
        if currentLocation!.distanceFromLocation(locations.last!) >= 10 {
            timeTracker.reset()
            currentLocation = nil
        }
    }
}

extension CLLocation {
    func save(){
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
                let location = Location(lat:self.coordinate.latitude, long:self.coordinate.latitude,address:  address)
                try location.managedObjectContext?.save()
            } catch {
                print(error)
            }
            
        })
    }
}


