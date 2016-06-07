//
//  RealtorForm1ViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/4/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class RealtorForm3ViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var lblShowingRate: UILabel!
    @IBOutlet weak var lblTravelRate: UILabel!
    
    
    var viewData:JSON = []
    var numberShowingRate:String = "25"
    var numberTravelRange:String = "50"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.findUserInfo()
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
    
    @IBAction func editShowingRate(sender: AnyObject) {
        
        let pickerView = CustomPickerDialog.init()
        var arrayDataSource:[String] = []
        for i in 0...50 {
            arrayDataSource.append(String(i))
        }
        pickerView.setDataSource(arrayDataSource)
        pickerView.selectValue(self.numberShowingRate)
        
        pickerView.showDialog("Select Showing Rate", doneButtonTitle: "Done", cancelButtonTitle: "Cancel") { (result) -> Void in
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
        
        pickerView.showDialog("Select Travel Range", doneButtonTitle: "Done", cancelButtonTitle: "Cancel") { (result) -> Void in
            //self.lblResult.text = result
            let travelRange = result
            self.numberTravelRange = result
            self.showRates("", traveRange: String(travelRange))
        }
    }
    
    @IBAction func btnBack(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btnMakeSomeMoney(sender: AnyObject) {
        User().updateField("is_login", value: "1")
        save()
    }
    
    func save() {
        //create params
        let showingRate = self.numberShowingRate
        let travelRate  = self.numberTravelRange
        let params = "id="+self.viewData["id"].stringValue+"&realtor_id="+self.viewData["realtor_id"].stringValue+"&showing_rate="+showingRate+"&travel_range="+travelRate
        let url = AppConfig.APP_URL+"/users/"+self.viewData["id"].stringValue
        Request().put(url, params:params,controller:self,successHandler: {(response) in self.afterPost(response)});
    }
    
    func afterPost(let response: NSData) {
        let result = JSON(data: response)
        if(result["result"].bool == true) {
            self.viewData = result
            Utility().performSegue(self, performSegue: "RealtorForm3")
        } else {
            var msg = "Error saving, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title:"Error", message:msg, performSegue:"")
        }
    }
    
    /*@IBAction func editShowingRate(sender: AnyObject) {
        let showingRate = Int(roundf(slShowingRate.value))
        self.showRates(String(showingRate), traveRange: "")
    }
    
    @IBAction func editTravelRate(sender: AnyObject) {
        let travelRange = Int(roundf(slTravelRate.value))
        self.showRates("", traveRange: String(travelRange))
    }*/
    
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
            if(!result["showing_rate"].stringValue.isEmpty) {
                self.numberShowingRate = result["showing_rate"].stringValue
                //self.slShowingRate.value = Float(result["showing_rate"].stringValue)!
                self.showRates(result["showing_rate"].stringValue, traveRange: "")
            }
            if(!result["travel_range"].stringValue.isEmpty) {
                self.numberTravelRange = result["travel_range"].stringValue
                //self.slTravelRate.value = Float(result["travel_range"].stringValue)!
                self.showRates("", traveRange: result["travel_range"].stringValue)
            }
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "RealtorForm1") {
            let view: RealtorForm2ViewController = segue.destinationViewController as! RealtorForm2ViewController
            view.viewData  = self.viewData
        }
    }

}
