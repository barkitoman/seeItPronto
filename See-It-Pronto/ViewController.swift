//
//  ViewController.swift
//  See-It-Pronto
//
//  Created by user114136 on 12/18/15.
//  Copyright © 2015 user114136. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    private let internvalSeconds:NSTimeInterval = 4
    private var timer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startSetInterval()
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
    
    func goToLogin() {
        if self.timer != nil { self.stopInterval()}
        automaticLogin()
        self.performSegueWithIdentifier("ShowLogin", sender: self)
    }
    
    func automaticLogin() {
        let user   = User().find()
        let obj    = user[0] as! NSManagedObject
        let userId = obj.valueForKey("id") as! String
        let role   = obj.valueForKey("role") as! String
        if(!userId.isEmpty && !role.isEmpty) {
            if(role == "realtor") {
                let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                let vc : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("RealtorHomeViewController") as UIViewController
                self.presentViewController(vc, animated: true, completion: nil)
            }else if (role == "buyer") {
                let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                let vc : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("BuyerHomeViewController") as UIViewController
                self.presentViewController(vc, animated: true, completion: nil)
            }
        }
    }
    
    func startSetInterval() {
        if self.timer != nil { self.stopInterval()}
        self.timer = NSTimer.scheduledTimerWithTimeInterval(self.internvalSeconds,
            target:self,
            selector:Selector("goToLogin"),
            userInfo:nil,
            repeats:true)
    }
    
    func stopInterval() {
        self.timer!.invalidate()
    }


}

