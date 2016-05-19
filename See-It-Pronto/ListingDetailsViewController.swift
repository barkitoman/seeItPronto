//
//  ListingDetailsViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/4/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class ListingDetailsViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate {

    var viewData:JSON = []
    var propertyId:String = ""
    
    @IBOutlet weak var propertyImage: UIImageView!
    @IBOutlet weak var propertyDescription: UILabel!
    @IBOutlet weak var txtShowingInstructions: UITextView!
    @IBOutlet weak var swBeacon: UISwitch!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    var animateDistance: CGFloat!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selfDelegate()
        self.propertyId = self.viewData["property"]["id"].stringValue
        self.viewData["id"] = JSON("")
        BProgressHUD.showLoadingViewWithMessage("Loading")
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
    
    //selfDelegate, textFieldShouldReturn are functions for hide keyboard when press 'return' key
    func selfDelegate() {
        self.txtShowingInstructions.delegate = self
        self.txtEmail.delegate = self
        self.txtPhone.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
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
        var propertyClass = self.viewData["property_class"].stringValue
        if(self.viewData["property_class"].stringValue.isEmpty && !self.viewData["property"]["class"].stringValue.isEmpty) {
            propertyClass = self.viewData["property"]["class"].stringValue
        }
        var url = AppConfig.APP_URL+"/realtor_properties"
        var params = "showing_instruction=\(self.txtShowingInstructions.text!)&owner_email=\(self.txtEmail.text!)"
        params     = params+"&owner_phone=\(self.txtPhone.text!)&user_id=\(User().getField("id"))"
        params     = params+"&property_id=\(self.propertyId)&property_class=\(propertyClass)"
        if(!self.viewData["id"].stringValue.isEmpty) {
            //if user is editing a beacon
            params = params+"&id="+self.viewData["id"].stringValue
            url = AppConfig.APP_URL+"/realtor_properties/"+self.viewData["id"].stringValue
            Request().put(url, params:params,successHandler: {(response) in self.afterUpdateRequest(response)});
        } else {
            //if user is registering a new beacon
            Request().post(url, params:params, controller: self, successHandler: {(response) in self.afterUpdateRequest(response)});
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
        var propertyClass = self.viewData["property"]["class"].stringValue
        if(propertyClass.isEmpty) {propertyClass = "1"}
        let url = AppConfig.APP_URL+"/real_state_property_basics/get_property_details/\(self.propertyId)/\(propertyClass)/\(User().getField("id"))"
        Request().get(url, successHandler: {(response) in self.loadPropertyDetails(response)})
    }
    
    func loadPropertyDetails(let response: NSData) {
        dispatch_async(dispatch_get_main_queue()) {
            let result = JSON(data: response)
            var description = result["address"].stringValue+Utility().formatCurrency(result["price"].stringValue)
            description     = description+" "+result["bedrooms"].stringValue+"Bd / "
            description     = description+result["bathrooms"].stringValue+"Ba"
            self.propertyDescription.text = description
            if(!result["images"][0].stringValue.isEmpty) {
                Utility().showPhoto(self.propertyImage, imgPath: result["images"][0].stringValue)
            }
            BProgressHUD.dismissHUD(0)
        }
    }
    @IBAction func swBeaconState(sender: AnyObject) {
        let url = AppConfig.APP_URL+"/turn_beacon_on_off/"+User().getField("id")+"/"+self.propertyId+"/"+Utility().switchValue(self.swBeacon, onValue: "1", offValue: "0")
        Request().get(url, successHandler: {(response) in self.afterTurnOnOffBeacon(response)})
    }
    
    func afterTurnOnOffBeacon(let response: NSData) {
        let result = JSON(data: response)
        if(result["result"].bool == false ) {
            var msg = "Error saving, please try later"
            if(result["msg"].stringValue != "") {
                dispatch_async(dispatch_get_main_queue()) {
                    self.swBeacon.on = false
                }
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }
    
    func findPropertyListing(){
        let url = AppConfig.APP_URL+"/realtor_property_listing/"+User().getField("id")+"/"+self.propertyId
        Request().get(url, successHandler: {(response) in self.loadPropertyListing(response)})
    }
    
    func loadPropertyListing(let response: NSData) {
        let result = JSON(data: response)
        dispatch_async(dispatch_get_main_queue()) {
            if(!result["id"].stringValue.isEmpty) {
                self.viewData = result
                self.txtShowingInstructions.text = result["showing_instruction"].stringValue
                self.txtEmail.text = result["owner_email"].stringValue
                self.txtPhone.text = result["owner_phone"].stringValue
                if(result["state_beacon"].int == 1) {
                    self.swBeacon.on = true
                }
            }
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        let textFieldRect : CGRect = self.view.window!.convertRect(textField.bounds, fromView: textField)
        let viewRect : CGRect = self.view.window!.convertRect(self.view.bounds, fromView: self.view)
        let midline : CGFloat = textFieldRect.origin.y + 0.5 * textFieldRect.size.height
        let numerator : CGFloat = midline - viewRect.origin.y - MoveKeyboard.MINIMUM_SCROLL_FRACTION * viewRect.size.height
        let denominator : CGFloat = (MoveKeyboard.MAXIMUM_SCROLL_FRACTION - MoveKeyboard.MINIMUM_SCROLL_FRACTION) * viewRect.size.height
        var heightFraction : CGFloat = numerator / denominator
        if heightFraction < 0.0 {
            heightFraction = 0.0
        } else if heightFraction > 1.0 {
            heightFraction = 1.0
        }
        let orientation : UIInterfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
        if (orientation == UIInterfaceOrientation.Portrait || orientation == UIInterfaceOrientation.PortraitUpsideDown) {
            animateDistance = floor(MoveKeyboard.PORTRAIT_KEYBOARD_HEIGHT * heightFraction)
        } else {
            animateDistance = floor(MoveKeyboard.LANDSCAPE_KEYBOARD_HEIGHT * heightFraction)
        }
        var viewFrame : CGRect = self.view.frame
        viewFrame.origin.y -= animateDistance
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(NSTimeInterval(MoveKeyboard.KEYBOARD_ANIMATION_DURATION))
        self.view.frame = viewFrame
        UIView.commitAnimations()
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        var viewFrame : CGRect = self.view.frame
        viewFrame.origin.y += animateDistance
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(NSTimeInterval(MoveKeyboard.KEYBOARD_ANIMATION_DURATION))
        self.view.frame = viewFrame
        UIView.commitAnimations()
    }
    
}
