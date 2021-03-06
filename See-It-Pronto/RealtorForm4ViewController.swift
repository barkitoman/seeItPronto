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
            self.btnCancelSubscription.isHidden = true;
        } else if(self.viewData["stripe_subscription_id"].stringValue == "0"
            && self.viewData["stripe_subscription_active"].stringValue == "0") {
            self.btnCancelSubscription.isHidden = true;
                
        } else if(self.viewData["stripe_subscription_id"].stringValue != "0"
            && self.viewData["stripe_subscription_active"].stringValue == "1") {
                //cancel suscription
                self.btnCancelSubscription.isHidden = false;
                btnSuscriptionAction = "CANCEL"
                self.btnCancelSubscription.setTitle("Cancel Subscription", for: UIControlState())
                
        } else if(self.viewData["stripe_subscription_id"].stringValue != "0"
            && self.viewData["stripe_subscription_active"].stringValue == "0") {
                //activate suscription
                self.btnCancelSubscription.isHidden = false;
                btnSuscriptionAction = "ACTIVATE"
                self.btnCancelSubscription.setTitle("Activate Subscription", for: UIControlState())
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if (navigationController?.topViewController != self) {
            navigationController?.isNavigationBarHidden = false
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func btnBack(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnPrevious(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnNext(_ sender: AnyObject) {
        self.save()
    }
    
    func save() {
        if(self.validateFields() == true) {
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
    }
    
    func afterPut( _ response: Data) {
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
    
    func validateFields()->Bool {
        if(self.txtCardNumber.text! == "" || self.txtExpDate.text! == "" || self.txtCvc.text! == "") {
            Utility().displayAlert(self, title: "Error", message: "Card #, Exp Date and CVC fields are required", performSegue: "")
            return false
        }
        if(self.txtExpDate.text! != "") {
            let regex = "[0-9]{2}/[0-9]{2,4}"
            let matches = self.txtExpDate.text!.range(of: regex, options: .regularExpression)
            if let _ = matches {} else {
                Utility().displayAlert(self, title: "Error", message: "Please enter a valid Exp. Date. \n Example: 05/2020", performSegue: "")
                return false
            }
        }
        return true
    }
    
    func findUserInfo() {
        let userId = User().getField("id")
        if(!userId.isEmpty) {
            self.viewData["id"] = JSON(userId)
            let url = AppConfig.APP_URL+"/user_info/"+userId
            Request().get(url, successHandler: {(response) in self.loadDataToEdit(response)})
        }
    }
    
    func loadDataToEdit( _ response: Data) {
        let result = JSON(data: response)
        DispatchQueue.main.async {
            self.viewData = result
            self.subscriptionButtonAction()
            self.txtCardNumber.text = result["number_card"].stringValue
            self.txtExpDate.text    = result["expiration_date"].stringValue
            self.txtCvc.text        = result["csv"].stringValue
            self.txtPromoCode.text  = result["promo_code"].stringValue
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "RealtorForm3") {
            let view: RealtorForm3ViewController = segue.destination as! RealtorForm3ViewController
            view.viewData  = self.viewData
        }
    }
    
    @IBAction func cancelSubscription(_ sender: AnyObject) {
        if(btnSuscriptionAction == "CANCEL") {
            DispatchQueue.main.async {
                let cancelMsg = "If you cancel the subscription you will have limited access, and you will not be listed for customers to schedule appointments"
                let alertController = UIAlertController(title:"Confirmation", message: "Do you really want to cancel your subscription?\n \(cancelMsg)", preferredStyle: .alert)
                let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    self.cancelSubscription()
                }
                let noAction = UIAlertAction(title: "No", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                }
                alertController.addAction(yesAction)
                alertController.addAction(noAction)
                self.present(alertController, animated: true, completion: nil)
            }
        } else if(btnSuscriptionAction == "ACTIVATE") {
            DispatchQueue.main.async {
                let alertController = UIAlertController(title:"Confirmation", message: "Do you really want to activate your subscription", preferredStyle: .alert)
                let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    self.activateSubscription()
                }
                let noAction = UIAlertAction(title: "No", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                }
                alertController.addAction(yesAction)
                alertController.addAction(noAction)
                self.present(alertController, animated: true, completion: nil)
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
    
    func afterCancelSubscription( _ response: Data) {
        let result = JSON(data: response)
        if(result["result"].bool == true) {
            DispatchQueue.main.async {
                self.btnCancelSubscription.isHidden = true
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
            let url = AppConfig.APP_URL+"/reactive_subscription/\(userId)?promo_code=\(self.viewData["promo_code"].stringValue)"
            Request().get(url, successHandler: {(response) in self.afterActivateSubscription(response)})
        } else {
            Utility().displayAlert(self, title: "Message", message: "Activate subscription is not available at this time", performSegue: "")
        }
    }
    
    func afterActivateSubscription( _ response: Data) {
        let result = JSON(data: response)
        if(result["result"].bool == true) {
            DispatchQueue.main.async {
                self.btnCancelSubscription.isHidden = true
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
