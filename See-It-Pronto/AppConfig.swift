//
//  Config.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/7/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import Foundation
import UIKit

struct AppConfig {
    static var APP_URL                 = "http://oauthtest-nyxent.rhcloud.com"
    static var ABOUT_URL               = "http://seeitpronto.com/about"
    static var GRANT_TYPE              = "client_credentials"
    
    static var SHOWING_CANCELED_STATUS = "4"//0 en espera, 1 aceptado, 2 rechazado, 3 completado, 4 cancelado
    static var SHOWING_WAIT_SECONDS    = 60
    static var FIND_BEACONS_INTERVAL   = 10.0
    static var MODE                    = "DEVELOP" //PROD, DEVELOP
    
    //Valor de precios, estos valores se deben cambiar tambien en en backend app/Stripe.php
    static var SHOWING_PRICE           = "5"
    static var SUBSCRIPTION_PRICE      = "15"

}

//model configuration for avoid repeat images on table lists
class Model {
    var property : JSON = []
    var im       : UIImage!
    var picurl   : String!
    var task     : NSURLSessionTask!
    var reloaded = false
}

//struct for keep visible input fields
struct MoveKeyboard {
    static let KEYBOARD_ANIMATION_DURATION : CGFloat = 0.3
    static let MINIMUM_SCROLL_FRACTION : CGFloat = 0.2;
    static let MAXIMUM_SCROLL_FRACTION : CGFloat = 0.8;
    static let PORTRAIT_KEYBOARD_HEIGHT : CGFloat = 216;
    static let LANDSCAPE_KEYBOARD_HEIGHT : CGFloat = 162;
}

//avoid image rotation, when use the camera
extension UIImage {
    func correctlyOrientedImage() -> UIImage {
        if self.imageOrientation == UIImageOrientation.Up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.drawInRect(CGRectMake(0, 0, self.size.width, self.size.height))
        let normalizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return normalizedImage;
    }
}

extension String {
    func toDateTime(let format:String = "yyyy-MM-dd HH:mm:ss") -> NSDate {
        //Create Date Formatter
        let dateFormatter = NSDateFormatter()
        //Specify Format of String to Parse
        dateFormatter.dateFormat = format
        //Parse into NSDate
        if let dateFromString : NSDate = dateFormatter.dateFromString(self) {
            return dateFromString
        }
        let currentDate = NSDate()
        return currentDate
    }
}

extension NSDate {
    
    func diffHours(date:NSDate) -> Int {
        let dayHourMinuteSecond: NSCalendarUnit = [.Day, .Hour, .Minute, .Second]
        let difference = NSCalendar.currentCalendar().components(dayHourMinuteSecond, fromDate: date, toDate: self, options: [])
        let hours      = difference.hour
        return hours
    }
    
}