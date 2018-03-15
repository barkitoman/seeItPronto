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
    fileprivate let congratutationSeconds:TimeInterval = 1
    fileprivate var congratutationSecondsCount:Int = 30
    fileprivate var requestSeconds:Int = 0
    
    fileprivate var congratulationTimer: Timer?
    @IBOutlet weak var waitingForAgentConfirmationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.congratutationSecondsCount = AppConfig.SHOWING_WAIT_SECONDS
        self.showPropertydetails()
        self.startCongratulationTimer()
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
    
    @IBAction func btnCancel(_ sender: AnyObject) {
        cancelRequest()
    }
    
    func cancelRequest() {
        self.stopCongratulationTimer()
        let url    = AppConfig.APP_URL+"/showings/"+self.viewData["showing"]["id"].stringValue
        var params = "id="+self.viewData["showing"]["id"].stringValue+"&showing_status="+AppConfig.SHOWING_CANCELED_STATUS
        params     = self.canceledNotificationParams(params)
        Request().put(url, params:params,controller:self,successHandler: {(response) in self.afterCancelRequest(response)});
    }
    
    func canceledNotificationParams(_ params:String)->String {
        var params = params
        let fullUsername = User().getField("first_name")+" "+User().getField("last_name")
        params = params+"&notification=1&from_user_id="+User().getField("id")+"&to_user_id="+self.viewData["showing"]["realtor_id"].stringValue
        params = params+"&title=Showing Request Cancelled&property_id="+self.viewData["showing"]["property_id"].stringValue
        params = params+"&description=\(fullUsername) cancelled the showing request"
        params = params+"&parent_id="+self.viewData["showing"]["id"].stringValue+"&notification_type=showing_cancelled&parent_type=showings"
        return params
    }
    
    func afterCancelRequest(_ response: Data) {
        let result = JSON(data: response)
        if(result["result"].bool == true ) {
            DispatchQueue.main.async {
                let alertController = UIAlertController(title:"Success", message: "The request has been canceled", preferredStyle: .alert)
                let homeAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    self.stopCongratulationTimer()
                    self.gotoSelectAnotherAgent()
                }
                alertController.addAction(homeAction)
                self.present(alertController, animated: true, completion: nil)
            }
        } else {
            var msg = "Failed to cancel the request, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }
    
    @IBAction func btnCallAgent(_ sender: AnyObject) {
        self.chatAgent()
    }
    
    func chatAgent() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc : ChatViewController = mainStoryboard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        vc.to = self.viewData["realtor"]["id"].stringValue
        self.navigationController?.show(vc, sender: nil)
    }
    
    fileprivate func callNumber(_ phoneNumber:String) {
        if let phoneCallURL:URL = URL(string: "tel://\(phoneNumber)") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL);
            }
        }
    }

    @IBAction func btnHome(_ sender: AnyObject) {
        self.stopCongratulationTimer()
        Utility().goHome(self)
    }
    
    @IBAction func btnSearchAgain(_ sender: AnyObject) {
        self.stopCongratulationTimer()
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
            description += Property().getField("bedrooms")+" Bed / "
        }
        if(!Property().getField("bathrooms").isEmpty) {
            description += Property().getField("bathrooms")+" Bath / "
        }
        if(!Property().getField("property_type").isEmpty) {
            description += Property().getField("property_type")+" / "
        }
        if(!Property().getField("lot_size").isEmpty) {
            description += Property().getField("lot_size")
        }
        self.lblDescription.text = description
    }
    
    func startCongratulationTimer() {
        if(self.congratutationSecondsCount > 0) {
            self.stopCongratulationTimer()
            self.congratulationTimer = Timer.scheduledTimer(timeInterval: self.congratutationSeconds,
                target:self,
                selector:#selector(CongratulationsViewController.showWaitingForAgentConfirmation),
                userInfo:nil,
                repeats:true)
        } else {
            self.stopCongratulationTimer()
        }
    }
    
    func stopCongratulationTimer() {
        if self.congratulationTimer != nil {
            self.congratulationTimer!.invalidate()
        }
    }
    
    func showWaitingForAgentConfirmation(){
        self.requestSeconds+=1
        if(self.congratutationSecondsCount > 0) {
            self.congratutationSecondsCount-=1
            self.findShowingInfo()
            DispatchQueue.main.async {
                self.waitingForAgentConfirmationLabel.text = "Waiting for agent confirmation... \(self.congratutationSecondsCount)"
            }
        } else {
            self.stopCongratulationTimer()
            self.findShowingInfo()
        }
    }
    
    func findShowingInfo() {
        if(self.requestSeconds == 4 || self.congratutationSecondsCount <= 0) {
            self.requestSeconds = 0;
            let url = AppConfig.APP_URL+"/get_showing_info/"+self.viewData["showing"]["id"].stringValue
            Request().get(url, successHandler: {(response) in self.loadShowingData(response)})
        }
    }
    
    func loadShowingData(_ response: Data){
        let result = JSON(data: response)
        if(self.congratutationSecondsCount > 0 && result["showing_status"].int == 0) {
        
        }else if(result["showing_status"].int == 0) {
            self.noResponse()
            
        } else if(result["showing_status"].int == 1) {
            self.stopCongratulationTimer()
            Utility().displayAlert(self,title: "Success", message:"An Agent is on their way to show you the above property PRONTO!", performSegue:"showCurrentShowing")
            
        } else if(result["showing_status"].int == 2) {
            self.requestRejected()
        }
    }
    
    func noResponse() {
        self.stopCongratulationTimer()
        DispatchQueue.main.async {
            let alertController = UIAlertController(title:"Message", message: "The agent has not responded to the request", preferredStyle: .alert)
            let homeAction = UIAlertAction(title: "Home", style: UIAlertActionStyle.default) {
                UIAlertAction in
                Utility().goHome(self)
            }
        
            let cancelAction = UIAlertAction(title: "Cancel Request", style: UIAlertActionStyle.default) {
                UIAlertAction in
                self.cancelRequest()
            }
        
            let waitAction = UIAlertAction(title: "Wait", style: UIAlertActionStyle.default) {
                UIAlertAction in
                self.congratutationSecondsCount = AppConfig.SHOWING_WAIT_SECONDS
                self.startCongratulationTimer()
            }
        
            alertController.addAction(homeAction)
            alertController.addAction(cancelAction)
            alertController.addAction(waitAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func requestRejected() {
        self.stopCongratulationTimer()
        DispatchQueue.main.async {
            let alertController = UIAlertController(title:"Message", message: "The agent is not available at this time. Please choose another", preferredStyle: .alert)
            let homeAction = UIAlertAction(title: "Home", style: UIAlertActionStyle.default) {
                UIAlertAction in
                Utility().goHome(self)
            }
            let selectAgentAction = UIAlertAction(title: "Select Another", style: UIAlertActionStyle.default) {
                UIAlertAction in
                self.gotoSelectAnotherAgent()
            }
            alertController.addAction(homeAction)
            alertController.addAction(selectAgentAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func gotoSelectAnotherAgent() {
        DispatchQueue.main.async {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let viewController : SeeItNowViewController = mainStoryboard.instantiateViewController(withIdentifier: "SeeItNowViewController") as! SeeItNowViewController
            self.navigationController?.show(viewController, sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "CongratulationsToFeedBack1") {
            let view: FeedBack1ViewController = segue.destination as! FeedBack1ViewController
            view.showStartMessage  = true
            view.viewData = self.viewData
        }
        if (segue.identifier == "showCurrentShowing") {
            let view: CurrentShowingViewController = segue.destination as! CurrentShowingViewController
            view.showingId = self.viewData["showing"]["id"].stringValue
        }
    }
    
}
