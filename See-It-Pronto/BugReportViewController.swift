//
//  BugReportViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 7/1/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class BugReportViewController: UIViewController {

    
    @IBOutlet weak var txtComments: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    @IBAction func btnSubmit(sender: AnyObject) {
        save()
    }
    
    func save() {
        let url = AppConfig.APP_URL+"/bug_reports"
        let params = "user_id=\(User().getField("id"))&comments=\(self.txtComments.text!)"
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
    
    @IBAction func btnCancel(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }

}
