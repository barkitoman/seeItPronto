//
//  BuyerForm1ViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/4/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit
import CoreData

class BuyerForm1ViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate  {

    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnBack: UIButton!
    var animateDistance: CGFloat!
    var viewData:JSON = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selfDelegate()
        self.findUserInfo()
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
    
    @IBAction func btnPrevious(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)  
    }
    
    //selfDelegate, textFieldShouldReturn are functions for hide keyboard when press 'return' key
    func selfDelegate() {
        self.txtEmail.delegate = self
        self.txtPhone.delegate = self
        self.txtPassword.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func btnSave(sender: AnyObject) {
        save()
    }
    
    func save() {
        let userId = User().getField("id")
        var url = AppConfig.APP_URL+"/users"
        if(!userId.isEmpty) {
            //if user is editing
            var params = "role=buyer&email="+txtEmail.text!+"&phone="+txtPhone.text!+"&password="+txtPassword.text!
            params = params+"&id="+userId
            url = AppConfig.APP_URL+"/users/"+userId
            Request().put(url, params:params,successHandler: {(response) in self.afterPost(response)});
        } else {
            //if user is registering
            let params = "role=buyer&client_id="+txtEmail.text!+"&phone="+txtPhone.text!+"&client_secret="+txtPassword.text!+"&grant_type="+AppConfig.GRANT_TYPE
            Request().post(url, params:params,controller: self,successHandler: {(response) in self.afterPost(response)});
        }
    }
    
    func afterPost(let response: NSData) {
        let result = JSON(data: response)
        if(result["user"]["result"].bool == true || result["result"].bool == true ) {
            let userId = User().getField("id")
            //if user is editing
            if(!userId.isEmpty) {
                self.viewData = result
            } else {
                //if user is registering
                self.viewData = result["user"]
                User().saveIfExists(result)
            }
            Utility().performSegue(self, performSegue: "FromBuyerForm1")
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
            self.txtEmail.text = result["email"].stringValue
            self.txtPhone.text = result["phone"].stringValue
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "FromBuyerForm1") {
            let view: BuyerForm2ViewController = segue.destinationViewController as! BuyerForm2ViewController
            view.viewData  = self.viewData
        }
    }

}
