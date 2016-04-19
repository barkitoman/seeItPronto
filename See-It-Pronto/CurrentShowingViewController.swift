//
//  CurrentShowingViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 4/7/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class CurrentShowingViewController: UIViewController {

    @IBOutlet weak var propertyImage: UIImageView!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var propertyDescription: UILabel!

    @IBOutlet weak var btnCall: UIButton!
    @IBOutlet weak var btnStartEndShowing: UIButton!
    
    var manager: OneShotLocationManager?
    var showingId:String = ""
    var viewData:JSON = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.findShowing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    @IBAction func btnHome(sender: AnyObject) {
        Utility().goHome(self)
    }
    
    func findShowing() {
        if(!self.showingId.isEmpty) {
            let url = AppConfig.APP_URL+"/get_showing_details/"+self.showingId+"/"+User().getField("id")
            Request().get(url, successHandler: {(response) in self.loadShowingData(response)})
        } else {
            let url = AppConfig.APP_URL+"/current_showing/"+User().getField("id")
            Request().get(url, successHandler: {(response) in self.loadShowingData(response)})
        }
    }
    
    func loadShowingData(let response: NSData) {
        let result = JSON(data: response)
        dispatch_async(dispatch_get_main_queue()) {
            self.viewData = result
            if(self.viewData["showing"]["id"].stringValue.isEmpty) {
                self.showingNotExistMessage()
            }
            if(self.viewData["showing"]["showing_status"].int == 0
                && (self.viewData["showing"]["type"] == "see_it_later" || self.viewData["showing"]["type"] == "see_it_pronto")) {
                self.showingPendingMessage(self.viewData["showing"]["id"].stringValue)
            }
            self.address.text  = result["property"]["address"].stringValue
            self.lblPrice.text = Utility().formatCurrency(result["property"]["price"].stringValue)
            var description = ""
            description += "Bed "+result["property"]["bedrooms"].stringValue+"/"
            description += "Bath "+result["property"]["bathrooms"].stringValue+"/"
            if(!result["property"]["property_type"].stringValue.isEmpty) {
                description += result["property"]["property_type"].stringValue+"/"
            }
            if(!result["property"]["lot_size"].stringValue.isEmpty) {
                description += result["property"]["lot_size"].stringValue
            }
            self.propertyDescription.text = description
            if(!result["property"]["image"].stringValue.isEmpty) {
                Utility().showPhoto(self.propertyImage, imgPath: result["property"]["image"].stringValue)
            }
        }
    }
    
    func showingPendingMessage(showingId:String) {
        let role = User().getField("role")
        if(role == "realtor") {
            let alertController = UIAlertController(title:"Message", message: "This showing request is pending to be approved", preferredStyle: .Alert)
            let goAction = UIAlertAction(title: "Go", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                
                let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                let vc : ShowingRequestViewController = mainStoryboard.instantiateViewControllerWithIdentifier("ShowingRequestViewController") as! ShowingRequestViewController
                vc.showingId = showingId
                self.navigationController?.showViewController(vc, sender: nil)
            }
            alertController.addAction(goAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func showingNotExistMessage() {
        let alertController = UIAlertController(title:"Message", message: "You don't have a current showing", preferredStyle: .Alert)
        let homeAction = UIAlertAction(title: "Home", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            Utility().goHome(self)
        }
        alertController.addAction(homeAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func btnGetDirections(sender: AnyObject) {
        manager = OneShotLocationManager()
        manager!.fetchWithCompletion {location, error in
            // fetch location or an error
            if let loc  = location {
                let lat = (AppConfig.MODE == "PROD") ? "\(loc.coordinate.latitude)" : "26.189244"
                let lng = (AppConfig.MODE == "PROD") ? "\(loc.coordinate.longitude)": "-80.1824587"
                var address = self.viewData["property"]["address"].stringValue
                address = address.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
                let fullAddress = "http://maps.apple.com/?saddr=\(lat),\(lng)&daddr=\(address)"
                UIApplication.sharedApplication().openURL(NSURL(string: fullAddress)!)
            } else if let _ = error {
                print("ERROR GETTING LOCATION")
            }
            // destroy the object immediately to save memory
            self.manager = nil
        }
    }
    
    @IBAction func btnCallCustomer(sender: AnyObject) {
        let phoneNumber = self.viewData["buyer"]["phone"].stringValue
        if(phoneNumber.isEmpty) {
            Utility().displayAlert(self,title: "Message", message:"The call can't be made at this time, because the customer hasn't confirmed his/her phone number.", performSegue:"")
        } else {
            callNumber(phoneNumber)
        }
    }
    
    private func callNumber(phoneNumber:String) {
        if let phoneCallURL:NSURL = NSURL(string: "tel://\(phoneNumber)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL);
            }
        }
    }
    
    @IBAction func btnStartEndShowing(sender: AnyObject) {
    }
    
    
}
