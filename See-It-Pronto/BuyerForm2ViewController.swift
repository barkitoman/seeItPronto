//
//  BuyerForm2ViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/4/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class BuyerForm2ViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate   {

    
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var btnSelectPicture: UIButton!
    @IBOutlet weak var previewProfilePicture: UIImageView!
    let imagePicker: UIImagePickerController! = UIImagePickerController()
    var haveImage:Bool = false
    var isTakenPhoto:Bool = false
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
    
    @IBAction func btnBack(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btnPrevious(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)   
    }
    
    func selfDelegate() {
        self.txtFirstName.delegate = self
        self.txtLastName.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func btnChoosePicture(sender: AnyObject) {
        self.isTakenPhoto = false
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnTakePicture(sender: AnyObject) {
        self.isTakenPhoto = true
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
        if(self.isTakenPhoto == true) {
            self.saveTakenPhoto()
        }
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
    
    @IBAction func btnSave(sender: AnyObject) {
        self.save()
    }
    
    func save() {
        //create params
        let params = "id="+self.viewData["id"].stringValue+"&first_name="+txtFirstName.text!+"&last_name="+txtLastName.text!
        let url = AppConfig.APP_URL+"/users/"+self.viewData["id"].stringValue
        Request().put(url, params:params,controller:self,successHandler: {(response) in self.afterPut(response)});
    }

    func afterPut(let response: NSData) {
        let result = JSON(data: response)
        if(result["result"].bool == true) {
            self.viewData = result
            self.uploadImage()
            Utility().performSegue(self, performSegue: "FromBuyerForm2")
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
            let url = AppConfig.APP_URL+"/user_info/"+userId
            Request().get(url, successHandler: {(response) in self.loadDataToEdit(response)})
        }
    }
    
    func loadDataToEdit(let response: NSData) {
        let result = JSON(data: response)
        dispatch_async(dispatch_get_main_queue()) {
            self.txtFirstName.text = result["last_name"].stringValue
            self.txtLastName.text = result["first_name"].stringValue
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
        if (segue.identifier == "FromBuyerForm2") {
            let view: BuyerForm3ViewController = segue.destinationViewController as! BuyerForm3ViewController
            view.viewData  = self.viewData
        }
    }
    
}
