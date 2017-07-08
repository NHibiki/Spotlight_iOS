//
//  MainViewController.swift
//  SpotlightShare
//
//  Created by NHibiki on 08/07/2017.
//  Copyright © 2017 NHibiki. All rights reserved.
//

import Foundation
import UIKit
import Material

class mainViewController: UIViewController, AMapLocationManagerDelegate, MAMapViewDelegate {
    
    fileprivate var addButton: IconButton!
    fileprivate var barGradientLayer: CAGradientLayer!
    
    fileprivate var locationManager: AMapLocationManager!
    fileprivate var mapView: MAMapView!
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.white
        
        locationManager = AMapLocationManager()
        locationManager.delegate = self
        locationManager.distanceFilter = 200
        locationManager.pausesLocationUpdatesAutomatically = true
        
        locationManager.startUpdatingLocation()
        
        prepareMapView()
        prepareNavigationItem()
        
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = MAUserTrackingMode.follow
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .default
        }
    }
    
}

extension mainViewController {
    fileprivate func prepareMapView() {
        mapView = MAMapView(frame: self.view.bounds)
        mapView.delegate = self
        self.view.addSubview(mapView!)
    }
    
    fileprivate func prepareNavigationItem() {
        let sz = view.frame.size
        
        addButton = IconButton(image: Icon.cm.add, tintColor: Color.lightBlue.darken4)
        addButton.addTarget(self, action: #selector(menuButtonClick), for: .touchUpInside)
        
        barGradientLayer = CAGradientLayer()
        barGradientLayer.frame = rect(0, sz.height / 5 * 4, sz.width, sz.height / 5)
        barGradientLayer.colors = [rgba(1, 1, 1, 0).cgColor, myMainColor.cgColor]
        barGradientLayer.masksToBounds = true
        view.layer.addSublayer(barGradientLayer)
        
        
        navigationItem.title = ""
        navigationItem.titleLabel.textColor = Color.lightBlue.darken4
        navigationItem.titleLabel.font = UIFont(name: "Arial Rounded MT Bold", size: 20)
        //navigationItem.detail = "Exchange your feelings."
        
        navigationItem.rightViews = [addButton]
    }
}

extension mainViewController {
    @objc
    fileprivate func menuButtonClick() {
        
    }
}

extension mainViewController {
    func amapLocationManager(_ manager: AMapLocationManager!, didUpdate location: CLLocation!, reGeocode: AMapLocationReGeocode?) {
        NSLog("location:{lat:\(location.coordinate.latitude); lon:\(location.coordinate.longitude); accuracy:\(location.horizontalAccuracy);};");
        
        if let reGeocode = reGeocode {
            NSLog("reGeocode:%@", reGeocode)
        }
    }
}
