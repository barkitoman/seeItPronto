//
//  ForgotPasswordViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/4/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate  {

    var viewData:JSON = []
    @IBOutlet weak var txtEmail: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtEmail.delegate = self
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    @IBAction func fnBack(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func isValidEmail(str: String) -> Bool {
        print("validate emilId: \(str)")
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluateWithObject(str)
        return result
    }
    
    @IBAction func fnRecoverPass(sender: AnyObject) {
        
        if txtEmail.text!.isEmpty {
            BProgressHUD.dismissHUD(0)
            let msg = "Please enter your email"
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }else{
            let mail: String
            mail = self.txtEmail.text!
            if self.isValidEmail(mail){
                recoverpassword(txtEmail.text!)
            }else{
                let msg = "Invalid email"
                Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
            }
           
        }
    }
    
    func recoverpassword(email: String){
            BProgressHUD.showLoadingViewWithMessage("Loading")
            let urlString = "\(AppConfig.APP_URL)/emailpasswordrecover/\(email)"
            let url = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            Request().get(url!, successHandler: {(response) in self.response(response)})

    }
    
    func response(let response: NSData){
        dispatch_async(dispatch_get_main_queue()) {
            BProgressHUD.dismissHUD(0)
            let result = JSON(data: response)
            if result["success"].bool == true{
                let msg = "Please review your inbox"
                Utility().displayAlert(self,title: "Confirm", message:msg, performSegue:"")
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }

}
