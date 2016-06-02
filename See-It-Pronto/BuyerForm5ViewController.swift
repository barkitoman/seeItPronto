//
//  BuerForm5ViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 3/23/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class BuyerForm5ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var viewData:JSON = []
    @IBOutlet weak var swPreQualified: UISwitch!
    @IBOutlet weak var swLikeToBe: UISwitch!
    @IBOutlet weak var lblLikeTobe: UILabel!
    @IBOutlet weak var lblNoLikeTobe: UILabel!
    @IBOutlet weak var lblYesLikeTobe: UILabel!
    @IBOutlet weak var btnScan: UIButton!
    @IBOutlet weak var lblIfYesText: UILabel!
    let imagePicker: UIImagePickerController! = UIImagePickerController()
    @IBOutlet weak var currentImage: UIImageView!
    var haveImage:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.findUserInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    @IBAction func btnBack(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btnPrevious(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btnTakePicture(sender: AnyObject) {
        if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
            if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .Camera
                imagePicker.cameraCaptureMode = .Photo
                presentViewController(imagePicker, animated: true, completion: {})
            } else {
                Utility().displayAlert(self, title: "Rear camera doesn't exist", message:  "Application cannot access the camera.", performSegue: "")
            }
        } else {
            Utility().displayAlert(self, title: "Camera inaccessable", message: "Application cannot access the camera.", performSegue: "")
        }
    }
    
    func documentPicker(controller: UIDocumentPickerViewController, didPickDocumentAtURL url: NSURL) {
        if controller.documentPickerMode == UIDocumentPickerMode.Import {
            // This is what it should be
            print(url.path)
            //self.newNoteBody.text = String(contentsOfFile: url.path!)
        }
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage:UIImage = (info[UIImagePickerControllerOriginalImage]) as? UIImage {
            let selectorToCall = Selector("imageWasSavedSuccessfully:didFinishSavingWithError:context:")
            UIImageWriteToSavedPhotosAlbum(pickedImage, self, selectorToCall, nil)
        }
        imagePicker.dismissViewControllerAnimated(true, completion: {
            // Anything you want to happen when the user saves an image
        })
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
                self.currentImage.image = image
            })
        }
    }
    
    @IBAction func btnNext(sender: AnyObject) {
        var params = "id="+User().getField("id")
        params     = params+"&pre_qualified="+Utility().switchValue(self.swPreQualified, onValue: "1", offValue: "0")
        params     = params+"&like_pre_qualification="+Utility().switchValue(self.swLikeToBe, onValue: "1", offValue: "0")
        let url    = AppConfig.APP_URL+"/users/"+User().getField("id")
        Request().put(url, params:params,controller:self,successHandler: {(response) in self.afterPut(response)});
    }
    
    //upload photo to server
    func uploadImage() {
        dispatch_async(dispatch_get_main_queue()) {
         if (self.currentImage.image != nil && self.haveImage == true && !self.swPreQualified.on) {
            let imageData:NSData = UIImageJPEGRepresentation(self.currentImage.image!, 1)!
            SRWebClient.POST(AppConfig.APP_URL+"/users/"+self.viewData["id"].stringValue)
                .data(imageData, fieldName:"pre_qualification_letter_image", data:["id":self.viewData["id"].stringValue,"_method":"PUT"])
                .send({(response:AnyObject!, status:Int) -> Void in
                    },failure:{(error:NSError!) -> Void in
                        print("ERROR UPLOADING PHOTO")
                })
         }
        }
    }
    
    func afterPut(let response: NSData) {
        let result = JSON(data: response)
        if(result["result"].bool == true) {
            self.viewData = result
            self.uploadImage()
            Utility().performSegue(self, performSegue: "FromBuyerForm5")
        } else {
            var msg = "Error saving, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }
    
    @IBAction func swPrequalification(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue()) {
            self.preQualificationFields(!self.swPreQualified.on)
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
            let preQualified = result["pre_qualified"].stringValue
            if(preQualified == "1") {
                self.swPreQualified.on = true
                self.preQualificationFields(false)
            }else{
                self.swPreQualified.on = false
                self.preQualificationFields(true)
            }
            let likeToBe = result["like_pre_qualification"].stringValue
            if(likeToBe == "1"){self.swLikeToBe.on = true}else{self.swLikeToBe.on = false}
        }
    }
    
    func preQualificationFields(preQuealificationIsEnabled:Bool){
        if(preQuealificationIsEnabled == false) {
            self.btnScan.hidden        = false
            self.currentImage.hidden   = false
            self.lblLikeTobe.hidden    = true
            self.lblYesLikeTobe.hidden = true
            self.lblNoLikeTobe.hidden  = true
            self.swLikeToBe.hidden     = true
            self.lblIfYesText.hidden   = false
        } else {
            self.btnScan.hidden        = true
            self.currentImage.hidden   = true
            self.lblLikeTobe.hidden    = false
            self.lblYesLikeTobe.hidden = false
            self.lblNoLikeTobe.hidden  = false
            self.swLikeToBe.hidden     = false
            self.lblIfYesText.hidden   = true
        }
    }
}
