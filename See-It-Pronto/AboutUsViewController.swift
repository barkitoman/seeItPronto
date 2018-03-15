//
//  AboutUsViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 8/25/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class AboutUsViewController: UIViewController,UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadAboutPage()
    }
    
    func loadAboutPage() {
        self.webView.delegate = self
        let url = AppConfig.ABOUT_URL
        let requestURL = URL(string:url)
        let request = URLRequest(url: requestURL!)
        self.webView.loadRequest(request)
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if (navigationController?.topViewController != self) {
            navigationController?.isNavigationBarHidden = false
        }
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnBack(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }
    

}
