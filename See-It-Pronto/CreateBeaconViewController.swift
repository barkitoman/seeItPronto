//
//  CreateBeaconViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 5/24/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class CreateBeaconViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate  {

    
    @IBOutlet weak var txtBeaconId: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtBeaconId.delegate = self
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func btnBack(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSave(_ sender: AnyObject) {
        if(!self.txtBeaconId.text!.isEmpty) {
            self.save()
        } else {
            Utility().displayAlert(self, title: "Error", message: "Please enter a beacon id", performSegue: "")
        }
    }
    
    func save() {
        let url = AppConfig.APP_URL+"/beacon_users"
        let params = "beacon_id=\(self.txtBeaconId.text!)&user_id=\(User().getField("id"))"
        Request().post(url, params:params,controller:self,successHandler: {(response) in self.afterPost(response)});
    }
    
    func afterPost(_ response: Data) {
        let result = JSON(data: response)
        if(result["result"].bool == true ) {
            DispatchQueue.main.async {
                self.txtBeaconId.text = "";
            }
            Utility().displayAlert(self,title: "Success", message:"The data has been saved successfully.", performSegue:"")
        } else {
            var msg = "Error saving, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }
    
    @IBAction func btnMyBeacons(_ sender: AnyObject) {
    }
    

}
