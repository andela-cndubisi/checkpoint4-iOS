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

class TrackingViewController: UIViewController {
    
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
    private var backgroundMask:UIView!

    private var recordedLocationsCount = 0 {
        didSet{
            locationCount.text = String(recordedLocationsCount)
        }
    }
    private var hasSavedLocation = false {
        didSet{
            if (oldValue == false){
                currentLocation?.save(coreDataStore.managedObjectContext)
            }
        }
    }
    var dimension:CGFloat! {
        return pauseButton.bounds.width/2
    }
    var coreDataStore:CoreDataStore!
    var intervalToSave:Int!
    var locationManager:CLLocationManager!

    
    @IBAction func showHistory(_ sender: UIBarButtonItem) {

    }
    
    @IBAction func pauseTracking(_ sender: UIButton) {
        if !timeTracker.isPaused() {
            pauseTracker()
        }
    }

    func pauseTracker(){
        timeTracker.pause()

        play.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.8)
        stop.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.8)
        
        play.layer.cornerRadius = play.bounds.width/2
        stop.layer.cornerRadius = stop.bounds.width/2
        
        backgroundMask.backgroundColor = UIColor.black()
        


        UIView.animate(withDuration: 0.15, animations: {() -> Void in

            let offset:CGFloat = 30
            self.backgroundMask.alpha = 0.6
            self.pauseButton.alpha = 0
            self.play.frame.origin.x += self.dimension
            self.play.frame.origin.y += offset
            self.stop.frame.origin.x -= self.dimension
            self.stop.frame.origin.y += offset
            self.stop.alpha = 1
            self.play.alpha = 1

            }, completion:{ completed in
                self.play.removeFromSuperview()
                self.stop.removeFromSuperview()
                self.backgroundMask.removeFromSuperview()
            })
    }

    func resumeTracker(){
        timeTracker.resume()

        let offset:CGFloat = 30
       UIView.animate(withDuration: 0.15, animations: { _ in
            self.backgroundMask.alpha = 0
            self.pauseButton.alpha = 1
            self.play.frame.origin.x -= self.dimension
            self.play.frame.origin.y -= offset
            self.stop.frame.origin.x += self.dimension
            self.stop.frame.origin.y -= offset
            }) { _ in
                self.backgroundMask.removeFromSuperview()
                self.play.removeFromSuperview()
                self.stop.removeFromSuperview()
        }
    }

    // MARK -
    // MARK: View Life Cycle
    override func viewDidLoad() {
        self.navigationItem.hidesBackButton = true
        timeTracker.delegate = self
        timeTracker.start()
        
        // setup LocationManager
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // customizeView
        addCornerRadius(toView: pauseButton, withCornerRadius: pauseButton.bounds.size.width/2, clipToBounds: true)
        addCornerRadius(toView: locationCount, withCornerRadius: locationCount.bounds.size.width/2, clipToBounds: true)
        recordedLocations.layer.cornerRadius = 20
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        controlsContainer = pauseButton.superview
        let frame =  CGRect(
            x:controlsContainer.frame.width/2 - dimension/2,
            y: controlsContainer.frame.height/2 - dimension/2,
            width: dimension, height:dimension)
        backgroundMask = UIView(frame: view.frame)
        
        play = UIButton(frame: frame)
        play.addTarget(self, action: #selector(resumeTracker), for: .touchUpInside)
        play.setImage(UIImage(named: "play.png"), for: UIControlState() )
        play.alpha = 0
        
        stop = UIButton(frame: frame)
        stop.setImage(UIImage(named: "stop.png"), for: UIControlState())
        stop.alpha = 0

    }

    private func addCornerRadius(toView: UIView, withCornerRadius radius:CGFloat, clipToBounds clip:Bool){
        toView.layer.cornerRadius = radius
        toView.clipsToBounds = clip
    }

}

// MARK -
// MARK: LocationManger Delegete
extension TrackingViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if currentLocation == nil {
            currentLocation = locations.last!
        }
        if timeTracker.hasReachedMax(intervalToSave) && !hasSavedLocation {
            recordedLocationsCount += 1
            hasSavedLocation = true
        }
        
        print("distance", currentLocation!.distance(from: locations.last!))
        if currentLocation!.distance(from: locations.last!) >= 10 {
            timeTracker.reset()
            currentLocation = nil
        }
    }
}

// MARK -
// MARK: TimeTrackerDelegate
extension TrackingViewController:TimeTrackerDelegate {
    

    func handleTime(_ milliseconds:Double){
        //calculate the minutes in elapsed time.
        var elapsedTime = milliseconds
        let minutes = UInt8(elapsedTime / 60.0)
        //calculate the seconds in elapsed time.
        elapsedTime -= (TimeInterval(minutes) * 60)
        let seconds = UInt32(elapsedTime)
        elapsedTime -= TimeInterval(seconds)
        //find out the fraction of milliseconds to be displayed.
        secondsLabel.text = String(format: "%02d", seconds)
        minuteLabel.text = String(format: "%02d", minutes)
    }
    
}
