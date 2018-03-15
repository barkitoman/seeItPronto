//
//  RealtorForm1ViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/4/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class RealtorForm1ViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtBiography: UITextView!
    @IBOutlet weak var txtCharacters: UILabel!
    
 
    var viewData:JSON = []
    var animateDistance: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selfDelegate()
        self.findUserInfo()
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
        self.txtEmail.delegate = self
        self.txtPhone.delegate = self
        self.txtPassword.delegate = self
        self.txtBiography.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func btnSave(_ sender: AnyObject) {
        save()
    }
    
    func save() {
        //create params
        let userId = User().getField("id")
        var params = "role=realtor&client_id=\(self.txtEmail.text!)&phone=\(self.txtPhone.text!)&client_secret=\(self.txtPassword.text!)"
        params     = params+"&biography=\(self.txtBiography.text)&grant_type=\(AppConfig.GRANT_TYPE)"
        params     = params+"&device_token_id=\(Utility().deviceTokenId())"
        var url    = AppConfig.APP_URL+"/users"
        if(!userId.isEmpty) {
            params = params+"&id=\(userId)"
            url = AppConfig.APP_URL+"/users/"+userId
            Request().put(url, params:params,controller:self,successHandler: {(response) in self.afterPost(response)});
        } else {
            Request().post(url, params:params,controller: self,successHandler: {(response) in self.afterPost(response)});
        }
    }
    
    func afterPost(_ response: Data) {
        let result = JSON(data: response)
        if(result["user"]["result"].bool == true || result["result"].bool == true ) {
            let userId = User().getField("id")
            //if user is editing
            if(!userId.isEmpty) {
                self.viewData = result
            } else {
                //if user is registering
                self.viewData = result["user"]
                User().saveOne(result)
            }
            Utility().performSegue(self, performSegue: "RealtorForm1")
        } else {
            var msg = "Error saving, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title:"Error", message:msg, performSegue:"")
        }
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
            self.viewData = result
            self.txtEmail.text = result["email"].stringValue
            self.txtPhone.text = result["phone"].stringValue
            self.txtBiography.text = result["biography"].stringValue
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "RealtorForm1") {
            let view: RealtorForm2ViewController = segue.destination as! RealtorForm2ViewController
            view.viewData  = self.viewData
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        self.txtCharacters.text = String(250 - textView.text.characters.count)
        return textView.text.characters.count + (text.characters.count - range.length) <= 250
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        let textFieldRect : CGRect = self.view.window!.convert(textView.bounds, from: textView)
        let viewRect : CGRect = self.view.window!.convert(self.view.bounds, from: self.view)
        let midline : CGFloat = textFieldRect.origin.y + 0.5 * textFieldRect.size.height
        let numerator : CGFloat = midline - viewRect.origin.y - MoveKeyboard.MINIMUM_SCROLL_FRACTION * viewRect.size.height
        let denominator : CGFloat = (MoveKeyboard.MAXIMUM_SCROLL_FRACTION - MoveKeyboard.MINIMUM_SCROLL_FRACTION) * viewRect.size.height
        var heightFraction : CGFloat = numerator / denominator
        if heightFraction < 0.0 {
            heightFraction = 0.0
        } else if heightFraction > 1.0 {
            heightFraction = 1.0
        }
        let orientation : UIInterfaceOrientation = UIApplication.shared.statusBarOrientation
        if (orientation == UIInterfaceOrientation.portrait || orientation == UIInterfaceOrientation.portraitUpsideDown) {
            animateDistance = floor(MoveKeyboard.PORTRAIT_KEYBOARD_HEIGHT * heightFraction)
        } else {
            animateDistance = floor(MoveKeyboard.LANDSCAPE_KEYBOARD_HEIGHT * heightFraction)
        }
        var viewFrame : CGRect = self.view.frame
        viewFrame.origin.y -= animateDistance
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(TimeInterval(MoveKeyboard.KEYBOARD_ANIMATION_DURATION))
        self.view.frame = viewFrame
        UIView.commitAnimations()
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        var viewFrame : CGRect = self.view.frame
        viewFrame.origin.y += animateDistance
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(TimeInterval(MoveKeyboard.KEYBOARD_ANIMATION_DURATION))
        self.view.frame = viewFrame
        UIView.commitAnimations()
    }
    
}
