//
//  PropertyDetailsViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/5/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class PropertyDetailsViewController: UIViewController {

    var viewData:JSON = []
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblBedrooms: UILabel!
    @IBOutlet weak var lblBathrooms: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblSquareFeed: UILabel!
    @IBOutlet weak var lblLotSize: UILabel!
    @IBOutlet weak var lblYearBuilt: UILabel!
    @IBOutlet weak var btnSeeItPronto: UIButton!
    @IBOutlet weak var btnSeeItLater: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.findPropertyDetails()
        self.showHideButtons()
    }
    
    func showHideButtons() {
        let role = User().getField("role")
        if(role == "realtor") {
            btnSeeItPronto.hidden = true
            btnSeeItLater.hidden  = true
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
    
    @IBAction func btnBack(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btnSeeItPronto(sender: AnyObject) {
        let propertyActionData: JSON =  ["type":"see_it_pronto"]
        PropertyAction().saveIfExists(propertyActionData)
        self.performSegueWithIdentifier("selectAgentForProperty", sender: self)
    }
    
    @IBAction func btnSeeItLater(sender: AnyObject) {
        let propertyActionData: JSON =  ["type":"see_it_later"]
        PropertyAction().saveIfExists(propertyActionData)
        self.performSegueWithIdentifier("selectAgentForProperty", sender: self)
    }
    
    func findPropertyDetails(){
        let propertyId = Property().getField("id")
        let url = AppConfig.APP_URL+"/real_state_property_basics/get_property_details/"+propertyId+"/"+User().getField("id")
        Request().get(url, successHandler: {(response) in self.showPropertydetails(response)})
    }
    
    func showPropertydetails(let response: NSData) {
        let result = JSON(data: response)
        dispatch_async(dispatch_get_main_queue()) {
            if(!result["images"][0].stringValue.isEmpty) {
                Utility().showPhoto(self.photo, imgPath: result["images"][0].stringValue)
            }
            self.lblPrice.text      = Utility().formatCurrency(result["price"].stringValue)
            self.lblAddress.text    = result["address"].stringValue
            self.lblBedrooms.text   = result["bedrooms"].stringValue
            self.lblBathrooms.text  = result["bathrooms"].stringValue
            self.lblType.text       = result["property_type"].stringValue
            self.lblSquareFeed.text = result["square_feed"].stringValue
            self.lblLotSize.text    = result["lot_size"].stringValue
            self.lblYearBuilt.text  = result["year_built"].stringValue
            Property().saveIfExists(result)
        }
    }
}
