//
//  ViewController.swift
//  See-It-Pronto
//
//  Created by user114136 on 12/18/15.
//  Copyright © 2015 user114136. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private let internvalSeconds:NSTimeInterval = 5
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
        self.performSegueWithIdentifier("ShowLogin", sender: self)
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

