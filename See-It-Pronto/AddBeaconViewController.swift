//
//  AddBeaconViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/4/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class AddBeaconViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate   {


    @IBOutlet weak var btnRemoveBeacon: UIButton!
    @IBOutlet weak var btnSelectBeacon: UIButton!
    var viewData:JSON   = []
    var beaconData:JSON = []
    @IBOutlet weak var txtLocation: UITextField!
    @IBOutlet weak var previewImage: UIImageView!
    var haveImage:Bool = false
    var propertyId:String = ""
    var beaconId = ""
    var animateDistance: CGFloat!
    var isTakenPhoto:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnRemoveBeacon.isHidden = true
        self.propertyId = self.viewData["property"]["id"].stringValue
        self.viewData["id"] = JSON("")
        self.selfDelegate()
        self.findPropertyBeacon()
    }
    
    func reloadButtonTitle() {
        DispatchQueue.main.async {
            self.btnSelectBeacon.setTitle(self.beaconId, for: UIControlState())
        }
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
    
    //selfDelegate, textFieldShouldReturn are functions for hide keyboard when press 'return' key
    func selfDelegate() {
        //self.txtBeaconId.delegate = self
        //self.txtBrand.delegate = self
        self.txtLocation.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func btnBack(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func btnCancel(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSave(_ sender: AnyObject) {
        if(!self.beaconId.isEmpty) {
            self.save()
        } else {
            Utility().displayAlert(self, title: "Error", message: "Please select a beacon", performSegue: "")
        }
    }
    
    func save() {
        var propertyClass = self.viewData["property_class"].stringValue
        if(self.viewData["property_class"].stringValue.isEmpty && !self.viewData["property"]["class"].stringValue.isEmpty) {
            propertyClass = self.viewData["property"]["class"].stringValue
        }
        var url = AppConfig.APP_URL+"/beacons"
        var params = "beacon_id=\(self.beaconId)&location=\(self.txtLocation.text!)"
        params     = params+"&state_beacon=0&property_id=\(self.propertyId)&user_id=\(User().getField("id"))&property_class=\(propertyClass)"
        if(!self.viewData["id"].stringValue.isEmpty) {
            //if user is editing a beacon
            params = params+"&id="+self.viewData["id"].stringValue
            url = AppConfig.APP_URL+"/beacons/"+self.viewData["id"].stringValue
            Request().put(url, params:params,controller:self,successHandler: {(response) in self.afterPost(response)});
        } else {
            //if user is registering a new beacon
            Request().post(url, params:params,controller: self,successHandler: {(response) in self.afterPost(response)});
        }
    }
    
    func afterPost(_ response: Data) {
        let result = JSON(data: response)
        if(result["result"].bool == true ) {
            self.viewData = result
            DispatchQueue.main.async {
                self.uploadImage()
            }
            Utility().displayAlert(self,title: "Success", message:"The data has been saved successfully.", performSegue:"")
        } else {
            var msg = "Error saving, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }
    
    @IBAction func btnTakePhoto(_ sender: AnyObject) {
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
    
    //display image after select
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        self.haveImage = true
        var takedPhoto = image
        takedPhoto = takedPhoto?.correctlyOrientedImage()
        self.previewImage.image = takedPhoto
        if(self.isTakenPhoto == true) {
            self.saveTakenPhoto()
        }
        self.dismiss(animated: true, completion: nil);
    }
    
    func saveTakenPhoto() {
        var takedPhoto = previewImage.image!
        takedPhoto = takedPhoto.correctlyOrientedImage()
        let imageData = UIImageJPEGRepresentation(takedPhoto, 0.6)
        let compressedJPGImage = UIImage(data: imageData!)
        UIImageWriteToSavedPhotosAlbum(compressedJPGImage!, nil, nil, nil)
    }
    
    //upload photo to server
    func uploadImage() {
        if (self.previewImage.image != nil && self.haveImage == true) {
            let imageData:Data = UIImageJPEGRepresentation(self.previewImage.image!, 1)!
            SRWebClient.POST(AppConfig.APP_URL+"/beacons/"+self.viewData["id"].stringValue)
                .data(imageData, fieldName:"image", data:["id":self.viewData["id"].stringValue,"_method":"PUT"])
                .send({(response:AnyObject!, status:Int) -> Void in
                    },failure:{(error:NSError!) -> Void in
                        print("ERROR UPLOADING BEACON IMAGE")
                })
        }
    }
    
    func findPropertyBeacon() {
        let url = AppConfig.APP_URL+"/get_property_beacons/"+User().getField("id")+"/"+self.propertyId
        Request().get(url, successHandler: {(response) in self.loadDataToEdit(response)})
    }
    
    func loadDataToEdit(_ response: Data) {
        let result = JSON(data: response)
        DispatchQueue.main.async {
            if(!result["id"].stringValue.isEmpty) {
                self.btnRemoveBeacon.isHidden = false
                self.viewData = result
                self.beaconId = result["beacon_id"].stringValue
                if(!result["beacon_id"].stringValue.isEmpty) {
                    self.btnSelectBeacon.setTitle(result["beacon_id"].stringValue, for: UIControlState())
                }
                self.txtLocation.text = result["location"].stringValue
                if(!result["url_image"].stringValue.isEmpty) {
                    Utility().showPhoto(self.previewImage, imgPath: result["url_image"].stringValue)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chowSelectBeacon" {
            let vc = segue.destination as! SelectBeaconViewController
            vc.canSelectBeacon = true
            vc.addBeaconVC = self
        }
    }
    
    @IBAction func actionRemoveBeacon(_ sender: UIButton) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title:"Confirmation", message: "Do you really want to remove this beacon?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) {
                UIAlertAction in
                DispatchQueue.main.async {
                    let url = AppConfig.APP_URL+"/remove_beacon_property/\(self.self.viewData["id"].stringValue)"
                    print(url)
                    Request().delete(url, params: "", successHandler: { (response) -> Void in
                        self.afterDeleteBeacon(response)
                    })
                }
            }
            let noAction = UIAlertAction(title: "No", style: UIAlertActionStyle.default) {
                UIAlertAction in
            }
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func afterDeleteBeacon(_ response: Data) {
            let result = JSON(data: response)
            if(result["result"].bool == true) {
                DispatchQueue.main.async {
                    let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    let viewController : MyListingsRealtorViewController = mainStoryboard.instantiateViewController(withIdentifier: "MyListingsRealtorViewController") as! MyListingsRealtorViewController
                    self.navigationController?.show(viewController, sender: nil)
                }
            } else {
                var msg = "Error saving, please try later"
                if(result["msg"].stringValue != "") {
                    msg = result["msg"].stringValue
                }
                Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
            }
        }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let textFieldRect : CGRect = self.view.window!.convert(textField.bounds, from: textField)
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
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        var viewFrame : CGRect = self.view.frame
        viewFrame.origin.y += animateDistance
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(TimeInterval(MoveKeyboard.KEYBOARD_ANIMATION_DURATION))
        self.view.frame = viewFrame
        UIView.commitAnimations()
    }
}
