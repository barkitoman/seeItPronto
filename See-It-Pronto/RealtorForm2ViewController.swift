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
    //@IBOutlet weak var txtmlsid: UITextField!
    let imagePicker: UIImagePickerController! = UIImagePickerController()
    var haveImage:Bool = false
    var viewData:JSON = []
    var isTakenImage = false
    
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
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(myPickerController, animated: true, completion: nil)
    }
    
    @IBAction func btnTakePhoto(sender: AnyObject) {
        self.isTakenImage = true
        if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
            if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .Camera
                imagePicker.cameraCaptureMode = .Photo
                presentViewController(imagePicker, animated: true, completion: {})
            } else {
                Utility().displayAlert(self, title: "Rear camera doesn't exist", message:  "Application cannot access the camera.", performSegue: "")
                self.isTakenImage = false
            }
        } else {
            Utility().displayAlert(self, title: "Camera inaccessable", message: "Application cannot access the camera.", performSegue: "")
            self.isTakenImage = false
        }
    }
    
    //display image after select
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if(self.isTakenImage == true) {
            if let pickedImage:UIImage = (info[UIImagePickerControllerOriginalImage]) as? UIImage {
                let selectorToCall = Selector("imageWasSavedSuccessfully:didFinishSavingWithError:context:")
                UIImageWriteToSavedPhotosAlbum(pickedImage, self, selectorToCall, nil)
            }
        } else {
            self.previewProfilePicture.image = info[UIImagePickerControllerOriginalImage] as? UIImage
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        self.haveImage = true
        imagePicker.dismissViewControllerAnimated(true, completion: {
            // Anything you want to happen when the user saves an image
            self.isTakenImage = false
        })
    }
    
    func documentPicker(controller: UIDocumentPickerViewController, didPickDocumentAtURL url: NSURL) {
        if controller.documentPickerMode == UIDocumentPickerMode.Import {
            // This is what it should be
            print(url.path)
            //self.newNoteBody.text = String(contentsOfFile: url.path!)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("User canceled image")
        dismissViewControllerAnimated(true, completion: {
            // Anything you want to happen when the user selects cancel
        })
    }
    
    func imageWasSavedSuccessfully(image: UIImage, didFinishSavingWithError error: NSError!, context: UnsafeMutablePointer<()>){
        if let theError = error {
            print("An error happened while saving the image = \(theError)")
        } else {
            print("Displaying")
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.previewProfilePicture.image = image
            })
        }
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
        params = params+"&active_zip_code3=\(self.zipCode3.text!)"
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
            self.txtFirstName.text = result["first_name"].stringValue
            self.txtLastName.text  = result["last_name"].stringValue
            self.txtBrokerage.text = result["brokerage"].stringValue
            self.txtBankAcct.text  = result["bank_acct"].stringValue
            self.txtLisence.text   = result["license"].stringValue
            self.zipCode1.text     = result["active_zip_code1"].stringValue
            self.zipCode2.text     = result["active_zip_code2"].stringValue
            self.zipCode3.text     = result["active_zip_code3"].stringValue
            //self.txtmlsid.text     = result["mls_id"].stringValue
            if(!result["url_image"].stringValue.isEmpty) {
                Utility().showPhoto(self.previewProfilePicture, imgPath: result["url_image"].stringValue)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "RealtorForm2") {
            let view: RealtorForm3ViewController = segue.destinationViewController as! RealtorForm3ViewController
            view.viewData  = self.viewData
        }
    }
    
}
