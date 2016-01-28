//
//  RealtorHomeViewController.swift
//  See-It-Pronto
//
//  Created by user114136 on 1/5/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class RealtorHomeViewController: UIViewController {

    var viewData:JSON = []
    @IBOutlet weak var mapContent: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        let url = NSURL (string: Config.APP_URL+"/real_state_property_basics/map/"+self.viewData["id"].stringValue);
        let requestObj = NSURLRequest(URL: url!);
        self.mapContent.loadRequest(requestObj);
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    }
    
}
