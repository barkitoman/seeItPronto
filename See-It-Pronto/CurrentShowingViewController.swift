//
//  CurrentShowingViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 4/7/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class CurrentShowingViewController: UIViewController {

    @IBOutlet weak var propertyImage: UIImageView!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblBedrooms: UILabel!
    @IBOutlet weak var lblBathrooms: UILabel!
    var showingId:String = ""
    var viewData:JSON = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.findShowing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    @IBAction func btnHome(sender: AnyObject) {
        Utility().goHome(self)
    }
    
    func findShowing() {
        if(!self.showingId.isEmpty) {
            let url = AppConfig.APP_URL+"/get_showing_details/"+self.showingId+"/"+User().getField("id")
            Request().get(url, successHandler: {(response) in self.loadShowingData(response)})
        } else {
            let url = AppConfig.APP_URL+"/current_showing/"+User().getField("id")
            Request().get(url, successHandler: {(response) in self.loadShowingData(response)})
        }
    }
    
    func loadShowingData(let response: NSData) {
        let result = JSON(data: response)
        dispatch_async(dispatch_get_main_queue()) {
            self.viewData = result
            if(self.viewData["showing"]["id"].stringValue.isEmpty) {
                self.showingNotExistMessage()
            }
            if(self.viewData["showing"]["showing_status"].int == 0
                && (self.viewData["showing"]["type"] == "see_it_later" || self.viewData["showing"]["type"] == "see_it_pronto")) {
                self.showingPendingMessage(self.viewData["showing"]["id"].stringValue)
            }
            self.lblBathrooms.text   = result["property"]["bathrooms"].stringValue
            self.lblBedrooms.text    = result["property"]["bedrooms"].stringValue
            self.lblDescription.text = result["property"]["address"].stringValue
            self.lblPrice.text       = Utility().formatCurrency(result["property"]["price"].stringValue)
            
            if(!result["property"]["image"].stringValue.isEmpty) {
                Utility().showPhoto(self.propertyImage, imgPath: result["property"]["image"].stringValue)
            }
        }
    }
    
    func showingPendingMessage(showingId:String) {
        let role = User().getField("role")
        if(role == "realtor") {
            let alertController = UIAlertController(title:"Message", message: "This showing request is pending to be approved", preferredStyle: .Alert)
            let goAction = UIAlertAction(title: "Go", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                
                let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                let vc : ShowingRequestViewController = mainStoryboard.instantiateViewControllerWithIdentifier("ShowingRequestViewController") as! ShowingRequestViewController
                vc.showingId = showingId
                self.navigationController?.showViewController(vc, sender: nil)
            }
            alertController.addAction(goAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func showingNotExistMessage() {
        let alertController = UIAlertController(title:"Message", message: "You don't have a current showing", preferredStyle: .Alert)
        let homeAction = UIAlertAction(title: "Home", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            Utility().goHome(self)
        }
        alertController.addAction(homeAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }

}
