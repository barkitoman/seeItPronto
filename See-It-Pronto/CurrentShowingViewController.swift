//
//  CurrentShowingViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 4/7/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class CurrentShowingViewController: UIViewController {

    @IBOutlet weak var btnPanicButton: UIButton!
    @IBOutlet weak var propertyImage: UIImageView!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var propertyDescription: UILabel!
    @IBOutlet weak var btnShowingInstructionChat: UIButton!

    @IBOutlet weak var btnCall: UIButton!
    @IBOutlet weak var btnStartEndShowing: UIButton!
    @IBOutlet weak var btnInstructions: UIButton!
    var LocationTimer: Timer?
    
    var manager: OneShotLocationManager?
    var showingId:String = ""
    var startEndButtonAction = "start"
    var viewData:JSON = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.findShowing()
        self.showHideButtons()
    }
    
    func showHideButtons() {
        let role = User().getField("role")
        if(role == "buyer") {
            self.btnCall.isHidden = true
            self.btnStartEndShowing.isHidden = true
            self.btnPanicButton.isHidden = true
            DispatchQueue.main.async {
                self.btnShowingInstructionChat.setTitle("Chat With Agent", for: UIControlState())
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        super.viewWillAppear(animated)
        self.stopShowingEnded();
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if (navigationController?.topViewController != self) {
            navigationController?.isNavigationBarHidden = false
        }
        super.viewWillDisappear(animated)
    }
    
    @IBAction func btnHome(_ sender: AnyObject) {
        Utility().goHome(self)
    }
    
    func findShowing() {
        if(!self.showingId.isEmpty) {
            let url = AppConfig.APP_URL+"/get_showing_details/"+self.showingId+"/"+User().getField("id")
            Request().get(url, successHandler: {(response) in self.loadShowingData(response)})
        } else {
            let url = AppConfig.APP_URL+"/current_showing/"+User().getField("id")
            Request().get(url, successHandler: {(response) in self.loadShowingData(response)})
        }
    }
    
    func loadShowingData(_ response: Data) {
        let result = JSON(data: response)
        DispatchQueue.main.async {
            self.viewData = result
            if(self.viewData["showing"]["id"].stringValue.isEmpty) {
                self.showingNotExistMessage()
            }
            if(self.viewData["showing"]["showing_status"].int == 0
                && (self.viewData["showing"]["type"] == "see_it_later" || self.viewData["showing"]["type"] == "see_it_pronto")) {
                self.showingPendingMessage(self.viewData["showing"]["id"].stringValue)
            }
            self.address.text  = result["property"]["address"].stringValue
            self.lblPrice.text = Utility().formatCurrency(result["property"]["price"].stringValue)
            var description = ""
            description += result["property"]["bedrooms"].stringValue+" Bed / "
            description += result["property"]["bathrooms"].stringValue+" Bath / "
            if(!result["property"]["type"].stringValue.isEmpty) {
                description = description+result["property"]["type"].stringValue+" / "
            }
            if(!result["property"]["square_feed"].stringValue.isEmpty) {
                description = description+result["property"]["square_feed"].stringValue+" SqrFt"
            }
            self.propertyDescription.text = description
            if(!result["property"]["image"].stringValue.isEmpty) {
                Utility().showPhoto(self.propertyImage, imgPath: result["property"]["image"].stringValue)
            }
            if(User().getField("role") == "buyer") {
                self.intervalShowingEnded()
            }
        }
    }
    
    func showingPendingMessage(_ showingId:String) {
        let role = User().getField("role")
        if(role == "realtor") {
            DispatchQueue.main.async {
                let alertController = UIAlertController(title:"Message", message: "This showing request is pending to be approved", preferredStyle: .alert)
                let goAction = UIAlertAction(title: "View Request", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                
                    let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    let vc : ShowingRequestViewController = mainStoryboard.instantiateViewController(withIdentifier: "ShowingRequestViewController") as! ShowingRequestViewController
                    vc.showingId = showingId
                    self.navigationController?.show(vc, sender: nil)
                }
                let homeAction = UIAlertAction(title: "Home", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    Utility().goHome(self)
                }
                alertController.addAction(goAction)
                alertController.addAction(homeAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func showingNotExistMessage() {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title:"Message", message: "You don't have a current showing", preferredStyle: .alert)
            let homeAction = UIAlertAction(title: "Home", style: UIAlertActionStyle.default) {
                UIAlertAction in
                Utility().goHome(self)
            }
            alertController.addAction(homeAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnGetDirections(_ sender: AnyObject) {
        manager = OneShotLocationManager()
        manager!.fetchWithCompletion {location, error in
            // fetch location or an error
            if let loc  = location {
                let lat = (AppConfig.MODE == "PROD") ? "\(loc.coordinate.latitude)" : AppConfig().develop_lat()
                let lng = (AppConfig.MODE == "PROD") ? "\(loc.coordinate.longitude)": AppConfig().develop_lon()
                var address = self.viewData["property"]["address"].stringValue
                address = address.replacingOccurrences(of: " ", with: "+", options: NSString.CompareOptions.literal, range: nil)
                let fullAddress = "http://maps.apple.com/?saddr=\(lat),\(lng)&daddr=\(address)"
                UIApplication.shared.openURL(URL(string: fullAddress)!)
            } else if let _ = error {
                print("ERROR GETTING LOCATION")
            }
            // destroy the object immediately to save memory
            self.manager = nil
        }
    }
    
    @IBAction func btnViewDetails(_ sender: AnyObject) {
        Utility().goPropertyDetails(self,propertyId: self.viewData["showing"]["property_id"].stringValue, PropertyClass: self.viewData["showing"]["property_class"].stringValue)
    }
    
    @IBAction func btnShowingInstrunctions(_ sender: AnyObject) {
        if(User().getField("role") == "buyer") {
            DispatchQueue.main.async {
                let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let vc : ChatViewController = mainStoryboard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
                vc.to = self.viewData["realtor"]["id"].stringValue
                self.navigationController?.show(vc, sender: nil)
            }
        } else {
            if(!self.viewData["realtor_properties"]["showing_instruction"].stringValue.isEmpty) {
                var instructions = self.viewData["realtor_properties"]["type"].stringValue+"\n"
                instructions = instructions+self.viewData["realtor_properties"]["showing_instruction"].stringValue
                Utility().displayAlert(self, title: "Showing instructions", message: instructions, performSegue: "")
            } else {
                Utility().displayAlert(self, title: "Message", message: "You don't have showing instructions for this property", performSegue: "")
            }
        }
    }
    
    @IBAction func btnCallCustomer(_ sender: AnyObject) {
        DispatchQueue.main.async {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let vc : ChatViewController = mainStoryboard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
            vc.to = self.viewData["buyer"]["id"].stringValue
            self.navigationController?.show(vc, sender: nil)
        }
    }
    
    @IBAction func btnStartEndShowing(_ sender: AnyObject) {
        if(self.startEndButtonAction == "start") {
            self.startShowing()
        } else {
            self.endShowing()
        }
    }
    
    func startShowing() {
        self.startEndButtonAction = "end"
        DispatchQueue.main.async {
            self.btnStartEndShowing.setTitle("End showing", for: UIControlState())
            self.btnStartEndShowing.backgroundColor = UIColor(rgba: "#45B5DC")
        }
    }
    
    func startShowingSendingMoney() {
        let url = AppConfig.APP_URL+"/start_showing/"+self.viewData["showing"]["id"].stringValue
        Request().get(url) { (response) -> Void in
            self.afterStartShowing(response)
        }
    }
    
    func afterStartShowing(_ response: Data) {
        let result = JSON(data: response)
        if(result["result"].bool == true ) {
            self.startEndButtonAction = "end"
            self.btnStartEndShowing.setTitle("End showing", for: UIControlState())
            self.btnStartEndShowing.backgroundColor = UIColor(rgba: "#45B5DC")
        } else {
            var msg = "Failed to start the showing request, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }
    
    func endShowing() {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title:"Confirmation", message: "Do you really want to end this showing?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) {
                UIAlertAction in
                self.sendEndShowingSaveRequest()
            }
            let noAction = UIAlertAction(title: "No", style: UIAlertActionStyle.default) {
                UIAlertAction in
            }
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    func sendEndShowingSaveRequest(){
        let url    = AppConfig.APP_URL+"/showings/"+self.viewData["showing"]["id"].stringValue
        var params = "id="+self.viewData["showing"]["id"].stringValue+"&showing_status=3"
        params     = self.endNotificationParams(params)
        Request().put(url, params:params,controller:self,successHandler: {(response) in self.afterCancelRequest(response)});
    }
    
    func endNotificationParams(_ params:String)->String {
        var params = params
        let fullUsername = User().getField("first_name")+" "+User().getField("last_name")
        params = params+"&notification=1&from_user_id="+User().getField("id")+"&to_user_id="+self.viewData["showing"]["buyer_id"].stringValue
        params = params+"&title=Showing Request Completed&property_id="+self.viewData["showing"]["property_id"].stringValue
        params = params+"&description=You have completed a showing with \(fullUsername) please give us your feedback"
        params = params+"&parent_id="+self.viewData["showing"]["id"].stringValue+"&notification_type=showing_completed&parent_type=showings"
        return params
    }
    
    func afterCancelRequest(_ response: Data) {
        let result = JSON(data: response)
        if(result["result"].bool == true ) {
            DispatchQueue.main.async {
                Utility().goHome(self)
            }
        } else {
            var msg = "Failed to completed the showing request, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }
    
    @IBAction func CallPanic(_ sender: AnyObject) {
        if let phoneCallURL:URL = URL(string: "tel://911") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL);
            }
        }
    }
    
    func findShowingEnded() {
        self.stopShowingEnded()
        let url = AppConfig.APP_URL+"/get_showing_details/\(self.viewData["showing"]["id"].stringValue)/"+User().getField("id")
        Request().get(url, successHandler: {(response) in self.loadShowingEndData(response)})
    }
    
    func loadShowingEndData(_ response: Data) {
        let result = JSON(data: response)
        DispatchQueue.main.async {
            if(!result["showing"]["id"].stringValue.isEmpty) {
                if(result["showing"]["showing_status"].stringValue == "3") {
                     let title = "Showing Request Completed"
                     let msg   = "You have completed this showing please give us your feedback"
                     Utility().displayAlert(self,title: title, message:msg, performSegue:"feedBackFromCurrentShowing")
                } else {
                    self.intervalShowingEnded();
                }
            } else {
                self.intervalShowingEnded();
            }
        }
    }
    
    func intervalShowingEnded() {
        self.LocationTimer = Timer.scheduledTimer(timeInterval: 4,
            target:self,
            selector:#selector(CurrentShowingViewController.findShowingEnded),
            userInfo:nil,
            repeats:true
        )
    }
    
    func stopShowingEnded() {
        if(self.LocationTimer != nil) {
            self.LocationTimer!.invalidate()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "feedBackFromCurrentShowing") {
            let view: FeedBack1ViewController = segue.destination as! FeedBack1ViewController
            view.viewData  = self.viewData
        }
    }
}
