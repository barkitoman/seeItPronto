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

    @IBAction func btnBack(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnPrev(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnShareMyInfo(_ sender: AnyObject) {
        var params = "id="+self.viewData["showing"]["id"].stringValue+"&buy_with_realtor=1"
        let url    = AppConfig.APP_URL+"/showings/"+self.viewData["showing"]["id"].stringValue
        params     = self.shareMyInfoNotificationParams(params)
        Request().put(url, params:params,controller:self,successHandler: {(response) in self.afterBuyWithAgentRequest(response)});
    }
    
    func shareMyInfoNotificationParams(_ params:String)->String {
        var params = params
        let fullUsername = User().getField("first_name")+" "+User().getField("last_name")
        params = params+"&notification=1&from_user_id="+User().getField("id")+"&to_user_id="+self.viewData["showing"]["realtor_id"].stringValue
        params = params+"&title=User Wants To Share Info&property_id=\(self.viewData["showing"]["property_id"].stringValue)"
        params = params+"&description=\(fullUsername) wants to share your info with you"
        params = params+"&parent_id="+self.viewData["showing"]["id"].stringValue+"&notification_type=user_wants_share&parent_type=showings"
        return params
    }
    
    func afterBuyWithAgentRequest(_ response: Data) {
        let result = JSON(data: response)
        if(result["result"].bool == true) {
            DispatchQueue.main.async {
                let alertController = UIAlertController(title:"Success", message: "The data has been saved successfully.", preferredStyle: .alert)
                let homeAction = UIAlertAction(title: "Home", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    Utility().goHome(self)
                }
                alertController.addAction(homeAction)
                self.present(alertController, animated: true, completion: nil)
            }
        } else {
            var msg = "Error saving, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }
    
    @IBAction func btnFinish(_ sender: AnyObject) {
        Utility().goHome(self)
    }
    
}
