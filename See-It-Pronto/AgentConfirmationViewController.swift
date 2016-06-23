//
//  AgentConfirmationViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/6/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class AgentConfirmationViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    var viewData:JSON = []
    @IBOutlet weak var txtCouponCode: UITextField!
    @IBOutlet weak var agentPhoto: UIImageView!
    @IBOutlet weak var lblBrokerAgent: UILabel!
    @IBOutlet weak var lblAgentName: UILabel!
    @IBOutlet weak var ratingImage: UIImageView!
    @IBOutlet weak var lblRaringLabel: UILabel!
    @IBOutlet weak var lblShowingRate: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var propertyImage: UIImageView!
    @IBOutlet weak var propertyAddress: UILabel!
    var animateDistance: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtCouponCode.delegate = self
        self.loadPropertyData()
        self.loadRealtorData()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
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
    
    @IBAction func btnSearchAgain(sender: AnyObject) {
        Utility().goHome(self)
    }
    
    @IBAction func btnSendRequest(sender: AnyObject) {
        self.sendRequest()
    }
    
    func sendRequest() {
        //create params
        var params = "buyer_id="+User().getField("id")+"&realtor_id="+PropertyRealtor().getField("id")+"&property_id="+Property().getField("id")
        params     = params+"&type=\(PropertyAction().getField("type"))&coupon_code=\(self.txtCouponCode.text!)"
        params     = params+"&date=\(Utility().getCurrentDate("-"))&property_class=\(Property().getField("property_class"))"
        print(params)
        let url    = AppConfig.APP_URL+"/seeitpronto"
        Request().post(url, params:params,controller: self,successHandler: {(response) in self.afterPostRequest(response)});
    }
    
    func afterPostRequest(let response: NSData) {
        let result = JSON(data: response)
        if(result["result"].bool == true) {
            self.viewData = result
            dispatch_async(dispatch_get_main_queue()) {
                self.performSegueWithIdentifier("showCongratulationView", sender: self)
            }
        } else {
            var msg = "Error sending your request, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }
    
    func loadPropertyData(){
        let image = Property().getField("image")
        self.propertyAddress.text = Property().getField("address")
        if(!image.isEmpty) {
            Utility().showPhoto(self.propertyImage, imgPath: image)
        }
    }
    
    func loadRealtorData(){
        let name          = PropertyRealtor().getField("first_name")+" "+PropertyRealtor().getField("last_name")
        lblAgentName.text = name
        let showingRate   = PropertyRealtor().getField("showing_rate")
        let rating        = PropertyRealtor().getField("rating")
        let image         = PropertyRealtor().getField("url_image")
        var distance      = PropertyRealtor().getField("travel_range")
        if(!distance.isEmpty) {
            distance = distance.stringByReplacingOccurrencesOfString("mi",  withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        }
        
        self.lblBrokerAgent.text = PropertyRealtor().getField("brokeragent")
        self.lblShowingRate.text = (!showingRate.isEmpty) ? "$"+showingRate : ""
        self.lblDistance.text    = (!distance.isEmpty) ? distance+" mi" : ""
        self.lblRaringLabel.text = (!rating.isEmpty) ? rating+" of 5" : ""
        if(!image.isEmpty) {
            Utility().showPhoto(self.agentPhoto, imgPath: image)
        }
        if(!rating.isEmpty) {
            ratingImage.image = UIImage(named: rating+"stars")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showCongratulationView") {
            let view: CongratulationsViewController = segue.destinationViewController as! CongratulationsViewController
            view.viewData  = self.viewData
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
