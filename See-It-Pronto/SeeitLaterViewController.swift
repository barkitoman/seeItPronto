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
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }
    
    func showPropertydetails() {
        let image = Property().getField("image")
        if(!image.isEmpty) {
            Utility().showPhoto(self.photo, imgPath: image)
        }
        self.lblPrice.text   = Property().getField("price")
        self.lblAddress.text  = Property().getField("address")
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
    
    func showRealtorData() {
        let name            = PropertyRealtor().getField("first_name")+" "+PropertyRealtor().getField("last_name")
        self.agentName.text = name
        let image           = PropertyRealtor().getField("url_image")
        if(!image.isEmpty) {
            Utility().showPhoto(self.agentPhoto, imgPath: image)
        }
    }

}
