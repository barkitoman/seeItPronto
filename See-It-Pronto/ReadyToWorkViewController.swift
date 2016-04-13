//
//  ReadyToWorkViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 4/12/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class ReadyToWorkViewController: UIViewController {

    var viewData:JSON = []
    @IBOutlet weak var slShowingRate: UISlider!
    @IBOutlet weak var slTravelRate: UISlider!
    @IBOutlet weak var lblShowingRate: UILabel!
    @IBOutlet weak var lblTravelRate: UILabel!
    
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
    
    @IBAction func btnActive(sender: AnyObject) {
        self.save("1")
    }
    
    @IBAction func btnInactive(sender: AnyObject) {
        self.save("0")
    }
    
    @IBAction func editShowingRate(sender: AnyObject) {
        let showingRate = Int(roundf(slShowingRate.value))
        self.showRates(String(showingRate), traveRange: "")
    }
    
    @IBAction func editTravelRate(sender: AnyObject) {
        let travelRange = Int(roundf(slTravelRate.value))
        self.showRates("", traveRange: String(travelRange))
    }
    
    func showRates(showingRate:String,traveRange:String) {
        if(!showingRate.isEmpty){
            self.lblShowingRate.text = "Your Rate: $\(showingRate) per showing"
        }
        if(!traveRange.isEmpty){
            self.lblTravelRate.text  = "You are willing to travel up to \(traveRange) miles to show a property"
        }
    }

    func save(shoingStatus:String) {
        //create params
        let showingRate = Utility().sliderValue(self.slShowingRate)
        let travelRate  = Utility().sliderValue(self.slTravelRate)
        let params = "id="+self.viewData["id"].stringValue+"&realtor_id="+self.viewData["realtor_id"].stringValue+"&showing_rate="+showingRate+"&travel_range="+travelRate+"&active_for_showing="+shoingStatus
        let url = AppConfig.APP_URL+"/users/"+User().getField("id")
        Request().put(url, params:params,successHandler: {(response) in self.afterPost(response)});
    }
    
    func afterPost(let response: NSData) {
        let result = JSON(data: response)
        if(result["result"].bool == true) {
            self.viewData = result
            dispatch_async(dispatch_get_main_queue()) {
                self.performSegueWithIdentifier("showRealtorHome", sender: self)
            }
        } else {
            var msg = "Error saving, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title:"Error", message:msg, performSegue:"")
        }
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
        dispatch_async(dispatch_get_main_queue()) {
            let result = JSON(data: response)
            self.viewData = result
            if(!result["showing_rate"].stringValue.isEmpty) {
                self.slShowingRate.value = Float(result["showing_rate"].stringValue)!
                self.showRates(result["showing_rate"].stringValue, traveRange: "")
            }
            if(!result["travel_range"].stringValue.isEmpty) {
                self.slTravelRate.value = Float(result["travel_range"].stringValue)!
                self.showRates("", traveRange: result["travel_range"].stringValue)
            }
        }
    }

}
