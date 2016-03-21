//
//  FullPropertyDetailsViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/5/16.
//  Copyright © 2016 Deyson. All rights reserved.
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
    
    @IBOutlet weak var btnSeeItNow: UIButton!
    @IBOutlet weak var btnSeeItLater: UIButton!
    @IBOutlet weak var btnSearchAgain: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showPropertydetails()
        self.showHideButtons()
    }
    
    func showHideButtons() {
        let role = User().getField("role")
        if(role == "realtor") {
            btnSearchAgain.hidden = true
            btnSeeItLater.hidden  = true
            btnSeeItNow.hidden    = true
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    }
    
    @IBAction func btnBack(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btnSearchAgain(sender: AnyObject) {
        Utility().goHome(self)
    }
    
    
    @IBAction func btnSeeitPronto(sender: AnyObject) {
        let propertyActionData: JSON =  ["type":"see_it_pronto"]
        PropertyAction().saveIfExists(propertyActionData)
        self.performSegueWithIdentifier("selectAgentForProperty", sender: self)
    }
    
    @IBAction func btnSeeItLater(sender: AnyObject) {
        let propertyActionData: JSON =  ["type":"see_it_later"]
        PropertyAction().saveIfExists(propertyActionData)
        self.performSegueWithIdentifier("selectAgentForProperty", sender: self)
    }
    
    func showPropertydetails() {
        dispatch_async(dispatch_get_main_queue()) {
            let image = Property().getField("image")
            if(!image.isEmpty) {
                Utility().showPhoto(self.photo, imgPath: image)
            }
            self.lblEstPayment.text   = Property().getField("est_payments")
            self.lblYourCredits.text  = Property().getField("your_credits")
            self.lblBedrooms.text     = Property().getField("bedrooms")
            self.lblBathrooms.text    = Property().getField("bathrooms")
            self.lblType.text         = Property().getField("property_type")
            self.lblSize.text         = Property().getField("size")
            self.lblLot.text          = Property().getField("lot")
            self.lblYearBuilt.text    = Property().getField("year_built")
            self.lblNeighborhood.text = Property().getField("neighborhood")
            self.lblAddedOn.text      = Property().getField("added_on")
            self.lblLocation.text     = Property().getField("location")
        }
    }
    
}
