//
//  editingViewController.swift
//  SpotlightShare
//
//  Created by NHibiki on 08/07/2017.
//  Copyright © 2017 NHibiki. All rights reserved.
//

import Material

class editingViewController: UIViewController {
    
    fileprivate var postButton: IconButton!
    fileprivate var closeButton: IconButton!
    
    fileprivate var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.white
        
        prepareNavigationItem()
        prepareWebView()
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
        webView.loadRequest(URLRequest(url: URL(string: "http://nekoyu.cc")!))
        
        view.addSubview(webView)
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
