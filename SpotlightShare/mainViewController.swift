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
    fileprivate var logoText: UILabel!
    fileprivate var barGradientLayer: CAGradientLayer!
    
    fileprivate var locationManager: AMapLocationManager!
    fileprivate var mapView: MAMapView!
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.white
        
        locationManager = AMapLocationManager()
        locationManager.delegate = self
        locationManager.distanceFilter = 200
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingLocation()
        
        prepareMapView()
        prepareNavigationItem()
        
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mapView.userTrackingMode = MAUserTrackingMode.follow
        mapView.showsUserLocation = true
        mapView.showsCompass = false
    
        let r = MAUserLocationRepresentation()
        r.showsHeadingIndicator = true
        r.enablePulseAnnimation = true
        r.locationDotFillColor = myMainColor
        r.locationDotBgColor = rgba(1, 1, 1, 0.9)
        r.fillColor = rgba(0, 1, 0.686, 0.2)
        mapView.update(r)
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
        //mapView.allowsBackgroundLocationUpdates = true
        mapView.setZoomLevel(18.0, animated: true)
        mapView.delegate = self
        self.view.addSubview(mapView!)
    }
    
    fileprivate func prepareNavigationItem() {
        let sz = view.frame.size
        
        barGradientLayer = CAGradientLayer()
        barGradientLayer.frame = rect(0, sz.height / 4 * 3, sz.width, sz.height / 4)
        barGradientLayer.colors = [rgba(1, 1, 1, 0).cgColor, myMainColor.cgColor]
        barGradientLayer.masksToBounds = true
        view.layer.addSublayer(barGradientLayer)
        
        addButton = IconButton(image: UIImage(named: "up.png"))
        addButton.addTarget(self, action: #selector(menuButtonClick), for: .touchUpInside)
        
        logoText = UILabel()
        logoText.backgroundColor = rgba(1, 1, 1, 0)
        logoText.text = "SpotLight"
        logoText.textColor = rgba(1, 1, 1, 1)
        logoText.font = UIFont(name: "Arial Rounded MT Bold", size: 28)
        view.layout(logoText).bottom(20).left(20)
        
        navigationItem.title = ""
        navigationItem.titleLabel.textColor = Color.lightBlue.darken4
        navigationItem.titleLabel.font = UIFont(name: "Arial Rounded MT Bold", size: 20)
        //navigationItem.detail = "Exchange your feelings."
        //navigationItem.rightViews = [addButton]
        
        view.layout(addButton).bottom(15).right(30).width(30).height(40)
    }
}

extension mainViewController {
    @objc
    fileprivate func menuButtonClick() {
        self.present(arViewController(), animated: true)
    }
}

extension mainViewController {
    func amapLocationManager(_ manager: AMapLocationManager!, didUpdate location: CLLocation!, reGeocode: AMapLocationReGeocode?) {
        myPosition.savePos(location)
        debugPrint(location.coordinate)
    }
    
    func mapView(_ mapView: MAMapView!, didTouchPois pois: [Any]!) {
        debugPrint(pois)
    }
    
    
}
