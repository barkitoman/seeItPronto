//
//  ViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 12/18/15.
//  Copyright © 2015 user114136. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    private let internvalSeconds:NSTimeInterval = 3
    private var timer: NSTimer?
    var login = false
    
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
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func goToLogin() {
        if self.timer != nil { self.stopInterval()}
        login = automaticLogin()
        if (login == false) {
            self.performSegueWithIdentifier("showMap", sender: self)
            //self.performSegueWithIdentifier("ShowLogin", sender: self)
        }
    }
    
    func automaticLogin()->Bool {
        let userId = User().getField("id")
        let role   = User().getField("role")
        let accessToken = User().getField("access_token")
        var out = false
        if(!userId.isEmpty && !role.isEmpty && !accessToken.isEmpty) {
            if(role == "realtor") {
                let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                let viewController : ReadyToWorkViewController = mainStoryboard.instantiateViewControllerWithIdentifier("ReadyToWorkViewController") as! ReadyToWorkViewController
                self.navigationController?.showViewController(viewController, sender: nil)
                out = true
            } else if (role == "buyer") {
                let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                let viewController : BuyerHomeViewController = mainStoryboard.instantiateViewControllerWithIdentifier("BuyerHomeViewController") as! BuyerHomeViewController
                self.navigationController?.showViewController(viewController, sender: nil)
                out = true
            }
        }
        if(!userId.isEmpty && !role.isEmpty && accessToken.isEmpty) {
            User().deleteAllData()
        }
        return out
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showMap") {
            let view: BuyerHomeViewController = segue.destinationViewController as! BuyerHomeViewController
            view.session  = login
        }
    }
    
}

