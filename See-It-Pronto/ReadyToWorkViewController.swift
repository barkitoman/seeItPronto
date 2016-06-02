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
    
    @IBOutlet weak var lblShowingRate: UILabel!
    @IBOutlet weak var lblTravelRate: UILabel!
    @IBOutlet weak var lblCurrentState: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    var pageTitle = "Ready to work?"
    var numberShowingRate:String = "25"
    var numberTravelRange:String = "50"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblTitle.text = pageTitle
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
        
        let pickerView = CustomPickerDialog.init()
        var arrayDataSource:[String] = []
        for i in 0...50 {
            arrayDataSource.append(String(i))
        }
        pickerView.setDataSource(arrayDataSource)
        print(numberShowingRate)
        pickerView.selectValue(self.numberShowingRate)
        
        pickerView.showDialog("Select Showing Rate", doneButtonTitle: "done", cancelButtonTitle: "cancel") { (result) -> Void in
            //self.lblResult.text = result
            let showingRate = result
            self.numberShowingRate = result
            self.showRates(String(showingRate), traveRange: "")
        }

    }
    
    @IBAction func editTravelRate(sender: AnyObject) {
        
        let pickerView = CustomPickerDialog.init()
        var arrayDataSource:[String] = []
        for i in 10...99 {
            arrayDataSource.append(String(i))
        }
        pickerView.setDataSource(arrayDataSource)
        pickerView.selectValue(self.numberTravelRange)
        
        pickerView.showDialog("Select Travel Range", doneButtonTitle: "done", cancelButtonTitle: "cancel") { (result) -> Void in
            //self.lblResult.text = result
            let travelRange = result
            self.numberTravelRange = result
            self.showRates("", traveRange: String(travelRange))
        }
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
        let showingRate = numberShowingRate //Utility().sliderValue(self.slShowingRate)
        let travelRate  = numberTravelRange //Utility().sliderValue(self.slTravelRate)
        let params = "id="+self.viewData["id"].stringValue+"&realtor_id="+self.viewData["realtor_id"].stringValue+"&showing_rate="+showingRate+"&travel_range="+travelRate+"&active_for_showing="+shoingStatus
        let url = AppConfig.APP_URL+"/users/"+User().getField("id")
        Request().put(url, params:params,controller:self,successHandler: {(response) in self.afterPost(response)});
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
                //self.slShowingRate.value = Float(result["showing_rate"].stringValue)!
                self.numberShowingRate = result["showing_rate"].stringValue
                print(self.numberShowingRate)
                self.showRates(result["showing_rate"].stringValue, traveRange: "")
            }
            if(!result["travel_range"].stringValue.isEmpty) {
                //self.slTravelRate.value = Float(result["travel_range"].stringValue)!
                self.numberTravelRange = result["travel_range"].stringValue
                self.showRates("", traveRange: result["travel_range"].stringValue)
            }
            if(result["active_for_showing"].int == 1) {
                self.lblCurrentState.text = "You are currently active"
            } else {
                self.lblCurrentState.text = "You are currently inactive"
            }
        }
    }

}
