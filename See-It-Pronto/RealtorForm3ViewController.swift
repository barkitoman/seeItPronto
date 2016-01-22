//
//  RealtorForm1ViewController.swift
//  See-It-Pronto
//
//  Created by user114136 on 1/4/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class RealtorForm3ViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate {


    @IBOutlet weak var slShowingRate: UISlider!
    @IBOutlet weak var slTravelRate: UISlider!
    
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
        let params = "id="+self.viewData["id"].stringValue+"&realtor_id"+self.viewData["realtor_id"].stringValue+"&showing_rate="+slShowingRate.value.description+"&travel_range="+slTravelRate.value.description
        let url = Config.APP_URL+"/users/"+self.viewData["id"].stringValue
        Request().post(url, params:params,successHandler: {(response) in self.afterPost(response)});
    }
    
    func afterPost(let response: NSData) {
        let result = JSON(data: response)
        if(result["result"].bool == true) {
            self.viewData = result
            Utility().displayAlert(self,title:"Success", message:"The data have been saved correctly", performSegue:"RealtorForm1")
        } else {
            var msg = "Error saving, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title:"Error", message:msg, performSegue:"")
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "RealtorForm1") {
            let view: RealtorForm2ViewController = segue.destinationViewController as! RealtorForm2ViewController
            view.viewData  = self.viewData
        }
    }

}
