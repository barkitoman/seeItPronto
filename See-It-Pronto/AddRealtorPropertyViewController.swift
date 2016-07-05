//
//  AddRealtorPropertyViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 6/2/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class AddRealtorPropertyViewController: UIViewController {

    @IBOutlet weak var btnClass: UIButton!
    @IBOutlet weak var lblPropertyId: UILabel!
    @IBOutlet weak var txtPropertyId: UITextField!
    let picker = UIImageView(image: UIImage(named: "picker2"))
    var propertySelectedClass:String = "1"
    var propertySelectedClassName:String = "Select Property Type"
    var defaultColor     = "#4870b7"
    var selectedColor    = "#5cb85c"
    var selectedIndex    = 0
    
    struct properties {
        static let moods = [
            ["title" : "Select Property Type",      "class":""],
            ["title" : "Single Family",             "class":"1"],
            ["title" : "Condo/Coop/Villa/Twnhse",   "class":"2"],
            ["title" : "Residential Rental",        "class":"6"],
            ["title" : "Business Opportunity",      "class":"8"],
            /*
            ["title" : "Residential Income",        "class":"3"],
            ["title" : "ResidentialLand/BoatDocks", "class":"4"],
            ["title" : "Comm/Bus/Agr/Indust Land",  "class":"5"],
            ["title" : "Improved Comm/Indust",      "class":"7"],
            ["title" : "Business Opportunity",      "class":"8"],
            ["title" : "Office",                    "class":"10"],
            ["title" : "Open House",                "class":"13"]
            */
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblPropertyId.hidden = true;
        self.txtPropertyId.hidden = true;
        self.createPicker()
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
    
    @IBAction func btnSubmit(sender: AnyObject) {
            self.save()
    }
    
    func save() {
        if(self.selectedIndex != 0) {
            if(self.txtPropertyId.text != "") {
                let url = AppConfig.APP_URL+"/add_property_realtor"
                let params = "property_id=\(self.txtPropertyId.text!)&user_id=\(User().getField("id"))&property_class=\(self.propertySelectedClass)"
                Request().post(url, params:params,controller:self,successHandler: {(response) in self.afterPost(response)});
            } else {
                Utility().displayAlert(self, title: "Message", message: "Please enter a property id", performSegue: "")
            }
        } else {
            Utility().displayAlert(self, title: "Message", message: "Please select a property type", performSegue: "")
        }
    }
    
    func afterPost(let response: NSData) {
        let result = JSON(data: response)
        if(result["result"].bool == true ) {
            Utility().displayAlert(self,title: "Success", message:"The data have been saved correctly", performSegue:"")
        } else {
            var msg = "Error saving, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }
    
    @IBAction func btnSelectClass(sender: AnyObject) {
        picker.hidden ? openPicker() : closePicker()
    }
    
    func createPicker(){
        picker.frame = CGRect(x: ((self.view.frame.width / 2) - 143), y: 100, width: 286, height: 208)
        picker.alpha = 0
        picker.hidden = true
        picker.userInteractionEnabled = true
        var offset = 21
        for (index, feeling) in properties.moods.enumerate() {
            let button = UIButton()
            button.tag = index
            button.frame = CGRect(x: 13, y: offset, width: 260, height: 43)
            var color = self.defaultColor
            if(feeling["title"] == self.propertySelectedClassName) {
                color = self.selectedColor
                self.selectedIndex = index
            }
            button.setTitleColor(UIColor(rgba: color), forState: .Normal)
            button.setTitle(feeling["title"], forState: .Normal)
            button.addTarget(self, action: "clickPicker:", forControlEvents: .TouchUpInside)
            picker.addSubview(button)
            offset += 44
        }
        view.addSubview(picker)
    }
    
    @IBAction func clickPicker(sender:UIButton) {
        let index = sender.tag
        self.selectedIndex = index
        self.btnClass.setTitle(properties.moods[index]["title"], forState: .Normal)
        self.propertySelectedClass = properties.moods[index]["class"]!
        self.propertySelectedClassName = properties.moods[index]["title"]!
        closePicker()
        self.txtPropertyId.text = ""
        if(index == 0) {
            self.lblPropertyId.hidden = true;
            self.txtPropertyId.hidden = true;
        }else {
            self.lblPropertyId.hidden = false;
            self.txtPropertyId.hidden = false;
        }
    }
    
    func openPicker() {
        for v in self.picker.subviews {
            if (v is UIButton) {
                let button = v as! UIButton
                button.setTitleColor(UIColor(rgba: self.defaultColor), forState: .Normal)
                if(v.tag == self.selectedIndex) {
                    button.setTitleColor(UIColor(rgba: "#5cb85c"), forState: .Normal)
                }
            }
        }
        self.picker.hidden = false
        UIView.animateWithDuration(0.3,
            animations: {
                self.picker.frame = CGRect(x: ((self.view.frame.width / 2) - 143), y: 160, width: 286, height: 291)
                self.picker.alpha = 1
        })
    }
    
    func closePicker(){
        UIView.animateWithDuration(0.3,
            animations: {
                self.picker.frame = CGRect(x: ((self.view.frame.width / 2) - 143), y: 200, width: 286, height: 291)
                self.picker.alpha = 0
            },
            completion: { finished in
                self.picker.hidden = true
            }
        )
    }


}
