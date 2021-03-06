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
    @IBOutlet weak var lblBuyerName: UILabel!
    @IBOutlet weak var propertyPhoto: UIImageView!
    @IBOutlet weak var lblPropertyDescription: UILabel!
    @IBOutlet weak var showingInstructions: UILabel!
    var showingId:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            BProgressHUD.showLoadingViewWithMessage("Loading...")
        }
        self.findShowing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if (navigationController?.topViewController != self) {
            navigationController?.isNavigationBarHidden = false
        }
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnBack(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnYes(_ sender: AnyObject) {
        let url          = AppConfig.APP_URL+"/showings/\(self.viewData["showing"]["id"].stringValue)"
        var params       = "id="+self.viewData["showing"]["id"].stringValue+"&showing_status=1&current_showing="+self.isCurrentShowing()
        params           = params+"&user_id=\(User().getField("id"))&showing_type=\(self.viewData["showing"]["type"].stringValue)"
        params           = params+"&execute_payment=1&coupon_code=\(self.viewData["showing"]["coupon_code"].stringValue)"
        let fullUsername = User().getField("first_name")+" "+User().getField("last_name")
        let type         = "showing_acepted"
        let title        = "Showing Request Accepted"
        let description  = "Agent \(fullUsername) accepted your showing request"
        params           = self.notificationParams(params,type: type,title: title,descripcion: description)
        Request().put(url, params:params,controller:self,successHandler: {(response) in self.afterYesRequest(response)});
    }
    
    func afterYesRequest(_ response: Data) {
        let result = JSON(data: response)
        if(result["result"].bool == true ) {
            DispatchQueue.main.async {
                let alertController = UIAlertController(title:"Success", message: "The request has been accepted, Please proceed to the property", preferredStyle: .alert)
                let currentShowingAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    if(self.viewData["showing"]["type"].stringValue == "see_it_pronto") {
                        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                        let vc : CurrentShowingViewController = mainStoryboard.instantiateViewController(withIdentifier: "CurrentShowingViewController") as! CurrentShowingViewController
                        vc.showingId = self.showingId
                        self.navigationController?.show(vc, sender: nil)
                    } else {
                        Utility().goHome(self)
                    }
                }
                alertController.addAction(currentShowingAction)
                self.present(alertController, animated: true, completion: nil)
            }
        } else {
            var msg = "Error saving, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            if(result["execute_payment"].stringValue == "1") {
                Utility().displayAlertBack(self, title: "Error", message: msg)
            } else {
                Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
            }
        }
    }
    
    func isCurrentShowing()->String {
        var out = "0"
        if(self.viewData["showing"]["type"].stringValue == "see_it_pronto") {
            out = "1"
        }
        return out
    }
    
    func notificationParams(_ params:String, type:String, title:String, descripcion:String)->String {
        var params = params
        params = params+"&notification=1&from_user_id="+User().getField("id")+"&to_user_id="+self.viewData["showing"]["buyer_id"].stringValue
        params = params+"&title=\(title)&property_id="+self.viewData["showing"]["property_id"].stringValue
        params = params+"&description="+descripcion
        params = params+"&parent_id="+self.viewData["showing"]["id"].stringValue+"&parent_type=showings&notification_type="+type
        return params
    }
    
    @IBAction func btnNo(_ sender: AnyObject) {
        let url          = AppConfig.APP_URL+"/showings/"+self.viewData["showing"]["id"].stringValue
        var params       = "id="+self.viewData["showing"]["id"].stringValue+"&showing_status=2&refund=1"
        let fullUsername = User().getField("first_name")+" "+User().getField("last_name")
        let type         = "showing_rejected"
        let title        = "Showing Request Rejected"
        let description  = "Agent \(fullUsername) is not available to show you the property at this time"
        params           = self.notificationParams(params,type: type,title: title,descripcion: description)
        Request().put(url, params:params,controller:self,successHandler: {(response) in self.afterNoRequest(response)});
    }
    
    func afterNoRequest(_ response: Data) {
        let result = JSON(data: response)
        if(result["result"].bool == true ) {
            DispatchQueue.main.async {
                let alertController = UIAlertController(title:"Success", message: "The request has been rejected", preferredStyle: .alert)
                let homeAction = UIAlertAction(title: "Home", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    Utility().goHome(self)
                }
                let backAction = UIAlertAction(title: "Back", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    self.navigationController?.popViewController(animated: true)
                }
                alertController.addAction(homeAction)
                alertController.addAction(backAction)
                self.present(alertController, animated: true, completion: nil)
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
        let url = AppConfig.APP_URL+"/get_showing_details/"+self.showingId+"/\(User().getField("id"))"
        Request().get(url, successHandler: {(response) in self.loadShowingData(response)})
    }
    
    func loadShowingData(_ response: Data) {
        let result = JSON(data: response)
        DispatchQueue.main.async {
            self.viewData = result
            let name = result["buyer"]["first_name"].stringValue+" "+result["buyer"]["last_name"].stringValue
            self.lblBuyerName.text = "\(name) wants to see it on \(result["showing"]["showing_date"].stringValue)"
            var description = result["property"]["address"].stringValue+"\n \(Utility().formatCurrency(result["property"]["price"].stringValue))"
            description = description+"\n \(result["property"]["bedrooms"].stringValue) Bd / \(result["property"]["bathrooms"].stringValue) Ba "
            if(!result["property"]["square_feed"].stringValue.isEmpty) {
                description = description+" / \(result["property"]["square_feed"].stringValue) Sq Ft"
            }
            self.lblPropertyDescription.text = description
            Utility().showPhoto(self.buyerPhoto, imgPath: result["buyer"]["url_image"].stringValue, defaultImg: "default_user_photo")
            if(!result["property"]["image"].stringValue.isEmpty) {
                Utility().showPhoto(self.propertyPhoto, imgPath: result["property"]["image"].stringValue)
            }
            BProgressHUD.dismissHUD(3)
            self.statusMessage()
        }
    }
    
    func statusMessage() {
        var message = ""
        if(self.viewData == nil) {
            message = "Sorry, this showing request is not available at this time"
            
        }else if(self.viewData["showing"]["showing_status"].int == 4) {
            message = "This showing request has been canceled"
            
        }else if(self.viewData["showing"]["showing_status"].int == 3) {
            message = "This showing request has been completed"
            
        }else if(self.viewData["showing"]["showing_status"].int == 2) {
            message = "This showing request has been rejected"
            
        }else if(self.viewData["showing"]["showing_status"].int == 1) {
            message = "This showing request has been accepted"
            
        }else if(self.viewData["showing"]["expired"].stringValue == "true") {
            message = "This showing request has expired on \(self.viewData["showing"]["nice_date"].stringValue)"
        }
        
        if(!message.isEmpty) {
            DispatchQueue.main.async {
                let alertController = UIAlertController(title:"Message", message: message, preferredStyle: .alert)
                let homeAction = UIAlertAction(title: "Back", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    self.navigationController?.popViewController(animated: true)
                }
                alertController.addAction(homeAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func btnViewShowingInstructions(_ sender: AnyObject) {
        if(!self.viewData["realtor_properties"]["showing_instruction"].stringValue.isEmpty) {
            var instructions = self.viewData["realtor_properties"]["type"].stringValue+"\n"
            instructions = instructions+self.viewData["realtor_properties"]["showing_instruction"].stringValue
            Utility().displayAlert(self, title: "Showing instructions", message: instructions, performSegue: "")
        } else {
            Utility().displayAlert(self, title: "Message", message: "You don't have showing instructions for this property", performSegue: "")
        }
    }
    
    @IBAction func btnCallCustomer(_ sender: AnyObject) {
        self.chatAgent()
    }
    
    func chatAgent() {
         DispatchQueue.main.async {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let vc : ChatViewController = mainStoryboard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
            vc.to = self.viewData["showing"]["buyer_id"].stringValue
            self.navigationController?.show(vc, sender: nil)
        }
    }
    
}
