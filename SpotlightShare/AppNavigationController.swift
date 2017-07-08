//
//  AppNavigationController.swift
//  iBiu
//
//  Created by NHibiki on 22/06/2017.
//  Copyright © 2017 NHibiki. All rights reserved.
//

import UIKit
import Material

class AppNavigationController: NavigationController {
    
    fileprivate var infoBar :UIView!
    fileprivate var infoLabel :UILabel!
    fileprivate var myTop :CGFloat = 0
    fileprivate var myTimer :Timer!
    fileprivate var myHeight :CGFloat = 0
    
    open override func prepare() {
        super.prepare()
        guard let v = navigationBar as? NavigationBar else {
            return
        }
        
        v.depthPreset = .none
        v.dividerColor = .clear
        v.backgroundColor = .clear
        v.isTranslucent = true
        myHeight = v.frame.size.height
        v.frame.size.height = 0
        
        prepareInfoBar(v.frame.size.height)
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .default
        }
    }
    
    fileprivate func prepareInfoBar(_ h: CGFloat) {
        let sz = view.frame.size
        
        myTop = h + CGFloat(28)
        infoBar = UIView(frame: rect(5, -50, sz.width - CGFloat(10), 50))
        infoBar.backgroundColor = Color.lightGreen.lighten4
        infoBar.layer.cornerRadius = 15
        infoBar.layer.masksToBounds = true
        let myTouch = UITapGestureRecognizer(target: self, action: #selector(onTouch))
        infoBar.addGestureRecognizer(myTouch)
        view.addSubview(infoBar)
        
        infoLabel = UILabel(frame: rect(10, 0, sz.width - CGFloat(20), 50))
        infoLabel.font = UIFont(name: "Arial Rounded MT Bold", size: 16)
        infoLabel.textAlignment = .center
        infoLabel.text = ""
        let myTouch2 = UITapGestureRecognizer(target: self, action: #selector(onTouch))
        infoLabel.addGestureRecognizer(myTouch2)
        infoBar.addSubview(infoLabel)
    }
    
    public func showBar(_ bool: Bool, _ color: UIColor = .clear) {
        guard let v = navigationBar as? NavigationBar else {
            return
        }
        v.backgroundColor = color
        if bool {
            v.frame.size.height = myHeight
            v.isTranslucent = false
        } else {
            v.frame.size.height = 0
            v.isTranslucent = true
        }
    }
    
    public func showInfo(_ text: String, _ color: UIColor, _ duration: Double) {
        infoLabel.text = text
        infoBar.backgroundColor = color
        let sz = view.frame.size
        UIView.animate(withDuration: 0.5) {
            self.infoBar.frame = rect(5, self.myTop, sz.width - CGFloat(10), 50)
            self.infoBar.opacity = 1
        }
        
        myTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false, block: { theTimer in
            self.hideInfo()
            guard let timer = self.myTimer else {
                return
            }
            timer.invalidate()
        })
    }
    
    public func hideInfo() {
        let sz = view.frame.size
        UIView.animate(withDuration: 0.5) {
            self.infoBar.frame = rect(5, -50, sz.width - CGFloat(10), 50)
            self.infoBar.opacity = 0
        }
    }
    
    @objc
    fileprivate func onTouch() {
        self.hideInfo()
    }
}
