//
//  ConfigViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 5/12/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class ConfigViewController: UIViewController {

    @IBOutlet weak var btnGPS: UISwitch!
    @IBOutlet weak var btnPUSH: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func fnBack(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func gpsEnabled(sender: AnyObject) {
        
        let alertController = UIAlertController (title: "Title", message: "Go to Settings?", preferredStyle: .Alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .Default) { (_) -> Void in
            //let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
            
                UIApplication.sharedApplication().openURL(NSURL(string:"prefs:root=LOCATION_SERVICES")!)
                //UIApplication.sharedApplication().openURL(url)
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil);
        
        
        
    }
    
    @IBAction func pushEnabled(sender: AnyObject) {
        let alertController = UIAlertController (title: "Title", message: "Go to Settings?", preferredStyle: .Alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .Default) { (_) -> Void in
            //let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
            UIApplication.sharedApplication().openURL(NSURL(string:"prefs:root=NOTIFICATIONS_ID")!)
            //UIApplication.sharedApplication().openURL(url)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil);
    }
    
}
