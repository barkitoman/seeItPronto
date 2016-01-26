//
//  RealtorForm1ViewController.swift
//  See-It-Pronto
//
//  Created by user114136 on 1/4/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class RealtorForm2ViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate   {
   
    @IBOutlet weak var txtBrokerage: UITextField!
    @IBOutlet weak var txtLisence: UITextField!
    @IBOutlet weak var txtBankAcct: UITextField!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var previewProfilePicture: UIImageView!
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
    
    func selfDelegate() {
        self.txtBrokerage.delegate = self
        self.txtFirstName.delegate = self
        self.txtLisence.delegate = self
        self.txtLastName.delegate = self
        self.txtBankAcct.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func btnchoosePicture(sender: AnyObject) {
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(myPickerController, animated: true, completion: nil)
    }
    
    //display image after select
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.previewProfilePicture.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //upload photo to server
    func uploadImage() {
        if self.previewProfilePicture.image != nil {
            let imageData:NSData = UIImageJPEGRepresentation(self.previewProfilePicture.image!, 1)!
            SRWebClient.POST(Config.APP_URL+"/users/"+self.viewData["id"].stringValue)
                .data(imageData, fieldName:"image", data:["id":self.viewData["id"].stringValue,"_method":"PUT"])
                .send({(response:AnyObject!, status:Int) -> Void in
                    },failure:{(error:NSError!) -> Void in
                        print("ERROR UPLOADING PHOTO")
                })
        }
    }
    
    @IBAction func btnBack(sender: AnyObject) {
       navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btnSave(sender: AnyObject) {
        self.save()
    }
    
    func save() {
        //create params
        let params = "id="+self.viewData["id"].stringValue+"&user_id="+self.viewData["id"].stringValue+"&role=realtor&brokerage="+txtBrokerage.text!+"&first_name="+txtFirstName.text!+"&last_name="+txtLastName.text!+"&lisence="+txtLisence.text!+"&back_acc="+txtBankAcct.text!
        let url = Config.APP_URL+"/users/"+self.viewData["id"].stringValue
        Request().put(url, params:params,successHandler: {(response) in self.afterPut(response)});
    }
    
    func afterPut(let response: NSData) {
        let result = JSON(data: response)
        if(result["result"].bool == true) {
            self.uploadImage()
            self.viewData = result
            Utility().displayAlert(self,title:"Success", message:"The data have been saved correctly", performSegue:"RealtorForm2")
        } else {
            var msg = "Error saving, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title:"Error", message:msg, performSegue:"")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "RealtorForm2") {
            let view: RealtorForm3ViewController = segue.destinationViewController as! RealtorForm3ViewController
            view.viewData  = self.viewData
        }
    }
    
}
