//
//  ViewPropertyViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/4/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class ShowingRequestViewController: UIViewController {

    var viewData:JSON = []
    @IBOutlet weak var buyerPhoto: UIImageView!
    @IBOutlet weak var buyerName: UILabel!
    @IBOutlet weak var propertyPhoto: UIImageView!
    @IBOutlet weak var propertyDescription: UILabel!
    @IBOutlet weak var showingInstructions: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showPropertyDetails()
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
    
    func showPropertyDetails() {
        let showing:  JSON =  ["showing":["id":1, "date":"Aug 15th 2:30 pm","type":"see it later"]]
        let buyer:    JSON =  ["buyer": ["id":1,"first_name":"John","last_name":"Smith","url_image":"img/Users/user1.jpg"]]
        let property: JSON =  ["property":["id":1,"price":"48.000", "bedrooms":5,"bathrooms":5, "property":"img/properties/real1.jpg","address":"1234 Main StreetAnytown, FL,33123"]]
        
        let name = buyer["buyer"]["first_name"].stringValue+" "+buyer["buyer"]["last_name"].stringValue
        self.buyerName.text   = "User "+name+" want to see it on "+showing["showing"]["date"].stringValue
        var description       = property["property"]["address"].stringValue+" $"+property["property"]["price"].stringValue
        description           = description+" "+property["property"]["bedrooms"].stringValue+"Br / "+property["property"]["bathrooms"].stringValue+"Ba"
        self.propertyDescription.text = description
        if(!buyer["buyer"]["url_image"].stringValue.isEmpty) {
            Utility().showPhoto(self.buyerPhoto, imgPath: buyer["buyer"]["url_image"].stringValue)
        }
        if(!property["property"]["property"].stringValue.isEmpty) {
            Utility().showPhoto(self.propertyPhoto, imgPath: property["property"]["property"].stringValue)
        }
    }

}
