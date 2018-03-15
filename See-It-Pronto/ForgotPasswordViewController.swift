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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    @IBAction func fnBack(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }
    
    func isValidEmail(_ str: String) -> Bool {
        print("validate emilId: \(str)")
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: str)
        return result
    }
    
    @IBAction func fnRecoverPass(_ sender: AnyObject) {
        if txtEmail.text!.isEmpty {
            DispatchQueue.main.async {
                BProgressHUD.dismissHUD(0)
            }
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
    
    func recoverpassword(_ email: String){
            DispatchQueue.main.async {
                BProgressHUD.showLoadingViewWithMessage("Loading...")
            }
            let url = "\(AppConfig.APP_URL)/emailpasswordrecover"
            let params = "email=\(email)"
            Request().post(url, params: params, controller: self) { (response) -> Void in
                self.afterRecoverRequest(response)
            }
    }
    
    func afterRecoverRequest(_ response: Data){
        DispatchQueue.main.async {
            BProgressHUD.dismissHUD(0)
            let result = JSON(data: response)
            if result["result"].bool == true {
                let msg = "Please check your email to continue the process of recovering password."
                Utility().displayAlertBack(self, title: "Success", message: msg)
            } else {
                var msg = "Error recovering password, please try later"
                if(!result["msg"].stringValue.isEmpty) {
                    msg = result["msg"].stringValue
                }
                Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
            }
        }
    }

}
