//
//  ListingDetailsViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/4/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class ListingDetailsViewController: UIViewController {

    var viewData:JSON = []
    var propertyId:String = ""
    
    @IBOutlet weak var propertyImage: UIImageView!
    @IBOutlet weak var propertyDescription: UILabel!
    @IBOutlet weak var txtShowingInstructions: UITextView!
    @IBOutlet weak var swBeacon: UISwitch!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.findPropertyDetails()
        self.findPropertyListing()
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
    
    @IBAction func btnBack(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btnCancel(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btnUpdate(sender: AnyObject) {
        self.updateData()
    }
    
    func updateData() {
        var url = AppConfig.APP_URL+"/realtor_properties"
        var params = "showing_instruction="+self.txtShowingInstructions.text!+"&owner_email="+self.txtEmail.text!
        params     =  params+"&owner_phone="+self.txtPhone.text!+"&user_id="+User().getField("id")+"&property_id="+self.propertyId
        if(!self.viewData["id"].stringValue.isEmpty) {
            //if user is editing a beacon
            params = params+"&id="+self.viewData["id"].stringValue
            url = AppConfig.APP_URL+"/realtor_properties/"+self.viewData["id"].stringValue
            Request().put(url, params:params,successHandler: {(response) in self.afterUpdateRequest(response)});
        } else {
            //if user is registering a new beacon
            Request().post(url, params:params,successHandler: {(response) in self.afterUpdateRequest(response)});
        }
    }
    
    func afterUpdateRequest(let response: NSData) {
        let result = JSON(data: response)
        if(result["result"].bool == true ) {
            self.viewData = result
            Utility().displayAlert(self,title: "Success", message:"The data have been saved correctly", performSegue:"")
        } else {
            var msg = "Error saving, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }
    
    func findPropertyDetails(){
        let url = AppConfig.APP_URL+"/real_state_property_basics/get_property_details/"+self.propertyId
        Request().get(url, successHandler: {(response) in self.loadPropertyDetails(response)})
    }
    
    func loadPropertyDetails(let response: NSData) {
        dispatch_async(dispatch_get_main_queue()) {
            let result = JSON(data: response)
            var description = result["address"].stringValue+" $"+result["price"].stringValue
            description     = description+" "+result["bedrooms"].stringValue+"Br / "
            description     = description+result["bathrooms"].stringValue+"Ba"
            self.propertyDescription.text = description
            if(!result["images"][0].stringValue.isEmpty) {
                Utility().showPhoto(self.propertyImage, imgPath: result["images"][0].stringValue)
            }
        }
    }
    
    func findPropertyListing(){
        let url = AppConfig.APP_URL+"/realtor_property_listing/"+self.propertyId
        Request().get(url, successHandler: {(response) in self.loadPropertyListing(response)})
    }
    
    func loadPropertyListing(let response: NSData){
        dispatch_async(dispatch_get_main_queue()) {
            let result = JSON(data: response)
            self.viewData = result
            self.txtShowingInstructions.text = result["showing_instruction"].stringValue
            self.txtEmail.text = result["owner_email"].stringValue
            self.txtPhone.text = result["owner_phone"].stringValue
        }
    }
    
}
