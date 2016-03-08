//
//  FeedBack1ViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/6/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class FeedBack1ViewController: UIViewController {

    var viewData:JSON = []
    var showStartMessage:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(showStartMessage == true) {
         self.showIndications()
        }
    }
    
    func showIndications() {
     Utility().displayAlert(self, title: "Message", message: "The agent is on their way. When agent finishes show you the property, please complete the following feedback", performSegue: "")
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func btnBack(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
}
