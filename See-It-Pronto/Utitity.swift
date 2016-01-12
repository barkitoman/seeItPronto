//
//  Utitity.swift
//  See-It-Pronto
//
//  Created by user114136 on 1/11/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import Foundation
import UIKit

class Utility {

    //show alert dialog on screen
    func displayAlert(controller:UIViewController, title:String, message:String, performSegue:String){
        dispatch_async(dispatch_get_main_queue()) {
            let alertController = UIAlertController(title:title, message: message, preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                if performSegue != "" {
                    controller.performSegueWithIdentifier(performSegue, sender: self)
                }
            }
            alertController.addAction(okAction)
            controller.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}
