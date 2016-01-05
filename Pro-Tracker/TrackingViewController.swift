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
    
    private var play:UIButton!
    private var stop:UIButton!
    private var controlsContainer:UIView!
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
            pauseTracker()
        }
    }
    var backgroundMask:UIView!

    func pauseTracker(){
        timeTracker.pause()

        play.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.8)
        stop.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.8)
        
        stop.setImage(UIImage(named: "stop.png"), forState: .Normal)
        play.setImage(UIImage(named: "play.png"), forState: .Normal )
        
        play.layer.cornerRadius = play.bounds.width/2
        stop.layer.cornerRadius = stop.bounds.width/2
        
        backgroundMask.backgroundColor = UIColor.blackColor()
        
        self.controlsContainer.addSubview(play)
        self.controlsContainer.addSubview(stop)
        self.view.insertSubview(backgroundMask, belowSubview: self.controlsContainer)

        UIView.animateWithDuration(0.15, animations: { () -> Void in
            let offset:CGFloat = 30
            self.backgroundMask.alpha = 0.6
            self.pauseButton.alpha = 0
            self.play.frame.origin.x += self.dimension
            self.play.frame.origin.y += offset
            self.stop.frame.origin.x -= self.dimension
            self.stop.frame.origin.y += offset
            self.stop.alpha = 1
            self.play.alpha = 1

        })
    }
    var dimension:CGFloat! {
        get {
            return pauseButton.bounds.width/2
        }
    }

    func resumeTracker(){
        timeTracker.resume()

        let offset:CGFloat = 30
       UIView.animateWithDuration(0.15, animations: { _ in
            self.backgroundMask.alpha = 0
            self.pauseButton.alpha = 1
            self.play.frame.origin.x -= self.dimension
            self.play.frame.origin.y -= offset
            self.stop.frame.origin.x += self.dimension
            self.stop.frame.origin.y -= offset
            }) { (_) -> Void in
                self.backgroundMask.removeFromSuperview()
                self.play.removeFromSuperview()
                self.stop.removeFromSuperview()
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let frame =  CGRect(
            x:controlsContainer.frame.width/2 - dimension/2,
            y: controlsContainer.frame.height/2 - dimension/2,
            width: dimension,
            height:dimension)

        controlsContainer = pauseButton.superview
        backgroundMask = UIView(frame: view.frame)
        
        play = UIButton(frame: frame)
        play.addTarget(self, action: "resumeTracker", forControlEvents: .TouchUpInside)
        play.alpha = 0
        
        stop = UIButton(frame: frame)
        stop.alpha = 0
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


