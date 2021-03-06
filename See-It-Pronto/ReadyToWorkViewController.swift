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
    
    //@IBOutlet weak var lblShowingRate: UILabel!
    @IBOutlet weak var lblTravelRate: UILabel!
    @IBOutlet weak var lblCurrentState: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    var pageTitle = "Ready to work?"
    //var numberShowingRate:String = "25"
    var numberTravelRange:String = "50"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblTitle.text = pageTitle
        self.findUserInfo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    @IBAction func btnActive(_ sender: AnyObject) {
        self.save("1")
    }
    
    @IBAction func btnInactive(_ sender: AnyObject) {
        self.save("0")
    }
    
//    @IBAction func editShowingRate(sender: AnyObject) {
//        
//        let pickerView = CustomPickerDialog.init()
//        var arrayDataSource:[String] = []
//        for i in 10...50 {
//            arrayDataSource.append(String(i))
//        }
//        pickerView.setDataSource(arrayDataSource)
//        pickerView.selectValue(self.numberShowingRate)
//        
//        pickerView.showDialog("Select Showing Rate", doneButtonTitle: "Done", cancelButtonTitle: "Cancel") { (result) -> Void in
//            //self.lblResult.text = result
//            let showingRate = result
//            self.numberShowingRate = result
//            self.showRates(String(showingRate), traveRange: "")
//        }
//
//    }
    
    @IBAction func editTravelRate(_ sender: AnyObject) {
        
        let pickerView = CustomPickerDialog.init()
        var arrayDataSource:[String] = []
        for i in 5...25 {
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
    
    func showRates(_ showingRate:String,traveRange:String) {
//        if(!showingRate.isEmpty){
//            self.lblShowingRate.text = "Your Rate: $\(showingRate) per showing"
//        }
        if(!traveRange.isEmpty){
            self.lblTravelRate.text  = "You are willing to travel up to \(traveRange) miles to show a property"
        }
    }

    func save(_ shoingStatus:String) {
        //create params
        DispatchQueue.main.async {
            BProgressHUD.showLoadingViewWithMessage("Loading...")
        }
        let travelRate  = self.numberTravelRange
        let params = "id="+self.viewData["id"].stringValue+"&realtor_id="+self.viewData["realtor_id"].stringValue+"&travel_range="+travelRate+"&active_for_showing="+shoingStatus
        let url = AppConfig.APP_URL+"/users/"+User().getField("id")
        Request().put(url, params:params,controller:self,successHandler: {(response) in self.afterPost(response)});
    }
    
    func afterPost(_ response: Data) {
        let result = JSON(data: response)
        DispatchQueue.main.async {
            BProgressHUD.dismissHUD(0)
        }
        if(result["result"].bool == true) {
            self.viewData = result
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "showRealtorHome", sender: self)
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
    
    func loadDataToEdit(_ response: Data) {
        DispatchQueue.main.async {
            let result = JSON(data: response)
            self.viewData = result
//            if(!result["showing_rate"].stringValue.isEmpty) {
//                //self.slShowingRate.value = Float(result["showing_rate"].stringValue)!
//                self.numberShowingRate = result["showing_rate"].stringValue
//                print(self.numberShowingRate)
//                self.showRates(result["showing_rate"].stringValue, traveRange: "")
//            }
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
