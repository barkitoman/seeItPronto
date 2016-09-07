//
//  LoginViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 12/23/15.
//  Copyright © 2015 Deyson. All rights reserved.
//

import UIKit
import CoreData

class LoginViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate  {

    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    var viewData:JSON = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selfDelegate()
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
    
    func selfDelegate() {
        self.txtUsername.delegate = self
        self.txtPassword.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func btnMap(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnLogin(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue()) {
            BProgressHUD.showLoadingViewWithMessage("Loading...")
        }
        self.login()
    }
    
    func login() {
        //create params
        let params = "client_id=\(txtUsername.text!)&client_secret=\(txtPassword.text!)&device_token_id=\(Utility().deviceTokenId())&grant_type="+AppConfig.GRANT_TYPE
        let url = AppConfig.APP_URL+"/phone_login"
        Request().post(url, params:params, controller: self, successHandler: {(response) in self.afterLoginRequest(response)});
    }
    
    func afterLoginRequest(let response: NSData) {
        let result = JSON(data: response)
        dispatch_async(dispatch_get_main_queue()) {
            BProgressHUD.dismissHUD(0)
        }
        if(result["user"]["result"].bool == true) {
            //is login is ok, store the user data
            User().deleteAllData()
            User().saveOne(result)
            self.goHomeView(result["user"]["role"].stringValue)
        } else {
            let msg = "Invalid login information, please try again"
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }
    
    func goHomeView(role:String) {
        dispatch_async(dispatch_get_main_queue()) {
            if(role == "realtor") {
                self.performSegueWithIdentifier("LoginRealtor", sender: self)
            } else {
                self.performSegueWithIdentifier("LoginBuyer", sender: self)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "LoginBuyer") {
            let view: BuyerHomeViewController = segue.destinationViewController as! BuyerHomeViewController
            view.viewData  = self.viewData
            
        }else if(segue.identifier == "LoginRealtor") {
            let view: ReadyToWorkViewController = segue.destinationViewController as! ReadyToWorkViewController
            view.viewData  = self.viewData
        }
    }

}
