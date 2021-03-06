//
//  AgentConfirmationViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/6/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class AgentConfirmationViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var lblPaymentDescription: UILabel!
    var viewData:JSON = []
    @IBOutlet weak var txtCouponCode: UITextField!
    @IBOutlet weak var agentPhoto: UIImageView!
    @IBOutlet weak var lblBrokerAgent: UILabel!
    @IBOutlet weak var lblAgentName: UILabel!
    @IBOutlet weak var ratingImage: UIImageView!
    @IBOutlet weak var lblRaringLabel: UILabel!
    //@IBOutlet weak var lblShowingRate: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var propertyImage: UIImageView!
    @IBOutlet weak var propertyAddress: UILabel!
    var animateDistance: CGFloat!
    var realtorId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblPaymentDescription.text = "Once you select the \"Send Request\" button below, your request will be sent to the agent. Once they confirm, your card will be charged $\(AppConfig.SHOWING_PRICE)"
        self.txtCouponCode.delegate = self
        self.loadPropertyData()
        self.loadRealtorData()
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
    
    @IBAction func btnSearchAgain(_ sender: AnyObject) {
        Utility().goHome(self)
    }
    
    @IBAction func btnSendRequest(_ sender: AnyObject) {
        self.sendRequest()
    }
    
    func sendRequest() {
        //create params
        let currentDate = "\(Utility().getCurrentDate("-")) \(Utility().getTime(":"))"
        let propertyDescription = "\(Property().getField("bedrooms")) Bd/ \(Property().getField("bathrooms")) Ba"
        var params = "buyer_id="+User().getField("id")+"&realtor_id="+PropertyRealtor().getField("id")+"&property_id="+Property().getField("id")
        params     = params+"&type=\(PropertyAction().getField("type"))&coupon_code=\(self.txtCouponCode.text!)"
        params     = params+"&date=\(currentDate)&property_class=\(Property().getField("property_class"))"
        params     = params+"&property_price=\(Property().getField("price"))&property_address=\(Property().getField("address"))&property_description=\(propertyDescription)"
        params     = params+"&property_license=\(Property().getField("license"))"
        print(params)
        let url    = AppConfig.APP_URL+"/seeitpronto"
        Request().post(url, params:params,controller: self,successHandler: {(response) in self.afterPostRequest(response)});
    }
    
    func afterPostRequest(_ response: Data) {
        let result = JSON(data: response)
        if(result["result"].bool == true) {
            self.viewData = result
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "showCongratulationView", sender: self)
            }
        } else {
            var msg = "Error sending your request, please try later"
            if(!result["msg"].stringValue.isEmpty) {
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
        //let showingRate   = PropertyRealtor().getField("showing_rate")
        let rating        = PropertyRealtor().getField("rating")
        let image         = PropertyRealtor().getField("url_image")
        var distance      = PropertyRealtor().getField("travel_range")
        if(!distance.isEmpty) {
            distance = distance.replacingOccurrences(of: "mi",  with: "", options: NSString.CompareOptions.literal, range: nil)
        }
        
        self.lblBrokerAgent.text = PropertyRealtor().getField("brokeragent")
        //self.lblShowingRate.text = (!showingRate.isEmpty) ? "$"+showingRate : ""
        self.lblDistance.text    = (!distance.isEmpty) ? distance+" mi" : ""
        self.lblRaringLabel.text = (!rating.isEmpty) ? rating+" of 5" : ""
        Utility().showPhoto(self.agentPhoto, imgPath: image,defaultImg: "default_user_photo")
        
        if(!rating.isEmpty) {
            ratingImage.image = UIImage(named: rating+"stars")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showCongratulationView") {
            let view: CongratulationsViewController = segue.destination as! CongratulationsViewController
            view.viewData  = self.viewData
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
