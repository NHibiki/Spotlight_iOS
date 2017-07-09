
//
//  loginViewController.swift
//  SpotlightShare
//
//  Created by NHibiki on 08/07/2017.
//  Copyright © 2017 NHibiki. All rights reserved.
//


import Material
import JavaScriptCore

class loginViewController: UIViewController {
    
    fileprivate var postButton: IconButton!
    fileprivate var closeButton: IconButton!
    
    fileprivate var webView: UIWebView!
    fileprivate var progressTimer: Timer!
    
    fileprivate var jsContext: JSContext!
    fileprivate let webViewHandler: @convention(block) (String, String, String) -> Void = { un, id, passwd in
        //NotificationCenter.default.post(name: NSNotification.Name("didReceiveRandomNumbers"), object: luckyNumbers)
        // Username(nil indicates login), Email, Password
        if un == "" {
            debugPrint("Login")
            loginAction("login", id, passwd) { status in
                globalOrder = "OFF"
            }
        } else {
            debugPrint("Register")
            loginAction("register", id, passwd, un) { status in
                globalOrder = "OFF"
            }
        }
        
    }
    
    fileprivate let navToHandler: @convention(block) (String) -> Void = { url in
        //NotificationCenter.default.post(name: NSNotification.Name("didReceiveRandomNumbers"), object: luckyNumbers)
        // Username(nil indicates login), Email, Password
        
        globalSurf = url
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.white
        
        globalSurf = "login"
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

extension loginViewController {
    @objc
    fileprivate func updateOrd() {
        if globalSurf != "" {
            prepareJS()
        }
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
        
        navigationItem.title = "Login"
        navigationItem.detail = "login / register"
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
        jsContext.setObject(webControlJs, forKeyedSubscript: "loginAction" as(NSCopying & NSObjectProtocol))
        jsContext.evaluateScript("loginAction")
        let webControlNav = unsafeBitCast(self.navToHandler, to: AnyObject.self)
        jsContext.setObject(webControlNav, forKeyedSubscript: "navTo" as(NSCopying & NSObjectProtocol))
        jsContext.evaluateScript("navTo")
        
        webView.loadRequest(URLRequest(url: URL(string: ApiBase + globalSurf)!))
        globalSurf = ""
    }
}

extension loginViewController {
    @objc
    fileprivate func postButtonClick() {
        
    }
    
    @objc
    fileprivate func closeButtonClick() {
        self.dismiss(animated: true)
    }
    
}
