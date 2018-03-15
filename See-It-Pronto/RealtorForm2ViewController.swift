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
    var isTakenPhoto:Bool = false

    @IBOutlet weak var txtBrokerMail: UITextField!

    let imagePicker: UIImagePickerController! = UIImagePickerController()
    var haveImage:Bool = false
    var viewData:JSON  = []
    
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
    
    func selfDelegate() {
        self.txtLisence.delegate    = self
        self.txtBankAcct.delegate   = self
        self.txtBrokerage.delegate  = self
        self.txtBrokerMail.delegate = self
        self.txtFirstName.delegate  = self
        self.txtLastName.delegate   = self
        self.zipCode1.delegate      = self
        self.zipCode2.delegate      = self
        self.zipCode1.tag           = 1
        self.zipCode2.tag           = 1
    }
    
    @IBAction func btnchoosePicture(_ sender: AnyObject) {
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
    
    //display image after select
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        self.haveImage = true
        var takedPhoto = image
        takedPhoto = takedPhoto?.correctlyOrientedImage()
        self.previewProfilePicture.image = takedPhoto
        if(self.isTakenPhoto == true) {
            self.saveTakenPhoto()
        }
        self.dismiss(animated: true, completion: nil);
    }

    //upload photo to server
    func uploadImage() {
        if (self.previewProfilePicture.image != nil && self.haveImage == true) {
            let imageData:Data = UIImageJPEGRepresentation(self.previewProfilePicture.image!, 1)!
            SRWebClient.POST(AppConfig.APP_URL+"/users/"+self.viewData["id"].stringValue)
                .data(imageData, fieldName:"image", data:["id":self.viewData["id"].stringValue,"_method":"PUT"])
                .send({(response:AnyObject!, status:Int) -> Void in
                    },failure:{(error:NSError!) -> Void in
                        print("ERROR UPLOADING PHOTO")
                })
        }
    }
    
    @IBAction func btnBack(_ sender: AnyObject) {
       navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnPrevious(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSave(_ sender: AnyObject) {
        self.save()
    }
    
    func save() {
        //create params
        var params = "id="+self.viewData["id"].stringValue+"&user_id="+self.viewData["id"].stringValue
        params = params+"&active_zip_code1=\(self.zipCode1.text!)"
        params = params+"&active_zip_code2=\(self.zipCode2.text!)"
        params = params+"&broker_email=\(self.txtBrokerMail.text!)"
        params = params+"&license=\(self.txtLisence.text!)"
        params = params+"&role=realtor&brokerage="+txtBrokerage.text!+"&first_name="+txtFirstName.text!
        params = params+"&last_name="+txtLastName.text!+"&lisence="+txtLisence.text!+"&broker_name="+txtBankAcct.text!+"&broker_email="+self.txtBrokerMail.text!
        if(!self.viewData["realtor_id"].stringValue.isEmpty){
            params = params+"&realtor_id="+self.viewData["realtor_id"].stringValue
        }
        let url = AppConfig.APP_URL+"/users/"+self.viewData["id"].stringValue
        Request().put(url, params:params,controller:self,successHandler: {(response) in self.afterPut(response)});
    }
    
    func afterPut( _ response: Data) {
        let result = JSON(data: response)
        if(result["result"].bool == true) {
            self.viewData = result
            User().updateField("license", value: result["license"].stringValue)
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
    
    func loadDataToEdit( _ response: Data) {
        let result = JSON(data: response)
        DispatchQueue.main.async {
            self.viewData = result
            self.txtFirstName.text  = result["first_name"].stringValue
            self.txtLastName.text   = result["last_name"].stringValue
            self.txtBrokerage.text  = result["brokerage"].stringValue
            self.txtBrokerMail.text = result["broker_email"].stringValue
            self.txtBankAcct.text   = result["broker_name"].stringValue
            self.txtLisence.text    = result["license"].stringValue
            self.zipCode1.text      = result["active_zip_code1"].stringValue
            self.zipCode2.text      = result["active_zip_code2"].stringValue
            if(!result["url_image"].stringValue.isEmpty) {
                Utility().showPhoto(self.previewProfilePicture, imgPath: result["url_image"].stringValue)
            }
        }
    }
    
    func saveTakenPhoto() {
        var takedPhoto = previewProfilePicture.image!
        takedPhoto = takedPhoto.correctlyOrientedImage()
        let imageData = UIImageJPEGRepresentation(takedPhoto, 0.6)
        let compressedJPGImage = UIImage(data: imageData!)
        UIImageWriteToSavedPhotosAlbum(compressedJPGImage!, nil, nil, nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "RealtorForm2") {
            let view: RealtorForm4ViewController = segue.destination as! RealtorForm4ViewController
            view.viewData  = self.viewData
        }
    }
    
    //MARK: - Helper Methods
    
    // This is called to remove the first responder for the text field.
    func resign() {
        self.resignFirstResponder()
    }
    
    // This triggers the textFieldDidEndEditing method that has the textField within it.
    //  This then triggers the resign() method to remove the keyboard.
    //  We use this in the "done" button action.
    func endEditingNow(){
        self.view.endEditing(true)
    }
    
    
    //MARK: - Delegate Methods
    
    // When clicking on the field, use this method.
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        // Create a button bar for the number pad
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        
        // Setup the buttons to be put in the system.
        let item = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(RealtorForm2ViewController.endEditingNow) )
        let toolbarButtons = [item]
        
        //Put the buttons into the ToolBar and display the tool bar
        keyboardDoneButtonView.setItems(toolbarButtons, animated: false)
        
        if textField.tag == 1{
            textField.inputAccessoryView = keyboardDoneButtonView
        }
        
        return true
    }
    
    // called when 'return' key pressed. return NO to ignore.
    // Requires having the text fields using the view controller as the delegate.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Sends the keyboard away when pressing the "done" button
        if textField.tag != 1 {
            self.view.endEditing(true)
            return false
        }else{
            resign()
            return true
        }
    }
    

    
}
