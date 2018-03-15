//
//  RealtorForm1ViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/4/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class RealtorForm3ViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate {

    
    @IBOutlet weak var lblTravelRate: UILabel!
    var viewData:JSON = []
    var numberShowingRate:String = "25"
    var numberTravelRange:String = "50"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.findUserInfo()
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
    
    @IBAction func editTravelRate(_ sender: AnyObject) {
        
        let pickerView = CustomPickerDialog.init()
        var arrayDataSource:[String] = []
        for i in 5...25 {
            arrayDataSource.append(String(i))
        }
        pickerView.setDataSource(arrayDataSource)
        pickerView.selectValue(self.numberTravelRange)
        
        pickerView.showDialog("Select Travel Range", doneButtonTitle: "Done", cancelButtonTitle: "Cancel") { (result) -> Void in
            let travelRange = result
            self.numberTravelRange = result
            self.showRates("", traveRange: String(travelRange))
        }
    }
    
    @IBAction func btnBack(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnMakeSomeMoney(_ sender: AnyObject) {
        User().updateField("is_login", value: "1")
        self.save()
    }
    
    func save() {
        //create params
        let travelRate  = self.numberTravelRange
        let params = "id="+self.viewData["id"].stringValue+"&realtor_id="+self.viewData["realtor_id"].stringValue+"&travel_range="+travelRate
        let url = AppConfig.APP_URL+"/users/"+self.viewData["id"].stringValue
        Request().put(url, params:params,controller:self,successHandler: {(response) in self.afterPost(response)});
    }
    
    func afterPost(_ response: Data) {
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
    
    func findUserInfo() {
        let userId = User().getField("id")
        if(!userId.isEmpty) {
            self.viewData["id"] = JSON(userId)
            let url = AppConfig.APP_URL+"/user_info/"+userId
            Request().get(url, successHandler: {(response) in self.loadDataToEdit(response)})
        }
    }
    
    func loadDataToEdit(_ response: Data) {
        let result = JSON(data: response)
        DispatchQueue.main.async {
            self.viewData = result
            if(!result["showing_rate"].stringValue.isEmpty) {
                self.numberShowingRate = result["showing_rate"].stringValue
                self.showRates(result["showing_rate"].stringValue, traveRange: "")
            }
            if(!result["travel_range"].stringValue.isEmpty) {
                self.numberTravelRange = result["travel_range"].stringValue
                self.showRates("", traveRange: result["travel_range"].stringValue)
            }
        }
    }
    
    func showRates(_ showingRate:String,traveRange:String) {
        if(!traveRange.isEmpty){
            self.lblTravelRate.text  = "You are willing to travel up to \(traveRange) miles to show a property"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "RealtorForm1") {
            let view: RealtorForm2ViewController = segue.destination as! RealtorForm2ViewController
            view.viewData  = self.viewData
        }
    }

}
