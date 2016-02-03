//
//  RealtorHomeViewController.swift
//  See-It-Pronto
//
//  Created by user114136 on 1/5/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class RealtorHomeViewController: UIViewController,UIWebViewDelegate {

    var viewData:JSON = []
    @IBOutlet weak var webView: UIWebView!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.delegate = self;
        loadMap()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = true
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        if (navigationController?.topViewController != self) {
            navigationController?.navigationBarHidden = false
        }
        super.viewWillDisappear(animated)
    }
    
    func loadMap() {
        let requestURL = NSURL(string:Config.APP_URL+"/real_state_property_basics/map/"+self.viewData["id"].stringValue)
        let request = NSURLRequest(URL: requestURL!)
        self.webView.loadRequest(request)
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.LinkClicked {
            return false
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    }
    
}
