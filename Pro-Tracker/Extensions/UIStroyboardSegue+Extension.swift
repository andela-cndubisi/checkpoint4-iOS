//
//  UIStroyboardSegue+Extension.swift
//  Pro-Tracker
//
//  Created by Chijioke Ndubisi on 6/17/16.
//  Copyright © 2016 andela-cj. All rights reserved.
//

import UIKit
extension UIStoryboardSegue {
    
    var storyBoardidentifier:UISegueIdentifier?{
        get { return UISegueIdentifier(rawValue:identifier!) }
    }
}

enum UISegueIdentifier:String {
    case Tracking = "SegueTracking"
}
