//
//  AddRealtorPropertyViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 6/2/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class AddRealtorPropertyViewController: UIViewController {

    @IBOutlet weak var txtPropertyId: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    @IBAction func btnBack(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btnSubmit(sender: AnyObject) {
        if(!self.txtPropertyId.text!.isEmpty) {
            self.save()
        } else {
            Utility().displayAlert(self, title: "Error", message: "Please enter a property id", performSegue: "")
        }
    }
    
    func save() {
        let url = AppConfig.APP_URL+"/add_property_realtor"
        let params = "property_id=\(self.txtPropertyId.text!)&user_id=\(User().getField("id"))"
        Request().post(url, params:params,controller:self,successHandler: {(response) in self.afterPost(response)});
    }
    
    func afterPost(let response: NSData) {
        let result = JSON(data: response)
        if(result["result"].bool == true ) {
            Utility().displayAlert(self,title: "Success", message:"The data have been saved correctly", performSegue:"")
        } else {
            var msg = "Error saving, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }
    


}
