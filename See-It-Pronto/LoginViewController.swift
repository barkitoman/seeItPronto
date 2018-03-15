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
    
    func selfDelegate() {
        self.txtUsername.delegate = self
        self.txtPassword.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func btnMap(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnLogin(_ sender: AnyObject) {
        DispatchQueue.main.async {
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
    
    func afterLoginRequest(_ response: Data) {
        let result = JSON(data: response)
        DispatchQueue.main.async {
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
    
    func goHomeView(_ role:String) {
        DispatchQueue.main.async {
            if(role == "realtor") {
                self.performSegue(withIdentifier: "LoginRealtor", sender: self)
            } else {
                self.performSegue(withIdentifier: "LoginBuyer", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "LoginBuyer") {
            let view: BuyerHomeViewController = segue.destination as! BuyerHomeViewController
            view.viewData  = self.viewData
            
        }else if(segue.identifier == "LoginRealtor") {
            let view: ReadyToWorkViewController = segue.destination as! ReadyToWorkViewController
            view.viewData  = self.viewData
        }
    }

}
