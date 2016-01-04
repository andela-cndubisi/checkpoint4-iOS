//
//  ViewController.swift
//  pro-tracker
//
//  Created by Chijioke Ndubisi on 19/11/2015.
//  Copyright © 2015 cjay. All rights reserved.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController, UIAlertViewDelegate, CLLocationManagerDelegate{
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var intervalSettingsButton: UIButton!
    
    var setting = false
    let KEY = "INTERVAL"
    var startButton:UIButton!
    var slider:CircularSlider!
    private var interval = 5 {
        didSet{
            if !setting {
                intervalSettingsButton.setTitle("\(interval) minutes", forState: .Normal)
            }
        }
    }

    @IBAction func setInterval(sender: UIButton) {

        let userDefault = NSUserDefaults.standardUserDefaults()
        
        if !setting {
            UIView.transitionFromView(startButton, toView: slider, duration: 0.3, options: .TransitionFlipFromTop, completion: nil)
            setting = !setting
            sender.setTitle("Done", forState: .Normal)
        }else {
            UIView.transitionFromView(slider, toView: startButton, duration: 0.3, options: .TransitionFlipFromBottom, completion: nil)
            setting = !setting
            interval = Int(slider.value)
            sender.setTitle("\(interval) minutes", forState: .Normal)
            userDefault.setInteger(interval, forKey: KEY)
            userDefault.synchronize()
        }
    }
    @IBAction func beginTracking(sender: UIButton) {
        let status  = appDelegate().validateLocationManagerAuthorization()
        if status == 1 {
            performSegueWithIdentifier("SegueTracking", sender: sender)
        }else if status == -1 {
            appDelegate().locationManager.requestAlwaysAuthorization()
            appDelegate().locationManager.delegate = self
        }else {
            presentViewController(showSettingAlert(), animated: true, completion: nil)
        }
    }
    
    @IBAction func showHistory(sender: UIBarButtonItem) {
        
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if appDelegate().validateLocationManagerAuthorization() == 1 {
            performSegueWithIdentifier("SegueTracking", sender: startButton)
        }
    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navigationController!.navigationBar.barStyle = .Black
        navigationController!.navigationBar.barTintColor = UIColor(red:  16.0/225, green: 169.0/255, blue: 224.0/255, alpha: 1)
        setupStartButton()
        setupWheel()
        containerView.addSubview(startButton)
        slider.value = Double(interval)
    }
    
    override func viewDidLoad() {
        let userDefault = NSUserDefaults.standardUserDefaults()
        if let value = userDefault.valueForKey(KEY) as? NSNumber {
            interval = value.integerValue
        }
    }
    
    func setupWheel(){
        slider = CircularSlider(frame: startButton.frame, currentValue: 5, minimumValue: 5, maximumValue: 60 )
        slider.trackWidth = slider.radius/2
        let colors = UIColor(red:  16.0/225, green: 169.0/255, blue: 224.0/255, alpha: 1)
        slider.trackColor = colors
        slider.fillColor = colors
        slider.thumb.strokeColor = UIColor.whiteColor()
        slider.thumb.fillColor = UIColor.whiteColor()
        slider.layer.cornerRadius = slider.bounds.width/2
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SegueTracking" {
            if let destinationViewController = segue.destinationViewController as? TrackingViewController {
                destinationViewController.intervalToSave = interval
            }
        }
    }
    
    func setupStartButton(){
        let length = min(containerView.bounds.width, containerView.bounds.height)/2 + 50
        let x = containerView.bounds.width/2 - length/2
        let y = containerView.bounds.height/2 - length/2
        
        startButton = UIButton(frame: CGRectMake(x, y, length, length))
        startButton.layer.cornerRadius = startButton.bounds.width / 2
        startButton.backgroundColor = UIColor(red:  16.0/225, green: 169.0/255, blue: 224.0/255, alpha: 1)
        startButton.setImage(UIImage(named: "play.png"), forState:.Normal)
        startButton.addTarget(self, action: "beginTracking:", forControlEvents: .TouchUpInside)        
    }
    
    func showSettingAlert() -> UIViewController{
       let LocationAlert =  UIAlertController(title: "Location Services Disabled", message: "Enable Location Services in Setting to Continue", preferredStyle: .Alert)
        LocationAlert.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { (actionview) -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!)
        }))
        LocationAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (actionview) -> Void in
            LocationAlert.dismissViewControllerAnimated(true, completion: nil)
        }))
        return LocationAlert
    }
}

