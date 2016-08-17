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
    @IBOutlet weak var btnInstructions: UIButton!
    
    var manager: OneShotLocationManager?
    var showingId:String = ""
    var startEndButtonAction = "start"
    var viewData:JSON = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.findShowing()
        self.showHideButtons()
    }
    
    func showHideButtons() {
        let role = User().getField("role")
        if(role == "buyer") {
            self.btnCall.hidden = true
            self.btnStartEndShowing.hidden = true
            self.btnInstructions.hidden = true
        }
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
            description += result["property"]["bedrooms"].stringValue+" Bed / "
            description += result["property"]["bathrooms"].stringValue+" Bath / "
            if(!result["property"]["type"].stringValue.isEmpty) {
                description = description+result["property"]["type"].stringValue+" / "
            }
            if(!result["property"]["square_feed"].stringValue.isEmpty) {
                description = description+result["property"]["square_feed"].stringValue+" SqrFt"
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
            let goAction = UIAlertAction(title: "View Request", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                
                let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                let vc : ShowingRequestViewController = mainStoryboard.instantiateViewControllerWithIdentifier("ShowingRequestViewController") as! ShowingRequestViewController
                vc.showingId = showingId
                self.navigationController?.showViewController(vc, sender: nil)
            }
            let homeAction = UIAlertAction(title: "Home", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                Utility().goHome(self)
            }
            alertController.addAction(goAction)
            alertController.addAction(homeAction)
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
    
    @IBAction func btnViewDetails(sender: AnyObject) {
        Utility().goPropertyDetails(self,propertyId: self.viewData["showing"]["property_id"].stringValue, PropertyClass: self.viewData["showing"]["property_class"].stringValue)
    }
    
    @IBAction func btnShowingInstrunctions(sender: AnyObject) {
        if(!self.viewData["realtor_properties"]["showing_instruction"].stringValue.isEmpty) {
            var instructions = self.viewData["realtor_properties"]["type"].stringValue+"\n"
            instructions = instructions+self.viewData["realtor_properties"]["showing_instruction"].stringValue
            Utility().displayAlert(self, title: "Showing instructions", message: instructions, performSegue: "")
        } else {
            Utility().displayAlert(self, title: "Message", message: "You don't have showing instructions for this property", performSegue: "")
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
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc : ChatViewController = mainStoryboard.instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
        vc.to = self.viewData["buyer"]["id"].stringValue
        vc.oponentImageName = self.viewData["buyer"]["url_image"].stringValue
        self.navigationController?.showViewController(vc, sender: nil)
    }
    
    @IBAction func btnStartEndShowing(sender: AnyObject) {
        if(self.startEndButtonAction == "start") {
            self.startShowing()
        } else {
            self.endShowing()
        }
    }
    
    func startShowing() {
        self.startEndButtonAction = "end"
        dispatch_async(dispatch_get_main_queue()) {
            self.btnStartEndShowing.setTitle("End showing", forState: .Normal)
            self.btnStartEndShowing.backgroundColor = UIColor(rgba: "#45B5DC")
        }
    }
    
    func startShowingSendingMoney() {
        let url = AppConfig.APP_URL+"/start_showing/"+self.viewData["showing"]["id"].stringValue
        Request().get(url) { (response) -> Void in
            self.afterStartShowing(response)
        }
    }
    
    func afterStartShowing(let response: NSData) {
        let result = JSON(data: response)
        if(result["result"].bool == true ) {
            self.startEndButtonAction = "end"
            self.btnStartEndShowing.setTitle("End showing", forState: .Normal)
            self.btnStartEndShowing.backgroundColor = UIColor(rgba: "#45B5DC")
        } else {
            var msg = "Failed to start the showing request, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }
    
    func endShowing() {
        dispatch_async(dispatch_get_main_queue()) {
            let alertController = UIAlertController(title:"Confirmation", message: "Do you really want to end this showing?", preferredStyle: .Alert)
            let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                self.sendEndShowingSaveRequest()
            }
            let noAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Default) {
                UIAlertAction in
            }
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }

    func sendEndShowingSaveRequest(){
        let url    = AppConfig.APP_URL+"/showings/"+self.viewData["showing"]["id"].stringValue
        var params = "id="+self.viewData["showing"]["id"].stringValue+"&showing_status=3"
        params     = self.endNotificationParams(params)
        Request().put(url, params:params,controller:self,successHandler: {(response) in self.afterCancelRequest(response)});
    }
    
    func endNotificationParams(var params:String)->String {
        let fullUsername = User().getField("first_name")+" "+User().getField("last_name")
        params = params+"&notification=1&from_user_id="+User().getField("id")+"&to_user_id="+self.viewData["showing"]["buyer_id"].stringValue
        params = params+"&title=Showing Request Completed&property_id="+self.viewData["showing"]["property_id"].stringValue
        params = params+"&description=You have completed a showing with \(fullUsername) please give us your feedback"
        params = params+"&parent_id="+self.viewData["showing"]["id"].stringValue+"&notification_type=showing_completed&parent_type=showings"
        return params
    }
    
    func afterCancelRequest(let response: NSData) {
        let result = JSON(data: response)
        if(result["result"].bool == true ) {
            dispatch_async(dispatch_get_main_queue()) {
                Utility().goHome(self)
            }
        } else {
            var msg = "Failed to completed the showing request, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }
    @IBAction func CallPanic(sender: AnyObject) {
        if let phoneCallURL:NSURL = NSURL(string: "tel://911") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL);
            }
        }
    }
}
