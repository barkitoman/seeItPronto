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
    
    
    static var TEST_LAT_REALTOR        = "25.770646"
    static var TEST_LON_REALTOR        = "-80.135926"
    
    static var TEST_LAT_BUYER          = "25.784339"
    static var TEST_LON_BUYER          = "-80.136345"
    
    //Valor de precios, estos valores se deben cambiar tambien en en backend app/Stripe.php
    static var SHOWING_PRICE           = "5"
    static var SUBSCRIPTION_PRICE      = "15"
    
    func develop_lat()->String {
        let role = User().getField("role");
        if(role == "realtor") {
            return AppConfig.TEST_LAT_REALTOR
        }
        return AppConfig.TEST_LAT_BUYER
    }
    
    func develop_lon()->String {
        let role = User().getField("role");
        if(role == "realtor") {
            return AppConfig.TEST_LON_REALTOR
        }
        return AppConfig.TEST_LON_BUYER
    }

}

//model configuration for avoid repeat images on table lists
class Model {
    var property : JSON = []
    var im       : UIImage!
    var picurl   : String!
    var task     : URLSessionTask!
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
        if self.imageOrientation == UIImageOrientation.up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let normalizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        return normalizedImage;
    }
}

extension String {
    func toDateTime(_ format:String = "yyyy-MM-dd HH:mm:ss") -> Date {
        //Create Date Formatter
        let dateFormatter = DateFormatter()
        //Specify Format of String to Parse
        dateFormatter.dateFormat = format
        //Parse into NSDate
        if let dateFromString : Date = dateFormatter.date(from: self) {
            return dateFromString
        }
        let currentDate = Date()
        return currentDate
    }
}

extension Date {
    
    func diffHours(_ date:Date) -> Int {
        let dayHourMinuteSecond: NSCalendar.Unit = [.day, .hour, .minute, .second]
        let difference = (Calendar.current as NSCalendar).components(dayHourMinuteSecond, from: date, to: self, options: [])
        let hours      = difference.hour
        return hours!
    }
    
}
