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
    
    func showPhoto(img:UIImageView, imgPath:String){
        let url = NSURL(string: Config.APP_URL+"/"+imgPath)
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) -> Void in
            if error != nil {
                print("ERROR SHOWING IMAGE "+imgPath)
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    img.image = UIImage(data: data!)
                }
            }
        }
        task.resume()
    }
    
    func defaultMenuImage() -> UIImage {
        var defaultMenuImage = UIImage()
        struct Static {
            static var onceToken: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.onceToken, { () -> Void in
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(30, 22), false, 0.0)
            
            UIColor.blackColor().setFill()
            UIBezierPath(rect: CGRectMake(0, 3, 30, 1)).fill()
            UIBezierPath(rect: CGRectMake(0, 10, 30, 1)).fill()
            UIBezierPath(rect: CGRectMake(0, 17, 30, 1)).fill()
            
            UIColor.whiteColor().setFill()
            UIBezierPath(rect: CGRectMake(0, 4, 30, 1)).fill()
            UIBezierPath(rect: CGRectMake(0, 11,  30, 1)).fill()
            UIBezierPath(rect: CGRectMake(0, 18, 30, 1)).fill()
            
            defaultMenuImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
        })
        return defaultMenuImage;
    }
}
