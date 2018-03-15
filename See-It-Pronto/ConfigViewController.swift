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
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func fnBack(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func gpsEnabled(_ sender: AnyObject) {
        DispatchQueue.main.async {
            let alertController = UIAlertController (title: "Message", message: "See It Pronto! requires certain functions enabled to work properly: GPS and Push Notifications. Click the Settings button to open it up so you can enable them.", preferredStyle: .alert)
        
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                //let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
                UIApplication.shared.openURL(URL(string:"prefs:root=LOCATION_SERVICES")!)
                //UIApplication.sharedApplication().openURL(url)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertController.addAction(settingsAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil);
        }
    }
    
    @IBAction func pushEnabled(_ sender: AnyObject) {
        DispatchQueue.main.async {
            let alertController = UIAlertController (title: "Message", message: "See It Pronto! requires certain functions enabled to work properly: GPS and Push Notifications. Click the Settings button to open it up so you can enable them.", preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                //let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
                UIApplication.shared.openURL(URL(string:"prefs:root=NOTIFICATIONS_ID")!)
                //UIApplication.sharedApplication().openURL(url)
            }
        
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertController.addAction(settingsAction)
            alertController.addAction(cancelAction)
        
            self.present(alertController, animated: true, completion: nil);
        }
    }
    
}
