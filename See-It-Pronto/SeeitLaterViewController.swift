//
//  SeeitLaterViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/6/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class SeeitLaterViewController: UIViewController {

    var viewData:JSON = []
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var txtDate: UITextField!
    @IBOutlet weak var agentPhoto: UIImageView!
    @IBOutlet weak var agentName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showPropertydetails()
        self.showRealtorData()
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
    
    @IBAction func btnShowDatePicker(sender: AnyObject) {
        DatePickerDialog().show("Select Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .DateAndTime) {
            (date) -> Void in
            var dateTime = "\(date)"
            dateTime     = dateTime.stringByReplacingOccurrencesOfString(" +0000",  withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            self.txtDate.text = dateTime
        }
    }
    
    @IBAction func btnMyListing(sender: AnyObject) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let viewController = mainStoryboard.instantiateViewControllerWithIdentifier("SeeItLaterBuyerViewController") as! SeeItLaterBuyerViewController
        self.navigationController?.showViewController(viewController, sender: nil)
    }
    
    func showPropertydetails() {
        dispatch_async(dispatch_get_main_queue()) {
            let image = Property().getField("image")
            if(!image.isEmpty) {
                Utility().showPhoto(self.photo, imgPath: image)
            }
            self.lblPrice.text   = Utility().formatCurrency(Property().getField("price"))
            self.lblAddress.text = Property().getField("address")
            var description = ""
            if(!Property().getField("bedrooms").isEmpty) {
                description += "Bed "+Property().getField("bedrooms")+"/"
            }
            if(!Property().getField("bathrooms").isEmpty) {
                description += "Bath "+Property().getField("bathrooms")+"/"
            }
            if(!Property().getField("property_type").isEmpty) {
                description += Property().getField("property_type")+"/"
            }
            if(!Property().getField("lot_size").isEmpty) {
                description += Property().getField("lot_size")
            }
            self.lblDescription.text = description
        }
    }
    
    func showRealtorData() {
        dispatch_async(dispatch_get_main_queue()) {
            let name            = PropertyRealtor().getField("first_name")+" "+PropertyRealtor().getField("last_name")
            self.agentName.text = name
            let image           = PropertyRealtor().getField("url_image")
            if(!image.isEmpty) {
                Utility().showPhoto(self.agentPhoto, imgPath: image)
            }
        }
    }
    
    @IBAction func btnSearchAgain(sender: AnyObject) {
        Utility().goHome(self)
    }
    
    @IBAction func btnSubmit(sender: AnyObject) {
        self.sendRequest()
    }
    
    func sendRequest() {
        //create params
        var params = "buyer_id="+User().getField("id")+"&realtor_id="+PropertyRealtor().getField("id")+"&property_id="+Property().getField("id")
        params     = params+"&type=see_it_later&date=\(self.txtDate.text!)&property_class=\(Property().getField("property_class"))"
        let url    = AppConfig.APP_URL+"/seeitpronto"
        Request().post(url, params:params,successHandler: {(response) in self.afterPostRequest(response)});
    }
        
    func afterPostRequest(let response: NSData) {
        let result = JSON(data: response)
        if(result["result"].bool == true) {
            self.viewData = result
            dispatch_async(dispatch_get_main_queue()) {
                let alertController = UIAlertController(title:"Success", message: "The request has been sent, Please wait for the agent confirmation", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) {
                    UIAlertAction in
                    Utility().goHome(self)
                }
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        } else {
            var msg = "Error sending your request, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }
    
}
