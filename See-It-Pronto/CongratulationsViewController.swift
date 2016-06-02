//
//  CongratulationsViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/6/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class CongratulationsViewController: UIViewController {

    var viewData:JSON = []
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    private let congratutationSeconds:NSTimeInterval = 1
    private var congratutationSecondsCount:Int = 30
    private var congratulationTimer: NSTimer?
    @IBOutlet weak var waitingForAgentConfirmationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.congratutationSecondsCount = AppConfig.SHOWING_WAIT_SECONDS
        self.showPropertydetails()
        self.startCongratulationTimer()
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
    
    @IBAction func btnCancel(sender: AnyObject) {
        cancelRequest()
    }
    
    func cancelRequest() {
        if self.congratulationTimer != nil { self.stopCongratulationTimer()}
        let url    = AppConfig.APP_URL+"/showings/"+self.viewData["showing"]["id"].stringValue
        var params = "id="+self.viewData["showing"]["id"].stringValue+"&showing_status="+AppConfig.SHOWING_CANCELED_STATUS
        params     = self.canceledNotificationParams(params)
        Request().put(url, params:params,controller:self,successHandler: {(response) in self.afterCancelRequest(response)});
    }
    
    func canceledNotificationParams(var params:String)->String {
        let fullUsername = User().getField("first_name")+" "+User().getField("last_name")
        params = params+"&notification=1&from_user_id="+User().getField("id")+"&to_user_id="+self.viewData["showing"]["realtor_id"].stringValue
        params = params+"&title=Showing request cancelled&property_id="+self.viewData["showing"]["property_id"].stringValue
        params = params+"&description=User \(fullUsername) cancelled the showing request"
        params = params+"&parent_id="+self.viewData["showing"]["id"].stringValue+"&notification_type=showing_cancelled&parent_type=showings"
        return params
    }
    
    func afterCancelRequest(let response: NSData) {
        let result = JSON(data: response)
        if(result["result"].bool == true ) {
            dispatch_async(dispatch_get_main_queue()) {
                let alertController = UIAlertController(title:"Success", message: "The request has been canceled", preferredStyle: .Alert)
                let homeAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) {
                    UIAlertAction in
                    self.gotoSelectAnotherAgent()
                }
                alertController.addAction(homeAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        } else {
            var msg = "Failed to cancel the request, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }
    
    @IBAction func btnCallAgent(sender: AnyObject) {
        self.callAgent()
    }
    
    func callAgent() {
        let phoneNumber = PropertyRealtor().getField("phone")
        if(phoneNumber.isEmpty) {
            Utility().displayAlert(self,title: "Message", message:"The call can't be made at this time, because the agent hasn't confirmed his/her phone number.", performSegue:"")
        } else {
            callNumber(phoneNumber)
        }
    }
    
    private func callNumber(phoneNumber:String) {
        if let phoneCallURL:NSURL = NSURL(string: "tel://\(phoneNumber)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL);
            }
        }
    }

    @IBAction func btnHome(sender: AnyObject) {
        if self.congratulationTimer != nil { self.stopCongratulationTimer()}
        Utility().goHome(self)
    }
    
    @IBAction func btnSearchAgain(sender: AnyObject) {
        if self.congratulationTimer != nil { self.stopCongratulationTimer()}
        Utility().goHome(self)
    }
    
    func showPropertydetails() {
        let image = Property().getField("image")
        if(!image.isEmpty) {
            Utility().showPhoto(self.photo, imgPath: image)
        }
        self.lblPrice.text   = Utility().formatCurrency(Property().getField("price"))
        self.lblAddress.text = Property().getField("address")
        var description = ""
        if(!Property().getField("bedrooms").isEmpty) {
            description += "Bed "+Property().getField("bedrooms")+"/"
        }
        if(!Property().getField("bathrooms").isEmpty) {
            description += "Bath "+Property().getField("bathrooms")+"/"
        }
        if(!Property().getField("property_type").isEmpty) {
            description += Property().getField("property_type")+"/"
        }
        if(!Property().getField("lot_size").isEmpty) {
            description += Property().getField("lot_size")
        }
        self.lblDescription.text = description
    }
    
    func startCongratulationTimer() {
        if(self.congratutationSecondsCount > 0) {
            if self.congratulationTimer != nil { self.stopCongratulationTimer()}
            self.congratulationTimer = NSTimer.scheduledTimerWithTimeInterval(self.congratutationSeconds,
                target:self,
                selector:Selector("showWaitingForAgentConfirmation"),
                userInfo:nil,
                repeats:true)
        } else {
            if self.congratulationTimer != nil { self.stopCongratulationTimer()}
        }
    }
    
    func stopCongratulationTimer() {
        self.congratulationTimer!.invalidate()
    }
    
    func showWaitingForAgentConfirmation(){
        if(self.congratutationSecondsCount > 0) {
            self.congratutationSecondsCount-=1
            self.waitingForAgentConfirmationLabel.text = "Waiting for agent confirmation... "+String(congratutationSecondsCount)
        } else {
            if self.congratulationTimer != nil { self.stopCongratulationTimer()}
            self.findShowingInfo()
        }
    }
    
    func findShowingInfo() {
        let url = AppConfig.APP_URL+"/get_showing_info/"+self.viewData["showing"]["id"].stringValue
        Request().get(url, successHandler: {(response) in self.loadShowingData(response)})
    }
    
    func loadShowingData(let response: NSData){
        let result = JSON(data: response)
        dispatch_async(dispatch_get_main_queue()) {
            if(result["showing_status"].int == 0) {
                self.noResponse()
            } else if(result["showing_status"].int == 1) {
                Utility().displayAlert(self,title: "Success", message:"The agent has accepted your request", performSegue:"showCurrentShowing")
                
            } else if(result["showing_status"].int == 2) {
                self.requestRejected()
            }
        }
    }
    
    func noResponse() {
        let alertController = UIAlertController(title:"Message", message: "The agent has not responded to the request", preferredStyle: .Alert)
        let homeAction = UIAlertAction(title: "Home", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            Utility().goHome(self)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel Request", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            self.cancelRequest()
        }
        
        let waitAction = UIAlertAction(title: "Wait", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            self.congratutationSecondsCount = AppConfig.SHOWING_WAIT_SECONDS
            self.startCongratulationTimer()
        }
        
        let callAction = UIAlertAction(title: "Call Agent", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            self.callAgent()
        }
        alertController.addAction(homeAction)
        alertController.addAction(cancelAction)
        alertController.addAction(waitAction)
        alertController.addAction(callAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func requestRejected() {
        let alertController = UIAlertController(title:"Message", message: "The agent is not available at this time. Please choose another", preferredStyle: .Alert)
        let homeAction = UIAlertAction(title: "Home", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            Utility().goHome(self)
        }
        let selectAgentAction = UIAlertAction(title: "Select another", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            self.gotoSelectAnotherAgent()
        }
        alertController.addAction(homeAction)
        alertController.addAction(selectAgentAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func gotoSelectAnotherAgent() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let viewController : SeeItNowViewController = mainStoryboard.instantiateViewControllerWithIdentifier("SeeItNowViewController") as! SeeItNowViewController
        self.navigationController?.showViewController(viewController, sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "CongratulationsToFeedBack1") {
            let view: FeedBack1ViewController = segue.destinationViewController as! FeedBack1ViewController
            view.showStartMessage  = true
            view.viewData = self.viewData
        }
        if (segue.identifier == "showCurrentShowing") {
            let view: CurrentShowingViewController = segue.destinationViewController as! CurrentShowingViewController
            view.showingId = self.viewData["showing"]["id"].stringValue
        }
    }
    
}
