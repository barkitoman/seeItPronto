//
//  FullPropertyDetailsViewController.swift
//  See-It-Pronto
//
//  Created by user114136 on 1/5/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class FullPropertyDetailsViewController: UIViewController {

    var viewData:JSON = []
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var lblEstPayment: UILabel!
    @IBOutlet weak var lblYourCredits: UILabel!
    @IBOutlet weak var lblBedrooms: UILabel!
    @IBOutlet weak var lblBathrooms: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblSize: UILabel!
    @IBOutlet weak var lblLot: UILabel!
    @IBOutlet weak var lblYearBuilt: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblNeighborhood: UILabel!
    @IBOutlet weak var lblAddedOn: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.findPropertyDetails()
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    }
    
    @IBAction func btnBack(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func findPropertyDetails(){
        let propertyId = Property().getField("id")
        let url = AppConfig.APP_URL+"/real_state_property_basics/get_property_details/"+propertyId
        Request().get(url, successHandler: {(response) in self.showPropertydetails(response)})
    }
    
    func showPropertydetails(let response: NSData) {
        let result = JSON(data: response)
        dispatch_async(dispatch_get_main_queue()) {
            if(!result["images"][0].stringValue.isEmpty) {
                Utility().showPhoto(self.photo, imgPath: result["images"][0].stringValue)
            }
            self.lblEstPayment.text   = result["est_payments"].stringValue
            self.lblYourCredits.text  = result["your_credits"].stringValue
            self.lblBedrooms.text     = result["bedrooms"].stringValue
            self.lblBathrooms.text    = result["bathrooms"].stringValue
            self.lblType.text         = result["property_type"].stringValue
            self.lblSize.text         = result["size"].stringValue
            self.lblLot.text          = result["lot"].stringValue
            self.lblYearBuilt.text    = result["year_built"].stringValue
            self.lblNeighborhood.text = result["neighborhood"].stringValue
            self.lblAddedOn.text      = result["added_on"].stringValue
        }
    }
    
}
