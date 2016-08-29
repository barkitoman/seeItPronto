//
//  RealtorForm4ViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 8/1/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class RealtorForm4ViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate  {
    
    var animateDistance: CGFloat!
    var viewData:JSON = []
    
    @IBOutlet weak var txtPromoCode: UITextField!
    @IBOutlet weak var lblSubscriptionDescription: UILabel!
    @IBOutlet weak var txtCardNumber: UITextField!
    @IBOutlet weak var txtExpDate: UITextField!
    @IBOutlet weak var txtCvc: UITextField!
    @IBOutlet weak var btnCancelSubscription: UIButton!
    var btnSuscriptionAction = "CANCEL"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblSubscriptionDescription.text = "This payment method will be used for your monthly subscription fee of $\(AppConfig.SUBSCRIPTION_PRICE).     Monthly subscription fee grants you full access. You will be able to switch on your listings and make them See It Pronto! properties. You will also appear in list of available agents for all See It Pronto! request and all See It Later appointments"
        self.findUserInfo()
        self.selfDelegate()
        self.subscriptionButtonAction()
    }
    
    func subscriptionButtonAction() {
        if(User().getField("id") == "") {
            self.btnCancelSubscription.hidden = true;
        } else if(self.viewData["stripe_subscription_id"].stringValue == "0"
            && self.viewData["stripe_subscription_active"].stringValue == "0") {
            self.btnCancelSubscription.hidden = true;
                
        } else if(self.viewData["stripe_subscription_id"].stringValue != "0"
            && self.viewData["stripe_subscription_active"].stringValue == "1") {
                //cancel suscription
                self.btnCancelSubscription.hidden = false;
                btnSuscriptionAction = "CANCEL"
                self.btnCancelSubscription.setTitle("Cancel Subscription", forState: .Normal)
                
        } else if(self.viewData["stripe_subscription_id"].stringValue != "0"
            && self.viewData["stripe_subscription_active"].stringValue == "0") {
                //activate suscription
                self.btnCancelSubscription.hidden = false;
                btnSuscriptionAction = "ACTIVATE"
                self.btnCancelSubscription.setTitle("Activate Subscription", forState: .Normal)
        }
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
    
    func selfDelegate() {
        self.txtCardNumber.delegate = self
        self.txtExpDate.delegate = self
        self.txtCvc.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func btnBack(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btnPrevious(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btnNext(sender: AnyObject) {
        self.save()
    }
    
    func save() {
        //create params
        var params = "id=\(self.viewData["id"].stringValue)&user_id=\(self.viewData["id"].stringValue)&number_card=\(txtCardNumber.text!)"
        params = params+"&expiration_date=\(txtExpDate.text!)&csv=\(self.txtCvc.text!)&promo_code=\(self.txtPromoCode.text!)"
        params = params+"&subscription=1&stripe_subscription_active=\(self.viewData["stripe_subscription_active"].stringValue)"
        params = params+"&email=\(self.viewData["email"].stringValue)&stripe_subscription_id=\(self.viewData["stripe_subscription_id"].stringValue)"
        params = params+"&first_name=\(self.viewData["first_name"].stringValue)&last_name=\(self.viewData["last_name"].stringValue)"
        if(!self.viewData["card_id"].stringValue.isEmpty) {
            params = params+"&card_id="+self.viewData["card_id"].stringValue
        }
        let url = AppConfig.APP_URL+"/users/"+self.viewData["id"].stringValue
        Request().put(url, params:params,controller:self,successHandler: {(response) in self.afterPut(response)});
    }
    
    func afterPut(let response: NSData) {
        let result = JSON(data: response)
        if(result["result"].bool == true) {
            self.viewData = result
            if(result["stripe_subscription_active"].stringValue == "1") {
                User().updateField("stripe_subscription_active", value: "1")
            }
            Utility().performSegue(self, performSegue: "RealtorForm3")
        } else {
            var msg = "Error saving, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }
    
    func findUserInfo() {
        let userId = User().getField("id")
        if(!userId.isEmpty) {
            self.viewData["id"] = JSON(userId)
            let url = AppConfig.APP_URL+"/user_info/"+userId
            Request().get(url, successHandler: {(response) in self.loadDataToEdit(response)})
        }
    }
    
    func loadDataToEdit(let response: NSData) {
        let result = JSON(data: response)
        dispatch_async(dispatch_get_main_queue()) {
            self.viewData = result
            self.subscriptionButtonAction()
            self.txtCardNumber.text = result["number_card"].stringValue
            self.txtExpDate.text    = result["expiration_date"].stringValue
            self.txtCvc.text        = result["csv"].stringValue
            self.txtPromoCode.text  = result["promo_code"].stringValue
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "RealtorForm3") {
            let view: RealtorForm3ViewController = segue.destinationViewController as! RealtorForm3ViewController
            view.viewData  = self.viewData
        }
    }
    
    @IBAction func cancelSubscription(sender: AnyObject) {
        if(btnSuscriptionAction == "CANCEL") {
            dispatch_async(dispatch_get_main_queue()) {
                let cancelMsg = "If you cancel the subscription you will have limited access, and you will not be listed for customers to schedule appointments"
                let alertController = UIAlertController(title:"Confirmation", message: "Do you really want to cancel your subscription?\n \(cancelMsg)", preferredStyle: .Alert)
                let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) {
                    UIAlertAction in
                    self.cancelSubscription()
                }
                let noAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Default) {
                    UIAlertAction in
                }
                alertController.addAction(yesAction)
                alertController.addAction(noAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        } else if(btnSuscriptionAction == "ACTIVATE") {
            dispatch_async(dispatch_get_main_queue()) {
                let alertController = UIAlertController(title:"Confirmation", message: "Do you really want to activate your subscription", preferredStyle: .Alert)
                let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) {
                    UIAlertAction in
                    self.activateSubscription()
                }
                let noAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Default) {
                    UIAlertAction in
                }
                alertController.addAction(yesAction)
                alertController.addAction(noAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        } else {
            Utility().displayAlert(self, title: "Message", message: "This action is not available at this time", performSegue: "")
        }
    }
    
    func cancelSubscription() {
        let userId = User().getField("id")
        if(!userId.isEmpty) {
            self.viewData["id"] = JSON(userId)
            let url = AppConfig.APP_URL+"/cancel_subscription/"+userId
            Request().get(url, successHandler: {(response) in self.afterCancelSubscription(response)})
        } else {
            Utility().displayAlert(self, title: "Message", message: "Cancel subscription is not available at this time", performSegue: "")
        }
    }
    
    func afterCancelSubscription(let response: NSData) {
        let result = JSON(data: response)
        if(result["result"].bool == true) {
            dispatch_async(dispatch_get_main_queue()) {
                self.btnCancelSubscription.hidden = true
            }
            btnSuscriptionAction = "ACTIVATE"
            self.viewData["stripe_subscription_active"].string = "0"
            User().updateField("stripe_subscription_active", value: "0")
            Utility().displayAlert(self, title: "Success!", message: "The subscription has been cancelled", performSegue: "")
        } else {
            var msg = "Error cancelling the subscription, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }
    
    func activateSubscription() {
        let userId = User().getField("id")
        if(!userId.isEmpty) {
            self.viewData["id"] = JSON(userId)
            let url = AppConfig.APP_URL+"/reactive_subscription/"+userId
            Request().get(url, successHandler: {(response) in self.afterActivateSubscription(response)})
        } else {
            Utility().displayAlert(self, title: "Message", message: "Activate subscription is not available at this time", performSegue: "")
        }
    }
    
    func afterActivateSubscription(let response: NSData) {
        let result = JSON(data: response)
        if(result["result"].bool == true) {
            dispatch_async(dispatch_get_main_queue()) {
                self.btnCancelSubscription.hidden = true
            }
            btnSuscriptionAction = "CANCEL"
            self.viewData["stripe_subscription_id"].string = result["subscription_id"].stringValue;
            self.viewData["stripe_subscription_active"].string = "1"
            User().updateField("stripe_subscription_active", value: "1")
            Utility().displayAlert(self, title: "Success!", message: "The subscription has been activated.", performSegue: "")
        } else {
            var msg = "Error when activating your subscription, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }

}
