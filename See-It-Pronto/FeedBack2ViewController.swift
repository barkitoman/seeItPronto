//
//  FeedBack2ViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/6/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class FeedBack2ViewController: UIViewController {

    var viewData:JSON = []
    @IBOutlet weak var txtAgentComments: UITextView!
    
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
    
    @IBAction func btnBuyWithThisAgent(sender: AnyObject) {
        let params = "id="+self.viewData["showing"]["id"].stringValue+"&showing_status=3&feedback_realtor_comment="+self.txtAgentComments.text!
        let url    = AppConfig.APP_URL+"/showings/"+self.viewData["showing"]["id"].stringValue
        Request().put(url, params:params,successHandler: {(response) in self.afterBuyWithAgentButton(response)});
    }
    
    func afterBuyWithAgentButton(let response: NSData) {
        let result = JSON(data: response)
        if(result["result"].bool == true) {
            dispatch_async(dispatch_get_main_queue()) {
                self.performSegueWithIdentifier("FeedBack2ViewController", sender: self)
            }
        } else {
            var msg = "Error loading the next step, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }
    
    @IBAction func btnPrev(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func btnNext(sender: AnyObject) {
        let params = "id="+self.viewData["showing"]["id"].stringValue+"&showing_status=3&feedback_realtor_comment="+self.txtAgentComments.text!
        let url    = AppConfig.APP_URL+"/showings/"+self.viewData["showing"]["id"].stringValue
        Request().put(url, params:params,successHandler: {(response) in self.afterNextRequest(response)});
    }
    
    func afterNextRequest(let response: NSData) {
        let result = JSON(data: response)
        if(result["result"].bool == true) {
            Utility().goHome(self)
        } else {
            var msg = "Error saving, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }
    
    @IBAction func bntSkip(sender: AnyObject) {
        Utility().goHome(self)
    }
    
    @IBAction func btnBack(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "FeedBack2ViewController") {
            let view: FeedBack3ViewController = segue.destinationViewController as! FeedBack3ViewController
            view.viewData  = self.viewData
        }
    }
    
}
