//
//  globalFunc.swift
//  SpotlightShare
//
//  Created by NHibiki on 08/07/2017.
//  Copyright © 2017 NHibiki. All rights reserved.
//

import Foundation
import Material
import SwiftyJSON
import UIKit

public class Position {
    public var lo: Double = 0.0
    public var la: Double = 0.0
    public var ho: Double = 0.0
    public var ve: Double = 0.0
    
    init() {
        lo = 0.0
        la = 0.0
        ho = 0.0
        ve = 0.0
    }
    
    public func savePos(_ loc: CLLocation!) {
        lo = loc.coordinate.longitude
        la = loc.coordinate.latitude
    }
    
    public func saveSens(_ accz: Double, _ dir: Double) {
        ho = dir
        ve = accz
    }
    
    public func getData() -> JSON {
        let myJson = JSON(parseJSON: "{\"lo\":\(lo), \"la\":\(la), \"ho\":\(ho), \"ve\":\(ve)}")
        return myJson
    }
}

public func doOrder(_ order: String, _ window: UIWindow) {
    
}

public func rect(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
    return CGRect(x: x, y: y, width: width, height: height)
}

public func rgba(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) -> UIColor {
    return Color.init(red: red, green: green, blue: blue, alpha: alpha)
}

