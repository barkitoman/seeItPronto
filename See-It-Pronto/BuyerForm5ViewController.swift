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
    var isTakenPhoto:Bool = false
    @IBOutlet weak var choosePicture: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.findUserInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    @IBAction func btnBack(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnPrevious(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnTakePicture(_ sender: AnyObject) {
        self.isTakenPhoto = true
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
                imagePicker.allowsEditing = false
                DispatchQueue.main.async {
                    self.present(imagePicker, animated: true, completion: nil)
                }
            } else {
                Utility().displayAlert(self, title: "Rear camera doesn't exist", message:  "Application cannot access the camera.", performSegue: "")
            }
        } else {
            Utility().displayAlert(self, title: "Camera inaccessable", message: "Application cannot access the camera.", performSegue: "")
        }
    }
    
    @IBAction func btnChoosePicture(_ sender: AnyObject) {
        self.isTakenPhoto = false
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            imagePicker.allowsEditing = true
            DispatchQueue.main.async {
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        self.currentImage.image = image
        if(self.isTakenPhoto == true) {
            self.saveTakenPhoto()
        }
        self.dismiss(animated: true, completion: nil);
    }
    
    @IBAction func btnNext(_ sender: AnyObject) {
        var params = "id="+User().getField("id")
        params     = params+"&pre_qualified="+Utility().switchValue(self.swPreQualified, onValue: "1", offValue: "0")
        params     = params+"&like_pre_qualification="+Utility().switchValue(self.swLikeToBe, onValue: "1", offValue: "0")
        let url    = AppConfig.APP_URL+"/users/"+User().getField("id")
        Request().put(url, params:params,controller:self,successHandler: {(response) in self.afterPut(response)});
    }
    
    //upload photo to server
    func uploadImage() {
        DispatchQueue.main.async {
         if (self.currentImage.image != nil && self.haveImage == true && !self.swPreQualified.isOn) {
            let imageData:Data = UIImageJPEGRepresentation(self.currentImage.image!, 1)!
            SRWebClient.POST(AppConfig.APP_URL+"/users/"+self.viewData["id"].stringValue)
                .data(imageData, fieldName:"pre_qualification_letter_image", data:["id":self.viewData["id"].stringValue,"_method":"PUT"])
                .send({(response:AnyObject!, status:Int) -> Void in
                    },failure:{(error:NSError!) -> Void in
                        print("ERROR UPLOADING PHOTO")
                })
            }
        }
    }
    
    func afterPut(_ response: Data) {
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
    
    @IBAction func swPrequalification(_ sender: AnyObject) {
        DispatchQueue.main.async {
            self.preQualificationFields(!self.swPreQualified.isOn)
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
            let preQualified = result["pre_qualified"].stringValue
            if(preQualified == "1") {
                self.swPreQualified.isOn = true
                self.preQualificationFields(false)
            }else{
                self.swPreQualified.isOn = false
                self.preQualificationFields(true)
            }
            let likeToBe = result["like_pre_qualification"].stringValue
            if(likeToBe == "1"){self.swLikeToBe.isOn = true}else{self.swLikeToBe.isOn = false}
        }
    }
    
    func preQualificationFields(_ preQuealificationIsEnabled:Bool){
        if(preQuealificationIsEnabled == false) {
            self.choosePicture.isHidden  = false
            self.btnScan.isHidden        = false
            self.currentImage.isHidden   = false
            self.lblLikeTobe.isHidden    = true
            self.lblYesLikeTobe.isHidden = true
            self.lblNoLikeTobe.isHidden  = true
            self.swLikeToBe.isHidden     = true
            self.lblIfYesText.isHidden   = false
        } else {
            self.choosePicture.isHidden  = true
            self.btnScan.isHidden        = true
            self.currentImage.isHidden   = true
            self.lblLikeTobe.isHidden    = false
            self.lblYesLikeTobe.isHidden = false
            self.lblNoLikeTobe.isHidden  = false
            self.swLikeToBe.isHidden     = false
            self.lblIfYesText.isHidden   = true
        }
    }
    
    func saveTakenPhoto() {
        let imageData = UIImageJPEGRepresentation(self.currentImage.image!, 0.6)
        let compressedJPGImage = UIImage(data: imageData!)
        UIImageWriteToSavedPhotosAlbum(compressedJPGImage!, nil, nil, nil)
    }
}
