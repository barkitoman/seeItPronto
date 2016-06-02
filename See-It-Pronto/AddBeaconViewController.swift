//
//  AddBeaconViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/4/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class AddBeaconViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate   {

    @IBOutlet weak var btnSelectBeacon: UIButton!
    var viewData:JSON = []
    @IBOutlet weak var txtLocation: UITextField!
    @IBOutlet weak var previewImage: UIImageView!
    var haveImage:Bool = false
    var propertyId:String = ""
    var beaconId = ""
    var animateDistance: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.propertyId = self.viewData["property"]["id"].stringValue
        self.viewData["id"] = JSON("")
        self.selfDelegate()
        self.findPropertyBeacon()
    }
    
    func reloadButtonTitle() {
        dispatch_async(dispatch_get_main_queue()) {
            self.btnSelectBeacon.setTitle(self.beaconId, forState: .Normal)
        }
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
        //self.txtBeaconId.delegate = self
        //self.txtBrand.delegate = self
        self.txtLocation.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func btnBack(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func btnCancel(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btnSave(sender: AnyObject) {
        if(!self.beaconId.isEmpty) {
            self.save()
        } else {
            Utility().displayAlert(self, title: "Error", message: "Please select a beacon", performSegue: "")
        }
    }
    
    func save() {
        var propertyClass = self.viewData["property_class"].stringValue
        if(self.viewData["property_class"].stringValue.isEmpty && !self.viewData["property"]["class"].stringValue.isEmpty) {
            propertyClass = self.viewData["property"]["class"].stringValue
        }
        var url = AppConfig.APP_URL+"/beacons"
        var params = "beacon_id=\(self.beaconId)&location=\(self.txtLocation.text!)"
        params     = params+"&state_beacon=0&property_id=\(self.propertyId)&user_id=\(User().getField("id"))&property_class=\(propertyClass)"
        if(!self.viewData["id"].stringValue.isEmpty) {
            //if user is editing a beacon
            params = params+"&id="+self.viewData["id"].stringValue
            url = AppConfig.APP_URL+"/beacons/"+self.viewData["id"].stringValue
            Request().put(url, params:params,controller:self,successHandler: {(response) in self.afterPost(response)});
        } else {
            //if user is registering a new beacon
            Request().post(url, params:params,controller: self,successHandler: {(response) in self.afterPost(response)});
        }
    }
    
    func afterPost(let response: NSData) {
        let result = JSON(data: response)
        if(result["result"].bool == true ) {
            self.viewData = result
            dispatch_async(dispatch_get_main_queue()) {
                self.uploadImage()
            }
            Utility().displayAlert(self,title: "Success", message:"The data have been saved correctly", performSegue:"")
        } else {
            var msg = "Error saving, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }

    @IBAction func btnChoosePicture(sender: AnyObject) {
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(myPickerController, animated: true, completion: nil)
    }
    
    //display image after select
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.previewImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.haveImage = true
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //upload photo to server
    func uploadImage() {
        if (self.previewImage.image != nil && self.haveImage == true) {
            let imageData:NSData = UIImageJPEGRepresentation(self.previewImage.image!, 1)!
            SRWebClient.POST(AppConfig.APP_URL+"/beacons/"+self.viewData["id"].stringValue)
                .data(imageData, fieldName:"image", data:["id":self.viewData["id"].stringValue,"_method":"PUT"])
                .send({(response:AnyObject!, status:Int) -> Void in
                    },failure:{(error:NSError!) -> Void in
                        print("ERROR UPLOADING BEACON IMAGE")
                })
        }
    }
    
    func findPropertyBeacon() {
        let url = AppConfig.APP_URL+"/get_property_beacons/"+User().getField("id")+"/"+self.propertyId
        Request().get(url, successHandler: {(response) in self.loadDataToEdit(response)})
    }
    
    func loadDataToEdit(let response: NSData) {
        let result = JSON(data: response)
        dispatch_async(dispatch_get_main_queue()) {
            if(!result["id"].stringValue.isEmpty) {
                self.viewData = result
                self.beaconId = result["beacon_id"].stringValue
                if(!result["beacon_id"].stringValue.isEmpty) {
                    self.btnSelectBeacon.setTitle(result["beacon_id"].stringValue, forState: .Normal)
                }
                self.txtLocation.text = result["location"].stringValue
                if(!result["url_image"].stringValue.isEmpty) {
                    Utility().showPhoto(self.previewImage, imgPath: result["url_image"].stringValue)
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "chowSelectBeacon" {
            let vc = segue.destinationViewController as! SelectBeaconViewController
            vc.canSelectBeacon = true
            vc.addBeaconVC = self
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
