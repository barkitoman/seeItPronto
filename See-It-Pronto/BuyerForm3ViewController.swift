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
        let params = "id="+self.viewData["id"].stringValue+"&user_id"+self.viewData["id"].stringValue+"&number_card"+txtCardNumber.text!+"&expiration_date="+txtExpDate.text!+"&csv="+txtCVC.text!+"&promo_code="+txtPromoCode.text!
        let url = Config.APP_URL+"/users/"+self.viewData["id"].stringValue
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "FromBuyerForm3") {
            let view: BuyerForm4ViewController = segue.destinationViewController as! BuyerForm4ViewController
            view.viewData  = self.viewData
        }
    }

}
