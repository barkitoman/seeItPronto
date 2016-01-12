//
//  RealtorForm2ViewController.swift
//  See-It-Pronto
//
//  Created by user114136 on 1/4/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class RealtorForm2ViewController: UIViewController {

    @IBOutlet weak var slShowingRate: UISlider!
    @IBOutlet weak var slTravelRange: UISlider!
    var viewData:JSON = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    func save() {
        //create params
        let params = "id="+self.viewData["user_id"].stringValue+"&showin_rate="+slShowingRate.value.description+"&travel_rate="+slTravelRange.value.description
        let url = Config.APP_URL+"/users/add"
        Request().post(url, params:params,successHandler: {(response) in self.afterPost(response)});
    }
    
    func afterPost(let response: NSData) {
        let result = JSON(data: response)
        if(result["result"].bool == true) {
            Utility().displayAlert(self,title:"Success", message:"The data have been saved correctly", performSegue:"FromBuyerForm1")
        } else {
            var msg = "Error saving, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title:"Success", message:msg, performSegue:"")
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }

}
