//
//  UIImage+Extension.swift
//  Pro-Tracker
//
//  Created by Chijioke Ndubisi on 6/10/16.
//  Copyright © 2016 andela-cj. All rights reserved.
//

import UIKit

enum ImageAsset:String {
    case PlayButton = "play.png"
}

extension UIImage{
    convenience init(asset:ImageAsset) {
        self.init(named: asset.rawValue)!
    }
}
