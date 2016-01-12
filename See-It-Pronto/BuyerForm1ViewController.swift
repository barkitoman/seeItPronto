//
//  BuyerForm1ViewController.swift
//  See-It-Pronto
//
//  Created by user114136 on 1/4/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class BuyerForm1ViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate  {

    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
     var viewData:JSON = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    @IBAction func btnBack(sender: AnyObject) {
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
    
    func save() {
        //create params
        let params = "id="+self.viewData["user_id"].stringValue+"&role=buyer&email="+txtEmail.text!+"&phone="+txtPhone.text!+"&password="+txtPassword.text!
        let url = Config.APP_URL+"/users/add"
        Request().post(url, params:params,successHandler: {(response) in self.afterPost(response)});
    }
    
    func afterPost(let response: NSData) {
        let result = JSON(data: response)
        if(result["result"].bool == true) {
            self.viewData = result
            Utility().displayAlert(self,title: "Success", message:"The data have been saved correctly", performSegue:"FromBuyerForm1")
        } else {
            var msg = "Error saving, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Success", message:msg, performSegue:"")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "FromBuyerForm1") {
            let view: BuyerForm2ViewController = segue.destinationViewController as! BuyerForm2ViewController
            view.viewData  = self.viewData
        }
    }

}
