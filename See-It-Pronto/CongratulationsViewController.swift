//
//  CongratulationsViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/6/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class CongratulationsViewController: UIViewController {

    var viewData:JSON = []
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    
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
    
    @IBAction func btnCallAgent(sender: AnyObject) {
        //let  phoneNumber = txtPhoneNumber.text
        //callNumber(phoneNumber!)
    }
    
    private func callNumber(phoneNumber:String) {
        if let phoneCallURL:NSURL = NSURL(string: "tel://\(phoneNumber)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL);
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    }

    @IBAction func btnHome(sender: AnyObject) {
        Utility().goHome(self)
    }
    
    @IBAction func btnSearchAgain(sender: AnyObject) {
        Utility().goHome(self)
    }
    
    func showPropertydetails() {
        let image = Property().getField("image")
        if(!image.isEmpty) {
            Utility().showPhoto(self.photo, imgPath: image)
        }
        self.lblPrice.text   = Property().getField("price")
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
