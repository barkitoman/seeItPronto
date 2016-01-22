//
//  RealtorForm1ViewController.swift
//  See-It-Pronto
//
//  Created by user114136 on 1/4/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class RealtorForm1ViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var txtBrokerage: UITextField!
    @IBOutlet weak var txtAgent: UITextField!
    @IBOutlet weak var txtLisence: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtBankAcct: UITextField!
    @IBOutlet weak var btnChoosePicture: UIButton!
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
    
    func selfDelegate() {
        self.txtBrokerage.delegate = self
        self.txtAgent.delegate = self
        self.txtLisence.delegate = self
        self.txtEmail.delegate = self
        self.txtBankAcct.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func save() {
        //create params
        let params = "id="+self.viewData["id"].stringValue+"&role=realtor&brokerage="+txtBrokerage.text!+"&agent="+txtBrokerage.text!+"&lisence="+txtLisence.text!+"&email="+txtEmail.text!+"&back_acc"+txtBankAcct.text!
        let url = Config.APP_URL+"/users/add"
        Request().post(url, params:params,successHandler: {(response) in self.afterPost(response)});
    }
    
    func afterPost(let response: NSData) {
        let result = JSON(data: response)
        if(result["result"].bool == true) {
            self.viewData = result
            Utility().displayAlert(self,title:"Success", message:"The data have been saved correctly", performSegue:"RealtorForm1")
        } else {
            var msg = "Error saving, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title:"Error", message:msg, performSegue:"")
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "RealtorForm1") {
            let view: RealtorForm2ViewController = segue.destinationViewController as! RealtorForm2ViewController
            view.viewData  = self.viewData
        }
    }

}
