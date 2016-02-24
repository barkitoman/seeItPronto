//
//  RealtorForm1ViewController.swift
//  See-It-Pronto
//
//  Created by user114136 on 1/4/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class RealtorForm1ViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
 
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
        //create params
        let userId = User().getField("id")
        var params = "role=realtor&email="+txtEmail.text!+"&phone="+txtPhone.text!+"&password="+txtPassword.text!
        var url = AppConfig.APP_URL+"/users"
        if(!userId.isEmpty) {
            params = params+"&id="+userId
            url = AppConfig.APP_URL+"/users/"+userId
            Request().put(url, params:params,successHandler: {(response) in self.afterPost(response)});
        } else {
            Request().post(url, params:params,successHandler: {(response) in self.afterPost(response)});
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
            Utility().displayAlert(self,title:"Success", message:"The data have been saved correctly", performSegue:"RealtorForm1")
        } else {
            var msg = "Error saving, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title:"Error", message:msg, performSegue:"")
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
        dispatch_async(dispatch_get_main_queue()) {
            let result = JSON(data: response)
            self.txtEmail.text = result["email"].stringValue
            self.txtPhone.text = result["phone"].stringValue
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "RealtorForm1") {
            let view: RealtorForm2ViewController = segue.destinationViewController as! RealtorForm2ViewController
            view.viewData  = self.viewData
        }
    }
    
}
