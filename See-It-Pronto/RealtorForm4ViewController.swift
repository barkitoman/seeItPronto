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
    
    @IBOutlet weak var txtCardNumber: UITextField!
    
    @IBOutlet weak var txtExpDate: UITextField!
    
    @IBOutlet weak var txtCvc: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.findUserInfo()
        self.selfDelegate()
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
        params = params+"&expiration_date=\(txtExpDate.text!)&csv=\(self.txtCvc.text!)"
        params = params+"&subscription=1&subscription_id=\(self.viewData["stripe_subscription_id"].stringValue)"
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
            self.txtCardNumber.text = result["number_card"].stringValue
            self.txtExpDate.text    = result["expiration_date"].stringValue
            self.txtCvc.text        = result["csv"].stringValue
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "RealtorForm3") {
            let view: RealtorForm3ViewController = segue.destinationViewController as! RealtorForm3ViewController
            view.viewData  = self.viewData
        }
    }
    

}
