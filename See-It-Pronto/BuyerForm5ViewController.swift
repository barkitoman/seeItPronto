//
//  BuerForm5ViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 3/23/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class BuyerForm5ViewController: UIViewController {

    var viewData:JSON = []
    @IBOutlet weak var swPreQualified: UISwitch!
    @IBOutlet weak var swLikeToBe: UISwitch!
    @IBOutlet weak var btnScan: UIButton!
    @IBOutlet weak var lblLikeTobe: UILabel!
    @IBOutlet weak var lblNoLikeTobe: UILabel!
    @IBOutlet weak var lblYesLikeTobe: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.findUserInfo()
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
    
    @IBAction func btnPrevious(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btnNext(sender: AnyObject) {
    }
    
    @IBAction func btnSearch(sender: AnyObject) {
        var params = "id="+User().getField("id")
        params     = params+"&pre_qualified="+Utility().switchValue(self.swPreQualified, onValue: "1", offValue: "0")
        params     = params+"&like_pre_qualification="+Utility().switchValue(self.swLikeToBe, onValue: "1", offValue: "0")
        let url    = AppConfig.APP_URL+"/users/"+User().getField("id")
        Request().put(url, params:params,successHandler: {(response) in self.afterPut(response)});
    }
    
    func afterPut(let response: NSData) {
        let result = JSON(data: response)
        if(result["result"].bool == true) {
            self.viewData = result
            Utility().displayAlert(self,title: "Success", message:"The data have been saved correctly", performSegue:"FromBuyerForm5")
        } else {
            var msg = "Error saving, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }
    
    @IBAction func swPrequalification(sender: AnyObject) {
        self.preQualificationFields(!self.swPreQualified.on)
    }
    
    func findUserInfo() {
        let userId = User().getField("id")
        if(!userId.isEmpty) {
            self.viewData["id"] = JSON(userId)
            let url = AppConfig.APP_URL+"/user_info/"+userId
            Request().get(url, successHandler: {(response) in self.loadDataToEdit(response)})
        }
    }
    
    func loadDataToEdit(let response: NSData) {
        let result = JSON(data: response)
        dispatch_async(dispatch_get_main_queue()) {
            let preQualified = result["pre_qualified"].stringValue
            if(preQualified == "1") {
                self.swPreQualified.on = true
                self.preQualificationFields(false)
            }else{
                self.swPreQualified.on = false
                self.preQualificationFields(true)
            }
            let likeToBe = result["like_pre_qualification"].stringValue
            if(likeToBe == "1"){self.swLikeToBe.on = true}else{self.swLikeToBe.on = false}
        }
    }
    
    func preQualificationFields(preQuealificationIsEnabled:Bool){
        if(preQuealificationIsEnabled == true) {
            self.btnScan.enabled       = true
            self.lblLikeTobe.hidden    = true
            self.lblYesLikeTobe.hidden = true
            self.lblNoLikeTobe.hidden  = true
            self.swLikeToBe.hidden     = true
        } else {
            self.btnScan.enabled       = false
            self.lblLikeTobe.hidden    = false
            self.lblYesLikeTobe.hidden = false
            self.lblNoLikeTobe.hidden  = false
            self.swLikeToBe.hidden     = false
        }
    }
}
