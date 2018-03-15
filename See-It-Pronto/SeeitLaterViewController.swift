//
//  SeeitLaterViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/6/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class SeeitLaterViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate  {

    var viewData:JSON = []
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var txtDate: UITextField!
    @IBOutlet weak var agentPhoto: UIImageView!
    @IBOutlet weak var agentName: UILabel!
    var animateDistance: CGFloat!
    var seeItLaterDate:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtDate.delegate = self
        self.showPropertydetails()
        self.showRealtorData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
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
    
    @IBAction func btnBack(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnShowDatePicker(_ sender: AnyObject) {
        DatePickerDialog().show("Select Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .dateAndTime) {
            (date) -> Void in
            var dateTime = "\(date)"
            dateTime = dateTime.replacingOccurrences(of: " +0000",  with: "", options: NSString.CompareOptions.literal, range: nil)
            self.seeItLaterDate = dateTime
            let timestamp = DateFormatter.localizedString(from: dateTime.toDateTime(), dateStyle: .short, timeStyle: .short)
            self.txtDate.text = timestamp
        }
    }
    
    @IBAction func btnMyListing(_ sender: AnyObject) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "SeeItLaterBuyerViewController") as! SeeItLaterBuyerViewController
        self.navigationController?.show(viewController, sender: nil)
    }
    
    func showPropertydetails() {
        DispatchQueue.main.async {
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
    }
    
    func showRealtorData() {
        DispatchQueue.main.async {
            let name            = PropertyRealtor().getField("first_name")+" "+PropertyRealtor().getField("last_name")
            self.agentName.text = name
            let image           = PropertyRealtor().getField("url_image")
            Utility().showPhoto(self.agentPhoto, imgPath: image,defaultImg: "default_user_photo")
        }
    }
    
    @IBAction func btnSearchAgain(_ sender: AnyObject) {
        Utility().goHome(self)
    }
    
    @IBAction func btnSubmit(_ sender: AnyObject) {
        if(!self.seeItLaterDate.isEmpty) {
            self.sendRequest()
        } else  {
            Utility().displayAlert(self, title: "Message", message: "Please select a date", performSegue: "")
        }
    }
    
    func sendRequest() {
        //create params
        let propertyDescription = "\(Property().getField("bedrooms")) Bd / \(Property().getField("bathrooms")) Ba /"
        var params = "buyer_id="+User().getField("id")+"&realtor_id="+PropertyRealtor().getField("id")+"&property_id="+Property().getField("id")
        params     = params+"&type=see_it_later&date=\(self.seeItLaterDate)&property_class=\(Property().getField("property_class"))"
        params     = params+"&property_price=\(Property().getField("price"))&property_address=\(Property().getField("address"))&property_description=\(propertyDescription)"
        params     = params+"&property_license=\(Property().getField("license"))"
        let url    = AppConfig.APP_URL+"/seeitpronto"
        Request().post(url, params:params,controller: self,successHandler: {(response) in self.afterPostRequest(response)});
    }
        
    func afterPostRequest(_ response: Data) {
        let result = JSON(data: response)
        if(result["result"].bool == true) {
            self.viewData = result
            DispatchQueue.main.async {
                let alertController = UIAlertController(title:"Success", message: "The request has been sent, Please wait for the agent confirmation", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    Utility().goHome(self)
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        } else {
            var msg = "Error sending your request, please try later"
            if(!result["msg"].stringValue.isEmpty) {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let textFieldRect : CGRect = self.view.window!.convert(textField.bounds, from: textField)
        let viewRect : CGRect = self.view.window!.convert(self.view.bounds, from: self.view)
        let midline : CGFloat = textFieldRect.origin.y + 0.5 * textFieldRect.size.height
        let numerator : CGFloat = midline - viewRect.origin.y - MoveKeyboard.MINIMUM_SCROLL_FRACTION * viewRect.size.height
        let denominator : CGFloat = (MoveKeyboard.MAXIMUM_SCROLL_FRACTION - MoveKeyboard.MINIMUM_SCROLL_FRACTION) * viewRect.size.height
        var heightFraction : CGFloat = numerator / denominator
        if heightFraction < 0.0 {
            heightFraction = 0.0
        } else if heightFraction > 1.0 {
            heightFraction = 1.0
        }
        let orientation : UIInterfaceOrientation = UIApplication.shared.statusBarOrientation
        if (orientation == UIInterfaceOrientation.portrait || orientation == UIInterfaceOrientation.portraitUpsideDown) {
            animateDistance = floor(MoveKeyboard.PORTRAIT_KEYBOARD_HEIGHT * heightFraction)
        } else {
            animateDistance = floor(MoveKeyboard.LANDSCAPE_KEYBOARD_HEIGHT * heightFraction)
        }
        var viewFrame : CGRect = self.view.frame
        viewFrame.origin.y -= animateDistance
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(TimeInterval(MoveKeyboard.KEYBOARD_ANIMATION_DURATION))
        self.view.frame = viewFrame
        UIView.commitAnimations()
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        var viewFrame : CGRect = self.view.frame
        viewFrame.origin.y += animateDistance
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(TimeInterval(MoveKeyboard.KEYBOARD_ANIMATION_DURATION))
        self.view.frame = viewFrame
        UIView.commitAnimations()
    }
    
}
