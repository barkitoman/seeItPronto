//
//  AgentConfirmationViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/6/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class AgentConfirmationViewController: UIViewController {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadPropertyData()
        self.loadRealtorData()
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
        params     = params+"&type="+PropertyAction().getField("type")+"&coupon_code="+self.txtCouponCode.text!+"&date="+Utility().getCurrentDate("-")
        let url    = AppConfig.APP_URL+"/seeitpronto"
        Request().post(url, params:params,successHandler: {(response) in self.afterPostRequest(response)});
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
    
}
