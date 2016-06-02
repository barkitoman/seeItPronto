//
//  FeedBack3ViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/6/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class FeedBack3ViewController: UIViewController {

    var viewData:JSON = []
    
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
    
    @IBAction func btnBuyWithThisAgent(sender: AnyObject) {
        var params = "id="+self.viewData["showing"]["id"].stringValue+"&buy_with_realtor=1"
        let url    = AppConfig.APP_URL+"/showings/"+self.viewData["showing"]["id"].stringValue
        params     = self.canceledNotificationParams(params)
        Request().put(url, params:params,controller:self,successHandler: {(response) in self.afterBuyWithAgentRequest(response)});
    }
    
    func canceledNotificationParams(var params:String)->String {
        let fullUsername = User().getField("first_name")+" "+User().getField("last_name")
        params = params+"&notification=1&from_user_id="+User().getField("id")+"&to_user_id="+self.viewData["showing"]["realtor_id"].stringValue
        params = params+"&title=A user wants to buy&property_id=\(self.viewData["showing"]["property_id"].stringValue)"
        params = params+"&description=User \(fullUsername) wants to buy a property with you"
        params = params+"&parent_id="+self.viewData["showing"]["id"].stringValue+"&type=user_wants_buy&parent_type=showings"
        return params
    }
    
    func afterBuyWithAgentRequest(let response: NSData) {
        let result = JSON(data: response)
        if(result["result"].bool == true) {
            dispatch_async(dispatch_get_main_queue()) {
                let alertController = UIAlertController(title:"Success", message: "The data have been saved correctly", preferredStyle: .Alert)
                let homeAction = UIAlertAction(title: "Home", style: UIAlertActionStyle.Default) {
                    UIAlertAction in
                    Utility().goHome(self)
                }
                alertController.addAction(homeAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        } else {
            var msg = "Error saving, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }
    
    @IBAction func btnNoThanks(sender: AnyObject) {
        Utility().goHome(self)
    }
    
}
