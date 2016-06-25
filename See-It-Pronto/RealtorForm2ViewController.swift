//
//  RealtorForm1ViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/4/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class RealtorForm2ViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
   
    @IBOutlet weak var txtBrokerage: UITextField!
    @IBOutlet weak var txtLisence: UITextField!
    @IBOutlet weak var txtBankAcct: UITextField!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var previewProfilePicture: UIImageView!
    @IBOutlet weak var zipCode1: UITextField!
    @IBOutlet weak var zipCode2: UITextField!
    @IBOutlet weak var zipCode3: UITextField!
    
    @IBOutlet weak var txtRoutingNumber: UITextField!
    //@IBOutlet weak var txtmlsid: UITextField!
    let imagePicker: UIImagePickerController! = UIImagePickerController()
    var haveImage:Bool = false
    var viewData:JSON = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selfDelegate()
        self.findUserInfo()
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
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnTakePhoto(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
                imagePicker.allowsEditing = false
                self.presentViewController(imagePicker, animated: true, completion: nil)
            } else {
                Utility().displayAlert(self, title: "Rear camera doesn't exist", message:  "Application cannot access the camera.", performSegue: "")
            }
        } else {
            Utility().displayAlert(self, title: "Camera inaccessable", message: "Application cannot access the camera.", performSegue: "")
        }
    }
    
    //display image after select
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.haveImage = true
        self.previewProfilePicture.image = image
        self.saveTakenPhoto()
        self.dismissViewControllerAnimated(true, completion: nil);
    }

    //upload photo to server
    func uploadImage() {
        if (self.previewProfilePicture.image != nil && self.haveImage == true) {
            let imageData:NSData = UIImageJPEGRepresentation(self.previewProfilePicture.image!, 1)!
            SRWebClient.POST(AppConfig.APP_URL+"/users/"+self.viewData["id"].stringValue)
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
    
    @IBAction func btnPrevious(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btnSave(sender: AnyObject) {
        self.save()
    }
    
    func save() {
        //create params
        var params = "id="+self.viewData["id"].stringValue+"&user_id="+self.viewData["id"].stringValue
        params = params+"&active_zip_code1=\(self.zipCode1.text!)"
        params = params+"&active_zip_code2=\(self.zipCode2.text!)"
        params = params+"&active_zip_code3=\(self.zipCode3.text!)&routing_number=\(self.txtRoutingNumber.text!)"
        params = params+"&role=realtor&brokerage="+txtBrokerage.text!+"&first_name="+txtFirstName.text!
        params = params+"&last_name="+txtLastName.text!+"&lisence="+txtLisence.text!+"&back_acc="+txtBankAcct.text!
        if(!self.viewData["realtor_id"].stringValue.isEmpty){
            params = params+"&realtor_id="+self.viewData["realtor_id"].stringValue
        }
        let url = AppConfig.APP_URL+"/users/"+self.viewData["id"].stringValue
        Request().put(url, params:params,controller:self,successHandler: {(response) in self.afterPut(response)});
    }
    
    func afterPut(let response: NSData) {
        let result = JSON(data: response)
        if(result["result"].bool == true) {
            self.viewData = result
            self.uploadImage()
            Utility().performSegue(self, performSegue: "RealtorForm2")
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
    
    func loadDataToEdit(let response: NSData) {
        dispatch_async(dispatch_get_main_queue()) {
            let result = JSON(data: response)
            self.txtFirstName.text     = result["first_name"].stringValue
            self.txtLastName.text      = result["last_name"].stringValue
            self.txtBrokerage.text     = result["brokerage"].stringValue
            self.txtRoutingNumber.text = result["routing_number"].stringValue
            self.txtBankAcct.text      = result["bank_acct"].stringValue
            self.txtLisence.text       = result["license"].stringValue
            self.zipCode1.text         = result["active_zip_code1"].stringValue
            self.zipCode2.text         = result["active_zip_code2"].stringValue
            self.zipCode3.text         = result["active_zip_code3"].stringValue
            //self.txtmlsid.text     = result["mls_id"].stringValue
            if(!result["url_image"].stringValue.isEmpty) {
                Utility().showPhoto(self.previewProfilePicture, imgPath: result["url_image"].stringValue)
            }
        }
    }
    
    func saveTakenPhoto() {
        let imageData = UIImageJPEGRepresentation(previewProfilePicture.image!, 0.6)
        let compressedJPGImage = UIImage(data: imageData!)
        UIImageWriteToSavedPhotosAlbum(compressedJPGImage!, nil, nil, nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "RealtorForm2") {
            let view: RealtorForm3ViewController = segue.destinationViewController as! RealtorForm3ViewController
            view.viewData  = self.viewData
        }
    }
    
}
