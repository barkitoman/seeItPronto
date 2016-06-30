//
//  ViewPropertyViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/4/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class ShowingRequestViewController: UIViewController {

    var viewData:JSON = []
    @IBOutlet weak var buyerPhoto: UIImageView!
    @IBOutlet weak var lblBuyerName: UILabel!
    @IBOutlet weak var propertyPhoto: UIImageView!
    @IBOutlet weak var lblPropertyDescription: UILabel!
    @IBOutlet weak var showingInstructions: UILabel!
    var showingId:String = ""
    
    @IBOutlet weak var btnConvenienceFee: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.findShowing()
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
    }
    
    @IBAction func btnBack(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btnYes(sender: AnyObject) {
        let url          = AppConfig.APP_URL+"/showings/"+self.viewData["showing"]["id"].stringValue
        var params       = "id="+self.viewData["showing"]["id"].stringValue+"&showing_status=1&current_showing="+self.isCurrentShowing()
        params           = params+"&user_id="+User().getField("id")
        let fullUsername = User().getField("first_name")+" "+User().getField("last_name")
        let type         = "showing_acepted"
        let title        = "Showing request accepted"
        let description  = "User \(fullUsername) Accepted your showing request"
        params           = self.notificationParams(params,type: type,title: title,descripcion: description)
        Request().put(url, params:params,controller:self,successHandler: {(response) in self.afterYesRequest(response)});
    }
    
    func afterYesRequest(let response: NSData) {
        let result = JSON(data: response)
        if(result["result"].bool == true ) {
            dispatch_async(dispatch_get_main_queue()) {
                let alertController = UIAlertController(title:"Success", message: "The request has been accepted, Please proceed to the property", preferredStyle: .Alert)
                let currentShowingAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) {
                    UIAlertAction in
                    if(self.viewData["showing"]["type"].stringValue == "see_it_pronto") {
                        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                        let vc : CurrentShowingViewController = mainStoryboard.instantiateViewControllerWithIdentifier("CurrentShowingViewController") as! CurrentShowingViewController
                        vc.showingId = self.showingId
                        self.navigationController?.showViewController(vc, sender: nil)
                    } else {
                        Utility().goHome(self)
                    }
                }
                alertController.addAction(currentShowingAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        } else {
            var msg = "Error saving, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }
    
    func isCurrentShowing()->String {
        var out = "0"
        if(self.viewData["showing"]["type"].stringValue == "see_it_pronto") {
            out = "1"
        }
        return out
    }
    
    func notificationParams(var params:String, type:String, title:String, descripcion:String)->String {
        params = params+"&notification=1&from_user_id="+User().getField("id")+"&to_user_id="+self.viewData["showing"]["buyer_id"].stringValue
        params = params+"&title=\(title)&property_id="+self.viewData["showing"]["property_id"].stringValue
        params = params+"&description="+descripcion
        params = params+"&parent_id="+self.viewData["showing"]["id"].stringValue+"&parent_type=showings&notification_type="+type
        return params
    }
    
    @IBAction func btnNo(sender: AnyObject) {
        let url          = AppConfig.APP_URL+"/showings/"+self.viewData["showing"]["id"].stringValue
        var params       = "id="+self.viewData["showing"]["id"].stringValue+"&showing_status=2"
        let fullUsername = User().getField("first_name")+" "+User().getField("last_name")
        let type         = "showing_rejected"
        let title        = "Showing request rejected"
        let description  = "User \(fullUsername) is not available to show you the property at this time"
        params           = self.notificationParams(params,type: type,title: title,descripcion: description)
        Request().put(url, params:params,controller:self,successHandler: {(response) in self.afterNoRequest(response)});
    }
    
    func afterNoRequest(let response: NSData) {
        let result = JSON(data: response)
        print(result)
        if(result["result"].bool == true ) {
            dispatch_async(dispatch_get_main_queue()) {
                let alertController = UIAlertController(title:"Success", message: "The request has been rejected", preferredStyle: .Alert)
                let homeAction = UIAlertAction(title: "Home", style: UIAlertActionStyle.Default) {
                    UIAlertAction in
                    Utility().goHome(self)
                }
                let backAction = UIAlertAction(title: "Back", style: UIAlertActionStyle.Default) {
                    UIAlertAction in
                    self.navigationController?.popViewControllerAnimated(true)
                }
                alertController.addAction(homeAction)
                alertController.addAction(backAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        } else {
            var msg = "Error saving, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }
    
    func findShowing() {
        let url = AppConfig.APP_URL+"/get_showing_details/"+self.showingId+"/\(User().getField("id"))"
        Request().get(url, successHandler: {(response) in self.loadShowingData(response)})
    }
    
    func loadShowingData(let response: NSData) {
        let result = JSON(data: response)
        dispatch_async(dispatch_get_main_queue()) {
            self.viewData = result
            let name = result["buyer"]["first_name"].stringValue+" "+result["buyer"]["last_name"].stringValue
            self.lblBuyerName.text = "User \(name) want to see it on \(result["showing"]["date"].stringValue)"
            var description = result["property"]["address"].stringValue+" \(Utility().formatCurrency(result["property"]["price"].stringValue))"
            description = description+" "+result["property"]["bedrooms"].stringValue+"Bd / "+result["property"]["bathrooms"].stringValue+"Ba"
            self.lblPropertyDescription.text = description
            self.btnConvenienceFee.setTitle("$"+result["information_realtor"]["showing_rate"].stringValue+" convenience fee", forState: .Normal)
            if(!result["buyer"]["url_image"].stringValue.isEmpty) {
                Utility().showPhoto(self.buyerPhoto, imgPath: result["buyer"]["url_image"].stringValue)
            }
            if(!result["property"]["image"].stringValue.isEmpty) {
                Utility().showPhoto(self.propertyPhoto, imgPath: result["property"]["image"].stringValue)
            }
            self.statusMessage()
        }
    }
    
    func statusMessage() {
        var message = ""
        if(self.viewData == nil) {
            message = "Sorry, the request has been removed"
            
        }else if(self.viewData["showing"]["showing_status"].int == 4) {
            message = "This showing request has been canceled"
            
        }else if(self.viewData["showing"]["showing_status"].int == 3) {
            message = "This showing request has been completed"
            
        }else if(self.viewData["showing"]["showing_status"].int == 2) {
            message = "This showing request has been rejected"
            
        }else if(self.viewData["showing"]["showing_status"].int == 1) {
            message = "This showing request has been accepted"
            
        }else if(self.viewData["showing"]["expired"].stringValue == "true") {
            message = "This showing request has expired on \(self.viewData["showing"]["nice_date"].stringValue)"
        }
        
        if(!message.isEmpty) {
            let alertController = UIAlertController(title:"Message", message: message, preferredStyle: .Alert)
            let homeAction = UIAlertAction(title: "Back", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                self.navigationController?.popViewControllerAnimated(true)
            }
            alertController.addAction(homeAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnViewShowingInstructions(sender: AnyObject) {
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
        if let phoneCallURL:NSURL = NSURL(string: "tel://\(phoneNumber)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL);
            }
        }
    }
    
}
