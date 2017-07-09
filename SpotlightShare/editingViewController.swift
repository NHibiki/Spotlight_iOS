//
//  editingViewController.swift
//  SpotlightShare
//
//  Created by NHibiki on 08/07/2017.
//  Copyright © 2017 NHibiki. All rights reserved.
//

import Material
import JavaScriptCore

class editingViewController: UIViewController {
    
    fileprivate var postButton: IconButton!
    fileprivate var closeButton: IconButton!
    
    fileprivate var webView: UIWebView!
    fileprivate var progressTimer: Timer!
    
    fileprivate var jsContext: JSContext!
    fileprivate let webViewHandler: @convention(block) (String, String) -> Void = { content, file in
        //NotificationCenter.default.post(name: NSNotification.Name("didReceiveRandomNumbers"), object: luckyNumbers)
        // Username(nil indicates login), Email, Password
        
        var spot = Spot()
        spot.data = content
        spot.position = myPosition
        spot.dataType = 0
        spot.timeStamp = getTimeStamp()
        sendPosts(spot, { status in
            if status {
                globalOrder = "OFF"
                getPosts{ spots in
                    aroundSpots = spots
                }
            }
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.white
        
        prepareNavigationItem()
        prepareWebView()
        prepareDetectTimer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        (navigationController as! AppNavigationController).showBar(false)
        super.viewDidDisappear(animated)
    }
}

extension editingViewController {
    @objc
    fileprivate func updateOrd() {
        if globalOrder == "OFF" {
            globalOrder = ""
            self.dismiss(animated: true)
        }
        
    }
    fileprivate func shutDetectTimer() {
        guard let timer = progressTimer else {
            return
        }
        timer.invalidate()
    }
    fileprivate func prepareDetectTimer() {
        shutDetectTimer()
        progressTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(updateOrd), userInfo: nil, repeats: true)
    }
    fileprivate func prepareNavigationItem() {
        
        (navigationController as! AppNavigationController).showBar(true, myMainColor)
        postButton = IconButton(image: Icon.edit, tintColor: Color.white)
        closeButton = IconButton(image: Icon.close, tintColor: Color.white)
        postButton.addTarget(self, action: #selector(postButtonClick), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeButtonClick), for: .touchUpInside)
        
        navigationItem.title = "Spotlight"
        navigationItem.detail = ""
        navigationItem.titleLabel.font = UIFont(name: "Arial Rounded MT Bold", size: 18)
        
        navigationItem.leftViews = [closeButton]
        //navigationItem.rightViews = [postButton]
    }
    
    fileprivate func prepareWebView() {
        let sz = view.frame.size
        webView = UIWebView(frame: rect(0, 0, sz.width, sz.height - 68))
        webView.scrollView.bounces = false
        view.addSubview(webView)
        
        prepareJS()
    }
    
    fileprivate func prepareJS() {
        jsContext = webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as! JSContext
        
        let webControlJs = unsafeBitCast(self.webViewHandler, to: AnyObject.self)
        jsContext.setObject(webControlJs, forKeyedSubscript: "submitPost" as(NSCopying & NSObjectProtocol))
        jsContext.evaluateScript("submitPost")
        
        webView.loadRequest(URLRequest(url: URL(string: ApiBase + "editor")!))
    }
}

extension editingViewController {
    @objc
    fileprivate func postButtonClick() {
        
    }
    
    @objc
    fileprivate func closeButtonClick() {
        self.dismiss(animated: true)
    }
    
}
