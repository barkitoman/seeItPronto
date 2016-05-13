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
        if btnGPS.enabled {
            /*Notification.askPermission()
            var manager: OneShotLocationManager?
            manager = OneShotLocationManager()
            manager!.fetchWithCompletion {location, error in
                // fetch location or an error
                if let loc = location {
                    print(loc.coordinate.latitude)
                    print(loc.coordinate.longitude)
                } else if let _ = error {
                    print("ERROR GETTING LOCATION")
                }
                // destroy the object immediately to save memory
                manager = nil
            }*/

        }else
        {
            
        }
        
    }
    
    @IBAction func pushEnabled(sender: AnyObject) {
        if btnPUSH.enabled {
            
        }else
        {
            
        }
    }
    
    //
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
