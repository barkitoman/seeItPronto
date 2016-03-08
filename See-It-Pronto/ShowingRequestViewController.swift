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
    var showingId:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.findShowing()
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
    
    @IBAction func btnYes(sender: AnyObject) {
        let url          = AppConfig.APP_URL+"/showings/"+self.viewData["showing"]["id"].stringValue
        var params       = "id="+self.viewData["showing"]["id"].stringValue+"&showing_status=1"
        let fullUsername = User().getField("first_name")+" "+User().getField("last_name")
        let type         = "showing_acepted"
        let title        = "Showing Request Accepted"
        let description  = "User \(fullUsername) Accepted your showing request"
        params           = self.notificationParams(params,type: type,title: title,descripcion: description)
        Request().put(url, params:params,successHandler: {(response) in self.afterRequest(response, titleOption: "accepted")});
    }
    
    func notificationParams(var params:String, type:String, title:String, descripcion:String)->String {
        params = params+"&notification=1&from_user_id="+User().getField("id")+"&to_user_id="+self.viewData["showing"]["realtor_id"].stringValue
        params = params+"&title="+title
        params = params+"&description="+descripcion
        params = params+"&parend_id="+self.viewData["showing"]["id"].stringValue+"&parent_type=showings&type="+type
        return params
    }
    
    @IBAction func btnNo(sender: AnyObject) {
        let url          = AppConfig.APP_URL+"/showings/"+self.viewData["showing"]["id"].stringValue
        var params       = "id="+self.viewData["showing"]["id"].stringValue+"&showing_status=2"
        let fullUsername = User().getField("first_name")+" "+User().getField("last_name")
        let type         = "showing_rejected"
        let title        = "Showing Request Accepted"
        let description  = "User \(fullUsername) is not available to show the property at this time"
        params           = self.notificationParams(params,type: type,title: title,descripcion: description)
        Request().put(url, params:params,successHandler: {(response) in self.afterRequest(response, titleOption: "rejected")});
    }
    
    func afterRequest(let response: NSData, titleOption:String) {
        let result = JSON(data: response)
        print(result)
        if(result["result"].bool == true ) {
            dispatch_async(dispatch_get_main_queue()) {
                let alertController = UIAlertController(title:"Success", message: "The request has been "+titleOption, preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) {
                    UIAlertAction in
                    Utility().goHome(self)
                }
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        } else {
            var msg = "Error saving, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }
    
    func findShowing() {
        let url = AppConfig.APP_URL+"/get_showing_details/"+self.showingId
        Request().get(url, successHandler: {(response) in self.loadShowingData(response)})
    }
    
    func loadShowingData(let response: NSData) {
        let result    = JSON(data: response)
        self.viewData = result
        let name            = result["buyer"]["first_name"].stringValue+" "+result["buyer"]["last_name"].stringValue
        self.buyerName.text = "User \(name) want to see it on "+result["showing"]["date"].stringValue
        var description     = result["property"]["address"].stringValue+" $"+result["property"]["price"].stringValue
        description         = description+" "+result["property"]["bedrooms"].stringValue+"Br / "+result["property"]["bathrooms"].stringValue+"Ba"
        self.propertyDescription.text = description
        if(!result["buyer"]["url_image"].stringValue.isEmpty) {
            Utility().showPhoto(self.buyerPhoto, imgPath: result["buyer"]["url_image"].stringValue)
        }
        if(!result["property"]["image"].stringValue.isEmpty) {
            Utility().showPhoto(self.propertyPhoto, imgPath: result["property"]["image"].stringValue)
        }
    }

}
