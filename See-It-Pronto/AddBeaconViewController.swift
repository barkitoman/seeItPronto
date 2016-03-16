//
//  AddBeaconViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/4/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class AddBeaconViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate   {

    var viewData:JSON = []
    @IBOutlet weak var txtBrand: UITextField!
    @IBOutlet weak var txtLocation: UITextField!
    @IBOutlet weak var txtBeaconId: UITextField!
    @IBOutlet weak var previewImage: UIImageView!
    var haveImage:Bool = false
    var propertyId:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.findPropertyBeacon()
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

    @IBAction func btnCancel(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btnSave(sender: AnyObject) {
        self.save()
    }
    
    func save() {
        var url = AppConfig.APP_URL+"/beacons"
        var params = "brand="+self.txtBrand.text!+"&beacon_id="+self.txtBeaconId.text!+"&location="+self.txtLocation.text!+"&state_beacon=0&property_id="+self.propertyId
        if(!self.viewData["id"].stringValue.isEmpty) {
            //if user is editing a beacon
            params = params+"&id="+self.viewData["id"].stringValue
            url = AppConfig.APP_URL+"/beacons/"+self.viewData["id"].stringValue
            Request().put(url, params:params,successHandler: {(response) in self.afterPost(response)});
        } else {
            //if user is registering a new beacon
            Request().post(url, params:params,successHandler: {(response) in self.afterPost(response)});
        }
    }
    
    func afterPost(let response: NSData) {
        let result = JSON(data: response)
        if(result["result"].bool == true ) {
            self.viewData = result
            dispatch_async(dispatch_get_main_queue()) {
                self.uploadImage()
            }
            Utility().displayAlert(self,title: "Success", message:"The data have been saved correctly", performSegue:"")
        } else {
            var msg = "Error saving, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }

    @IBAction func btnChoosePicture(sender: AnyObject) {
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(myPickerController, animated: true, completion: nil)
    }
    
    //display image after select
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.previewImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.haveImage = true
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //upload photo to server
    func uploadImage() {
        if (self.previewImage.image != nil && self.haveImage == true) {
            let imageData:NSData = UIImageJPEGRepresentation(self.previewImage.image!, 1)!
            SRWebClient.POST(AppConfig.APP_URL+"/beacons/"+self.viewData["id"].stringValue)
                .data(imageData, fieldName:"image", data:["id":self.viewData["id"].stringValue,"_method":"PUT"])
                .send({(response:AnyObject!, status:Int) -> Void in
                    },failure:{(error:NSError!) -> Void in
                        print("ERROR UPLOADING BEACON IMAGE")
                })
        }
    }
    
    func findPropertyBeacon() {
        let url = AppConfig.APP_URL+"/get_property_beacons/"+self.propertyId
        print(url)
        Request().get(url, successHandler: {(response) in self.loadDataToEdit(response)})
    }
    
    func loadDataToEdit(let response: NSData) {
        let result = JSON(data: response)
        dispatch_async(dispatch_get_main_queue()) {
            self.viewData = result
            self.txtBrand.text    = result["brand"].stringValue
            self.txtBeaconId.text = result["beacon_id"].stringValue
            self.txtLocation.text = result["location"].stringValue
            if(!result["url_image"].stringValue.isEmpty) {
                Utility().showPhoto(self.previewImage, imgPath: result["url_image"].stringValue)
            }
        }
    }
}
