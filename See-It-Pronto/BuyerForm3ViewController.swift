//
//  BuyerForm3ViewController.swift
//  See-It-Pronto
//
//  Created by user114136 on 1/4/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class BuyerForm3ViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var txtCardNumber: UITextField!
    @IBOutlet weak var txtExpDate: UITextField!
    @IBOutlet weak var txtCVC: UITextField!
    @IBOutlet weak var txtPromoCode: UITextField!
    var viewData:JSON = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selfDelegate()
        findUserInfo()
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
    
    func selfDelegate() {
        self.txtCardNumber.delegate = self
        self.txtExpDate.delegate = self
        self.txtCVC.delegate = self
        self.txtPromoCode.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func btnSave(sender: AnyObject) {
        save()
    }
    
    func save() {
        //create params
        var params = "id="+self.viewData["id"].stringValue+"&user_id="+self.viewData["id"].stringValue+"&number_card="+txtCardNumber.text!+"&expiration_date="+txtExpDate.text!+"&csv="+txtCVC.text!+"&promo_code="+txtPromoCode.text!
        if(!self.viewData["card_id"].stringValue.isEmpty) {
            params = params+"&card_id="+self.viewData["card_id"].stringValue
        }
        let url = Config.APP_URL+"/users/"+self.viewData["id"].stringValue
        print(url)
        Request().put(url, params:params,successHandler: {(response) in self.afterPut(response)});
    }
    
    func afterPut(let response: NSData) {
        let result = JSON(data: response)
        if(result["result"].bool == true) {
            self.viewData = result
            Utility().displayAlert(self,title: "Success", message:"The data have been saved correctly", performSegue:"FromBuyerForm3")
        } else {
            var msg = "Error saving, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }
    
    func findUserInfo() {
        let userId = User().getField("id")
        if(!userId.isEmpty) {
            self.viewData["id"] = JSON(userId)
            let url = Config.APP_URL+"/user_info/"+userId
            Request().get(url, successHandler: {(response) in self.loadDataToEdit(response)})
        }
    }
    
    func loadDataToEdit(let response: NSData) {
        let result = JSON(data: response)
        dispatch_async(dispatch_get_main_queue()) {
            self.txtCardNumber.text = result["number_card"].stringValue
            self.txtExpDate.text    = result["expiration_date"].stringValue
            self.txtCVC.text        = result["csv"].stringValue
            self.txtPromoCode.text  = result["promo_code"].stringValue
            //Utility().showPhoto(self.previewProfilePicture, imgPath: result["url_image"].stringValue)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "FromBuyerForm3") {
            let view: BuyerForm4ViewController = segue.destinationViewController as! BuyerForm4ViewController
            view.viewData  = self.viewData
        }
    }

}
