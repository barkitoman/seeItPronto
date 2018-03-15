//
//  BuyerForm3ViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/4/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class BuyerForm3ViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var txtCardNumber: UITextField!
    @IBOutlet weak var txtExpDate: UITextField!
    @IBOutlet weak var txtCVC: UITextField!
    @IBOutlet weak var txtPromoCode: UITextField!
    var viewData:JSON  = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selfDelegate()
        findUserInfo()
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
    
    @IBAction func btnPrevious(_ sender: AnyObject) {
         navigationController?.popViewController(animated: true)     
    }
    
    func selfDelegate() {
        self.txtCardNumber.delegate = self
        self.txtExpDate.delegate = self
        self.txtCVC.delegate = self
        self.txtPromoCode.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func btnSave(_ sender: AnyObject) {
        save()
    }
    
    func save() {
        if(self.validateFields() == true) {
            //create params
            var params = "id="+self.viewData["id"].stringValue+"&user_id="+self.viewData["id"].stringValue+"&number_card="+txtCardNumber.text!+"&expiration_date="+txtExpDate.text!+"&csv="+txtCVC.text!+"&promo_code="+txtPromoCode.text!
            if(!self.viewData["card_id"].stringValue.isEmpty) {
                params = params+"&card_id="+self.viewData["card_id"].stringValue
            }
            let url = AppConfig.APP_URL+"/users/"+self.viewData["id"].stringValue
            Request().put(url, params:params,controller:self,successHandler: {(response) in self.afterPut(response)});
        }
    }
    
    func afterPut(_ response: Data) {
        let result = JSON(data: response)
        if(result["result"].bool == true) {
            self.viewData = result
            Utility().performSegue(self, performSegue: "FromBuyerForm3")
        } else {
            var msg = "Error saving, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }
    
    func validateFields()->Bool {
        if(self.txtExpDate.text! != "") {
            let regex = "[0-9]{2}/[0-9]{4}"
            let matches = self.txtExpDate.text!.range(of: regex, options: .regularExpression)
            if let _ = matches {} else {
                Utility().displayAlert(self, title: "Error", message: "Please enter a valid Exp. Date. \n Example: 05/2020", performSegue: "")
                return false
            }
        }
        return true
    }
    
    func findUserInfo() {
        let userId = User().getField("id")
        if(!userId.isEmpty) {
            self.viewData["id"] = JSON(userId)
            let url = AppConfig.APP_URL+"/user_info/"+userId
            Request().get(url, successHandler: {(response) in self.loadDataToEdit(response)})
        }
    }
    
    func loadDataToEdit(_ response: Data) {
        let result = JSON(data: response)
        DispatchQueue.main.async {
            self.txtCardNumber.text = result["number_card"].stringValue
            self.txtExpDate.text    = result["expiration_date"].stringValue
            self.txtCVC.text        = result["csv"].stringValue
            self.txtPromoCode.text  = result["promo_code"].stringValue
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "FromBuyerForm3") {
            User().updateField("is_login", value: "1")
            let view: BuyerHomeViewController = segue.destination as! BuyerHomeViewController
            view.viewData  = self.viewData
        }
    }

}
