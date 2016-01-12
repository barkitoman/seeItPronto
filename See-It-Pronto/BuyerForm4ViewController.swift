//
//  BuyerForm4ViewController.swift
//  See-It-Pronto
//
//  Created by user114136 on 1/4/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class BuyerForm4ViewController: UIViewController {

    var viewData:JSON = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "FromBuyerForm4") {
    
        }
    }

}
