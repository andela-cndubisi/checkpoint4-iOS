//
//  ViewController.swift
//  pro-tracker
//
//  Created by Chijioke Ndubisi on 19/11/2015.
//  Copyright © 2015 andela-cj. All rights reserved.
//

import UIKit
import CoreLocation

private var interval = 1

func getInterval() -> Int{
    return interval
}

class MainViewController: UIViewController, UIAlertViewDelegate{
    @IBOutlet weak var intervalSettingsButton: UIButton!
    var setting = false
    let KEY = "INTERVAL"
    var startButton:UIButton!
    var slider:CircularSlider!


    @IBOutlet weak var containerView: UIView!
    
    @IBAction func setInterval(sender: UIButton) {

        let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setInteger(5, forKey: KEY)
        userDefault.synchronize()
        
        if !setting {
            UIView.transitionFromView(startButton, toView: slider, duration: 0.3, options: .TransitionFlipFromTop, completion: nil)
            setting = !setting
            sender.setTitle("Done", forState: .Normal)
        }else {
            UIView.transitionFromView(slider, toView: startButton, duration: 0.3, options: .TransitionFlipFromBottom, completion: nil)
            setting = !setting
            let interval = slider.value
            sender.setTitle("\(Int(interval)) minutes", forState: .Normal)
        }
    }

    @IBAction func beginTracking(sender: UIButton) {
        print(appDelegate().validateLocationManagerAuthorization())
        if appDelegate().validateLocationManagerAuthorization() <= 1 {
            performSegueWithIdentifier("SegueTracking", sender: sender)
        }else {
            presentViewController(showSettingAlert(), animated: true, completion: nil)
        }
    }
    
    @IBAction func showHistory(sender: UIBarButtonItem) {
        
    }
    
    override func viewDidLayoutSubviews() {
        containerView.removeConstraints(containerView.constraints)
        containerView.translatesAutoresizingMaskIntoConstraints = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navigationController!.navigationBar.barStyle = .Black
        navigationController!.navigationBar.barTintColor = UIColor(red:  16.0/225, green: 169.0/255, blue: 224.0/255, alpha: 1)
        setupStartButton()
        setupWheel()
        containerView.addSubview(startButton)
        let userDefault = NSUserDefaults.standardUserDefaults()
        if let value = userDefault.valueForKey(KEY) as? NSNumber {
            interval = value.integerValue
        }
    }
    
    func setupWheel(){
        slider = CircularSlider(frame: startButton.frame, currentValue: 5, minimumValue: 5, maximumValue: 60 )
        slider.trackWidth = slider.radius/2
        slider.trackColor = UIColor(red:  16.0/225, green: 169.0/255, blue: 224.0/255, alpha: 0.5)
        slider.fillColor = UIColor(red:  16.0/225, green: 169.0/255, blue: 224.0/255, alpha: 1)
        slider.thumb.strokeColor = UIColor.whiteColor()
        slider.thumb.fillColor = UIColor.whiteColor()
        slider.layer.cornerRadius = slider.bounds.width/2
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

