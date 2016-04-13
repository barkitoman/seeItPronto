//
//  Utitity.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/11/16.
//  Copyright © 2016 Deyson. All rights reserved.
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
        var url = NSURL(string: AppConfig.APP_URL+"/"+imgPath)
        if (imgPath.rangeOfString("http://") != nil || imgPath.rangeOfString("https://") != nil ){
            url = NSURL(string: imgPath)
        }
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) -> Void in
            if error != nil {
                print("ERROR SHOWING IMAGE "+imgPath)
            } else {
                if let httpResponse = response as? NSHTTPURLResponse {
                    if(httpResponse.statusCode == 200) {
                        dispatch_async(dispatch_get_main_queue()) {
                            img.image = UIImage(data: data!)
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    func formatCurrency(var currentString : String)->String  {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        formatter.maximumFractionDigits = 0 //remove cents
        let numberFromField = (NSString(string: currentString ).doubleValue)
        currentString  = formatter.stringFromNumber(numberFromField)!
        return currentString
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
    
    func switchValue(sw:UISwitch,onValue:String,offValue:String)->String{
        if(sw.on) {
            return onValue
        }
        return offValue
    }
    
    func sliderValue(sl:UISlider)->String{
        return String(Int(roundf(sl.value)))
    }
    
    func getIdFromUrl(url:String)->String{
        var id = url.stringByReplacingOccurrencesOfString(AppConfig.APP_URL, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        id     = id.stringByReplacingOccurrencesOfString("http:",  withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        id     = id.stringByReplacingOccurrencesOfString("map",  withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        id     = id.stringByReplacingOccurrencesOfString("/",      withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        id     = id.stringByReplacingOccurrencesOfString("#",      withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        id     = id.stringByReplacingOccurrencesOfString("?",      withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        id     = id.stringByReplacingOccurrencesOfString(" ",      withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        return id
    }
    
    func getCurrentDate(separator:String)->String {
        let date       = NSDate()
        let calendar   = NSCalendar.currentCalendar()
        let components = calendar.components([.Day , .Month , .Year], fromDate: date)
        
        let year  = components.year
        let month = components.month
        let day   = components.day
        var stringMonth = String(month)
        var stringDay   = String(day)
        if(month <= 9) {
            stringMonth = "0"+String(month)
        }
        if(day <= 9) {
            stringDay = "0"+String(day)
        }
        
        let out   = String(year)+separator+stringMonth+separator+stringDay
        return out
    }
    
    func goHome(controller:UIViewController){
        let role   = User().getField("role")
        if(role == "realtor") {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let viewController : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("RealtorHomeViewController") as UIViewController
            controller.navigationController?.showViewController(viewController, sender: nil)
        } else if (role == "buyer") {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let viewController : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("BuyerHomeViewController") as UIViewController
            controller.navigationController?.showViewController(viewController, sender: nil)
        }
    }
}
