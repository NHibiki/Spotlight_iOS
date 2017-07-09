//
//  AppDelegate.swift
//  SpotlightShare
//
//  Created by NHibiki on 08/07/2017.
//  Copyright © 2017 NHibiki. All rights reserved.
//

import UIKit
import Material

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        
        readUserInfoFromFile()
        AMapServices.shared().apiKey = myNavKey
        
        window = UIWindow(frame: Screen.bounds)
        window!.rootViewController = appSuperBarController
        window!.makeKeyAndVisible()
        globalSize = window!.frame.size
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let urlString = url.absoluteString
        let theSep = urlString.characters.split(separator: "#")
        if theSep.count > 1 {
            let theOrderSep = theSep[1].split(separator: "/").map(String.init)
            if theOrderSep.count > 0 {
                let theOrder = theOrderSep[theOrderSep.count - 1]
                doOrder(theOrder, window!)
            }
        }
        return true
    }
}

