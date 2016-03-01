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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    }

    @IBAction func btnBack(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btnSeeItLater(sender: AnyObject) {
        
    }
    
    @IBAction func btnSeeItNow(sender: AnyObject) {
        
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
        let distance      = PropertyRealtor().getField("distance")
        
        
        self.lblShowingRate.text = (!showingRate.isEmpty) ? "$"+showingRate : ""
        self.lblDistance.text    = (!distance.isEmpty) ? distance+"mi" : ""
        self.lblRaringLabel.text = (!rating.isEmpty) ? rating+" of 5" : ""
        if(!image.isEmpty) {
            Utility().showPhoto(self.agentPhoto, imgPath: image)
        }
        if(!rating.isEmpty) {
            ratingImage.image = UIImage(named: rating+"stars")
        }
    }
    
}
