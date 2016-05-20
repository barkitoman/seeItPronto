//
//  BuyerProfileViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 4/14/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class BuyerProfileViewController: UIViewController {

    var viewData:JSON = []
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var lblPrequelified: UILabel!
    @IBOutlet weak var lblLastName: UILabel!
    @IBOutlet weak var lblFirstName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.findUserInfo()
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
    
    func findUserInfo() {
        let userId = self.viewData["id"].stringValue
        if(!userId.isEmpty) {
            let url = AppConfig.APP_URL+"/user_info/"+userId
            Request().get(url, successHandler: {(response) in self.loadDataToEdit(response)})
        }
    }  
    
    func loadDataToEdit(let response: NSData) {
        dispatch_async(dispatch_get_main_queue()) {
            let result = JSON(data: response)
            self.lblFirstName.text = result["first_name"].stringValue
            self.lblLastName.text  = result["last_name"].stringValue
            if(result["pre_qualified"].int == 1) {
                self.lblPrequelified.text = "Yes"
            } else {
                self.lblPrequelified.text = "No"
            }
            if(!result["url_image"].stringValue.isEmpty) {
                print(result["url_image"].stringValue)
                Utility().showPhoto(self.photo, imgPath: result["url_image"].stringValue)
            }
        }
    }

}
