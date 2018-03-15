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

    private static var __once: () = { () -> Void in
            UIGraphicsBeginImageContextWithOptions(CGSize(width: 30, height: 22), false, 0.0)
            
            UIColor.black.setFill()
            UIBezierPath(rect: CGRect(x: 0, y: 3, width: 30, height: 1)).fill()
            UIBezierPath(rect: CGRect(x: 0, y: 10, width: 30, height: 1)).fill()
            UIBezierPath(rect: CGRect(x: 0, y: 17, width: 30, height: 1)).fill()
            
            UIColor.white.setFill()
            UIBezierPath(rect: CGRect(x: 0, y: 4, width: 30, height: 1)).fill()
            UIBezierPath(rect: CGRect(x: 0, y: 11,  width: 30, height: 1)).fill()
            UIBezierPath(rect: CGRect(x: 0, y: 18, width: 30, height: 1)).fill()
            
            defaultMenuImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
        }()

    //show alert dialog on screen
    func displayAlert(_ controller:UIViewController, title:String, message:String, performSegue:String){
        DispatchQueue.main.async {
            let alertController = UIAlertController(title:title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                UIAlertAction in
                if performSegue != "" {
                    controller.performSegue(withIdentifier: performSegue, sender: self)
                }
            }
            alertController.addAction(okAction)
            controller.present(alertController, animated: true, completion: nil)
        }
    }
    
    func displayAlertBack(_ controller:UIViewController, title:String, message:String){
        DispatchQueue.main.async {
            let alertController = UIAlertController(title:title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Back", style: UIAlertActionStyle.default) {
                UIAlertAction in
                controller.navigationController?.popViewController(animated: true)
            }
            alertController.addAction(okAction)
            controller.present(alertController, animated: true, completion: nil)
        }
    }
    
    func performSegue(_ controller:UIViewController, performSegue:String) {
        DispatchQueue.main.async {
            controller.performSegue(withIdentifier: performSegue, sender: self)
        }
    }
    
    func showPhoto(_ img:UIImageView, imgPath:String, defaultImg:String = ""){
        if(imgPath.isEmpty && !defaultImg.isEmpty) {
            DispatchQueue.main.async {
                img.image = UIImage(named: defaultImg)
            }
        } else {
            var url = URL(string: AppConfig.APP_URL+"/"+imgPath)
            if (imgPath.range(of: "http://") != nil || imgPath.range(of: "https://") != nil ){
                url = URL(string: imgPath)
            }
            let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) -> Void in
                if error != nil {
                    print("ERROR SHOWING IMAGE "+imgPath)
                } else {
                    if let httpResponse = response as? HTTPURLResponse {
                        if(httpResponse.statusCode == 200) {
                            DispatchQueue.main.async {
                                img.image = UIImage(data: data!)
                            }
                        } else if(defaultImg != "") {
                            DispatchQueue.main.async {
                                img.image = UIImage(named: defaultImg)
                            }
                        }
                    }
                }
            }) 
            task.resume()
        }
    }
    
    func formatCurrency(_ currentString : String)->String  {
        var currentString = currentString
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        formatter.locale = Locale(identifier: "en_US")
        formatter.maximumFractionDigits = 0 //remove cents
        let numberFromField = (NSString(string: currentString ).doubleValue)
        currentString  = formatter.string(from: NSNumber(numberFromField))!
        return currentString
    }
    
    func formatNumber(_ numberString : String)->String  {
        var numberString = numberString
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        formatter.locale = Locale(identifier: "en_US")
        formatter.maximumFractionDigits = 0
        let numberFromField = (NSString(string: numberString ).doubleValue)
        numberString  = formatter.string(from: NSNumber(numberFromField))!
        numberString = numberString.replacingOccurrences(of: "$",  with: "", options: NSString.CompareOptions.literal, range: nil)
        return numberString
    }
    
    func defaultMenuImage() -> UIImage {
        let defaultMenuImage = UIImage()
        struct Static {
            static var onceToken: Int = 0
        }
        
        _ = Utility.__once
        return defaultMenuImage;
    }
    
    func switchValue(_ sw:UISwitch,onValue:String,offValue:String)->String{
        if(sw.isOn) {
            return onValue
        }
        return offValue
    }
    
    func sliderValue(_ sl:UISlider)->String{
        return String(Int(roundf(sl.value)))
    }
    
    func getIdFromUrl(_ url:String)->JSON{
        var id = url.replacingOccurrences(of: AppConfig.APP_URL, with: "", options: NSString.CompareOptions.literal, range: nil)
        id     = id.replacingOccurrences(of: "http:",  with: "", options: NSString.CompareOptions.literal, range: nil)
        id     = id.replacingOccurrences(of: "map",    with: "", options: NSString.CompareOptions.literal, range: nil)
        id     = id.replacingOccurrences(of: "/",      with: "", options: NSString.CompareOptions.literal, range: nil)
        id     = id.replacingOccurrences(of: "#",      with: "", options: NSString.CompareOptions.literal, range: nil)
        id     = id.replacingOccurrences(of: "?",      with: "", options: NSString.CompareOptions.literal, range: nil)
        id     = id.replacingOccurrences(of: " ",      with: "", options: NSString.CompareOptions.literal, range: nil)
        let urlData = id.components(separatedBy: "_SEPARATOR_")
        let propertyId: String = urlData[0]
        let propertyClass: String? = urlData[1]
        let out:JSON = ["id":propertyId as AnyObject, "property_class":propertyClass! as AnyObject]
        return out
    }
    
    func getCurrentDate(_ separator:String = "-")->String {
        let date       = Date()
        let calendar   = Calendar.current
        let components = (calendar as NSCalendar).components([.day , .month , .year], from: date)
        
        let year  = components.year
        let month = components.month
        let day   = components.day
        var stringMonth = String(describing: month)
        var stringDay   = String(describing: day)
        if(month! <= 9) {
            stringMonth = "0"+String(describing: month)
        }
        if(day! <= 9) {
            stringDay = "0"+String(describing: day)
        }
        
        let out   = String(describing: year)+separator+stringMonth+separator+stringDay
        return out
    }
    
    func getTime(_ separator:String = ":") -> String {
        let currentDateTime = Date()
        let calendar   = Calendar.current
        let components = (calendar as NSCalendar).components([.hour,.minute,.second], from: currentDateTime)
        let hour       = components.hour
        let min        = components.minute
        let sec        = components.second
        return "\(hour)\(separator)\(min)\(separator)\(sec)"
    }
    
    func goHome(_ controller:UIViewController, viewData:JSON = []){
        let role   = User().getField("role")
        if(role == "realtor") {
            DispatchQueue.main.async {
                let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let viewController : RealtorHomeViewController = mainStoryboard.instantiateViewController(withIdentifier: "RealtorHomeViewController") as! RealtorHomeViewController
                viewController.viewData = viewData
                controller.navigationController?.show(viewController, sender: nil)
            }
        } else if (role == "buyer" || User().getField("id") == "") {
             DispatchQueue.main.async {
                let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let viewController : BuyerHomeViewController = mainStoryboard.instantiateViewController(withIdentifier: "BuyerHomeViewController") as! BuyerHomeViewController
                viewController.viewData = viewData
                controller.navigationController?.show(viewController, sender: nil)
            }
        }
    }
    
    func goPropertyDetails(_ controller:UIViewController, propertyId:String, PropertyClass:String){
        DispatchQueue.main.async {
            let saveData: JSON =  ["id":propertyId as AnyObject,"property_class":PropertyClass as AnyObject]
            Property().saveOne(saveData)
            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let vc : FullPropertyDetailsViewController = mainStoryboard.instantiateViewController(withIdentifier: "FullPropertyDetailsViewController") as! FullPropertyDetailsViewController
            controller.navigationController?.show(vc, sender: nil)
        }
    }
    
    func millitaryToStandardTime(_ militaryTime:String, format:String="MM/dd/yyyy hh:mm a")->String {
        let dateString = "\(militaryTime)"
        let dateFormatter = DateFormatter()
        
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        //dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+0:00")
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
        let date = dateFormatter.date(from: dateString)
            
        dateFormatter.dateFormat = format
        let standardTime = dateFormatter.string(from: date!)
        return standardTime
    }
    
    func deviceTokenId()->String {
        let deviceId = DeviceManager().getField("device_token_id")
        return deviceId;
    }
    
    func convertDeviceTokenToString(_ deviceToken:Data) -> String {
        //  Convert binary Device Token to a String (and remove the <,> and white space charaters).
        var deviceTokenStr = deviceToken.description.replacingOccurrences(of: ">", with: "", options: NSString.CompareOptions.literal, range: nil)
        deviceTokenStr = deviceTokenStr.replacingOccurrences(of: "<", with: "", options: NSString.CompareOptions.literal, range: nil)
        deviceTokenStr = deviceTokenStr.replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range: nil)
        return deviceTokenStr
    }
    
}
