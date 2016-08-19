//
//  NotificationDetailViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 4/5/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class NotificationDetailViewController: UIViewController {

    var viewData:JSON = []
    var showingId:String = ""

    @IBOutlet weak var propertyImage: UIImageView!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var propertyDescription: UILabel!
    @IBOutlet weak var showingDate: UILabel!
 
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
    
    @IBAction func btnBack(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }

    func findShowing() {
        let url = AppConfig.APP_URL+"/get_showing_details/"+self.showingId+"/"+User().getField("id")
        Request().get(url, successHandler: {(response) in self.loadShowingData(response)})
    }
    
    func loadShowingData(let response: NSData) {
        let result = JSON(data: response)
        dispatch_async(dispatch_get_main_queue()) {
            self.viewData = result
            if(result["property"]["id"].stringValue.isEmpty) {
                self.propertyNoExistMessage()
            }
            self.address.text  = result["property"]["address"].stringValue
            self.lblPrice.text = Utility().formatCurrency(result["property"]["price"].stringValue)
            var description = ""
            description += "Bed "+result["property"]["bedrooms"].stringValue+"/"
            description += "Bath "+result["property"]["bathrooms"].stringValue
            if(!result["property"]["type"].stringValue.isEmpty) {
                description = description+"/ "+result["property"]["type"].stringValue
            }
            if(!result["property"]["square_feed"].stringValue.isEmpty) {
                description = description+"/ "+result["property"]["square_feed"].stringValue+" SqrFt"
            }
            self.propertyDescription.text = description
            self.showingDate.text = result["showing"]["nice_date"].stringValue
            if(!result["property"]["image"].stringValue.isEmpty) {
                Utility().showPhoto(self.propertyImage, imgPath: result["property"]["image"].stringValue)
            }
        }
    }
    
    func propertyNoExistMessage() {
        dispatch_async(dispatch_get_main_queue()) {
            let alertController = UIAlertController(title:"Message", message: "The details of this property are not available at this time", preferredStyle: .Alert)
            let homeAction = UIAlertAction(title: "Home", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                Utility().goHome(self)
            }
            alertController.addAction(homeAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}
