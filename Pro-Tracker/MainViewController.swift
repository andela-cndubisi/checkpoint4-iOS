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
    
    var locationManager:CLLocationManager!
    var coreDataStore:CoreDataStore!
    var setting = false
    let KEY = "INTERVAL"
    var startButton:UIButton!
    var slider:CircularSlider!
    private var interval = 5 {
        didSet{
            if !setting {
                intervalSettingsButton.setTitle("\(interval) minutes", for: UIControlState())
            }
        }
    }

    @IBAction func setInterval(_ sender: UIButton) {
        let userDefault = UserDefaults.standard()
        
        if !setting {
            UIView.transition(from: startButton, to: slider, duration: 0.3, options: .transitionFlipFromTop, completion: nil)
            setting = !setting
            sender.setTitle("Done", for: UIControlState())
        }else {
            UIView.transition(from: slider, to: startButton, duration: 0.3, options: .transitionFlipFromBottom, completion: nil)
            setting = !setting
            interval = Int(slider.value)
            sender.setTitle("\(interval) minutes", for: UIControlState())
            userDefault.set(interval, forKey: KEY)
            userDefault.synchronize()
        }
    }
    
    @IBAction func beginTracking(_ sender: UIButton) {
        let status  = LocationCoordinator.validateLocationManagerAuthorization()
        if status == 1 {
            performSegue(withIdentifier: "SegueTracking", sender: sender)
        }else if status == -1 {
            locationManager.requestAlwaysAuthorization()
            locationManager.delegate = self
        }else {
            present(showSettingAlert(), animated: true, completion: nil)
        }
    }
    
    @IBAction func showHistory(_ sender: UIBarButtonItem) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if LocationCoordinator.validateLocationManagerAuthorization() == 1 {
            performSegue(withIdentifier: "SegueTracking", sender: startButton)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController!.navigationBar.barStyle = .black
        navigationController!.navigationBar.barTintColor = UIColor(red:  16.0/225, green: 169.0/255, blue: 224.0/255, alpha: 1)
        setupStartButton()
        setupWheel()
        containerView.addSubview(startButton)
        slider.value = Double(interval)
    }
    
    override func viewDidLoad() {
        let userDefault = UserDefaults.standard()
        if let value = userDefault.value(forKey: KEY) as? NSNumber {
            interval = value.intValue
        }
    }
    
    func setupWheel(){
        slider = CircularSlider(frame: startButton.frame, currentValue: 5, minimumValue: 5, maximumValue: 60 )
        slider.trackWidth = slider.radius/2
        let colors = UIColor(red:  16.0/225, green: 169.0/255, blue: 224.0/255, alpha: 1)
        slider.trackColor = colors
        slider.fillColor = colors
        slider.thumb.strokeColor = .white()
        slider.thumb.fillColor = .white()
        slider.layer.cornerRadius = slider.bounds.width/2
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SegueTracking" {
            if let destinationViewController = segue.destinationViewController as? TrackingViewController {
                destinationViewController.intervalToSave = interval
                destinationViewController.coreDataStore = coreDataStore
                destinationViewController.locationManager = locationManager
            }
        }
    }
    
    func setupStartButton(){
        let length = min(containerView.bounds.width, containerView.bounds.height)/2 + 50
        let x = containerView.bounds.width/2 - length/2
        let y = containerView.bounds.height/2 - length/2
        
        startButton = UIButton(frame: CGRect(x: x, y: y, width: length, height: length))
        startButton.layer.cornerRadius = startButton.bounds.width / 2
        startButton.backgroundColor = UIColor(red:  16.0/225, green: 169.0/255, blue: 224.0/255, alpha: 1)
        startButton.setImage(UIImage(asset: .PlayButton), for:UIControlState())
        startButton.addTarget(self, action: #selector(beginTracking), for: .touchUpInside)
    }
    
    func showSettingAlert() -> UIViewController{
       let LocationAlert =  UIAlertController(title: "Location Services Disabled", message: "Enable Location Services in Setting to Continue", preferredStyle: .alert)
        LocationAlert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (actionview) -> Void in
            UIApplication.shared().openURL(URL(string:UIApplicationOpenSettingsURLString)!)
        }))
        LocationAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (actionview) -> Void in
            LocationAlert.dismiss(animated: true, completion: nil)
        }))
        return LocationAlert
    }
}
