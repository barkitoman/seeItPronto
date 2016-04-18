//
//  SearchViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 2/16/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate, UIPopoverPresentationControllerDelegate  {

    let picker = UIImageView(image: UIImage(named: "picker_white"))
    
    @IBOutlet weak var btnClass: UIButton!
    
    @IBOutlet weak var beds1: UIButton!
    @IBOutlet weak var beds2: UIButton!
    @IBOutlet weak var beds3: UIButton!
    @IBOutlet weak var beds4: UIButton!
    @IBOutlet weak var beds5: UIButton!
    
    @IBOutlet weak var baths1: UIButton!
    @IBOutlet weak var baths2: UIButton!
    @IBOutlet weak var baths3: UIButton!
    @IBOutlet weak var baths4: UIButton!
    @IBOutlet weak var baths5: UIButton!
    
    
    @IBOutlet weak var txtPriceFrom: UITextField!
    @IBOutlet weak var txtPriceTo: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var swType: UISwitch!
    @IBOutlet weak var txtArea: UITextField!
    @IBOutlet weak var swPool: UISwitch!

    @IBOutlet weak var lblBeds: UILabel!
    @IBOutlet weak var lblBaths: UILabel!
    
    var priceRangeLess:String = "100000"
    var propertySelectedClass:String = "1"
    var propertySelectedClassName:String = "Single Family"
    var bedRooms:String  = ""
    var bathRooms:String = ""
    
    struct properties {
        static let moods = [
            ["title" : "Single Family",             "class":"1",  "color" : "#4870b7"],
            ["title" : "Condo/Coop/Villa/Twnhse",   "class":"2",  "color" : "#4870b7"],
            ["title" : "Residential Income",        "class":"3",  "color" : "#4870b7"],
            ["title" : "ResidentialLand/BoatDocks", "class":"4",  "color" : "#4870b7"],
            ["title" : "Comm/Bus/Agr/Indust Land",  "class":"5",  "color" : "#4870b7"],
            ["title" : "Residential Rental",        "class":"6",  "color" : "#4870b7"],
            ["title" : "Improved Comm/Indust",      "class":"7",  "color" : "#4870b7"],
            ["title" : "Business Opportunity",      "class":"8",  "color" : "#4870b7"],
            ["title" : "Member",                    "class":"9",  "color" : "#4870b7"],
            ["title" : "Office",                    "class":"10", "color" : "#4870b7"],
            ["title" : "Open House",                "class":"13", "color" : "#4870b7"]
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addButtonTarget()
        self.btnClass.setTitle(self.propertySelectedClassName, forState: .Normal)
        self.createPicker()
        self.selfDelegate()
        self.findSearcConfig()
        scrollView.contentSize.height = 1100
    }
    
    func addButtonTarget() {
        self.beds1.addTarget(self, action: "setBedrooms:", forControlEvents: .TouchUpInside)
        self.beds2.addTarget(self, action: "setBedrooms:", forControlEvents: .TouchUpInside)
        self.beds3.addTarget(self, action: "setBedrooms:", forControlEvents: .TouchUpInside)
        self.beds4.addTarget(self, action: "setBedrooms:", forControlEvents: .TouchUpInside)
        self.beds5.addTarget(self, action: "setBedrooms:", forControlEvents: .TouchUpInside)
        
        self.baths1.addTarget(self, action: "setBathrooms:", forControlEvents: .TouchUpInside)
        self.baths2.addTarget(self, action: "setBathrooms:", forControlEvents: .TouchUpInside)
        self.baths3.addTarget(self, action: "setBathrooms:", forControlEvents: .TouchUpInside)
        self.baths4.addTarget(self, action: "setBathrooms:", forControlEvents: .TouchUpInside)
        self.baths5.addTarget(self, action: "setBathrooms:", forControlEvents: .TouchUpInside)
    }
    
    @IBAction func setBedrooms(button:UIButton) {
        self.bedRooms = (button.titleLabel?.text)! as String
        setBedsAndBaths("bedrooms", value: self.bedRooms)
    }
    
    @IBAction func setBathrooms(button:UIButton) {
        self.bathRooms = (button.titleLabel?.text)! as String
        setBedsAndBaths("bathrooms", value: self.bathRooms)
    }
    
    func setBedsAndBaths(type:String, value:String) {
        if(type == "bedrooms") {
            self.beds1.backgroundColor = UIColor(rgba: "#45B5DC")
            self.beds2.backgroundColor = UIColor(rgba: "#45B5DC")
            self.beds3.backgroundColor = UIColor(rgba: "#45B5DC")
            self.beds4.backgroundColor = UIColor(rgba: "#45B5DC")
            self.beds5.backgroundColor = UIColor(rgba: "#45B5DC")
            if(value == "1") {
                beds1.backgroundColor = UIColor(rgba: "#5cb85c")
            } else if(value == "2") {
                beds2.backgroundColor = UIColor(rgba: "#5cb85c")
            } else if(value == "3") {
                beds3.backgroundColor = UIColor(rgba: "#5cb85c")
            } else if(value == "4") {
                beds4.backgroundColor = UIColor(rgba: "#5cb85c")
            } else if(value == "5") {
                beds5.backgroundColor = UIColor(rgba: "#5cb85c")
            }
            
        } else if(type == "bathrooms") {
            self.baths1.backgroundColor = UIColor(rgba: "#45B5DC")
            self.baths2.backgroundColor = UIColor(rgba: "#45B5DC")
            self.baths3.backgroundColor = UIColor(rgba: "#45B5DC")
            self.baths4.backgroundColor = UIColor(rgba: "#45B5DC")
            self.baths5.backgroundColor = UIColor(rgba: "#45B5DC")
            if(value == "1") {
                baths1.backgroundColor = UIColor(rgba: "#5cb85c")
            } else if(value == "2") {
                baths2.backgroundColor = UIColor(rgba: "#5cb85c")
            } else if(value == "3") {
                baths3.backgroundColor = UIColor(rgba: "#5cb85c")
            } else if(value == "4") {
                baths4.backgroundColor = UIColor(rgba: "#5cb85c")
            } else if(value == "5") {
                baths5.backgroundColor = UIColor(rgba: "#5cb85c")
            }
        }
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
    
    //selfDelegate, textFieldShouldReturn are functions for hide keyboard when press 'return' key
    func selfDelegate() {
        self.txtArea.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func btnClass(sender: AnyObject) {
        picker.hidden ? openPicker() : closePicker()
    }
    
    @IBAction func btnBack(sender: AnyObject) {
        self.goBack()
    }
    
    func goBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btnSearch(sender: AnyObject) {
        let userId = User().getField("id")
        var params = "type_property="+Utility().switchValue(self.swType, onValue: "rental", offValue: "sale")+"&area="+self.txtArea.text!
            params = params+"&beds=\(self.bedRooms)&baths=\(self.bathRooms)"
            params = params+"&pool=\(Utility().switchValue(self.swPool, onValue: "1", offValue: "0"))"
            params = params+"&price_range_less=\(txtPriceFrom.text!)&price_range_higher=\(txtPriceTo.text!)"
            params = params+"&user_id=\(userId)&property_class=\(self.propertySelectedClass)&property_class_name=\(self.propertySelectedClassName)"

        var url = AppConfig.APP_URL+"/user_config_searches"
        let configSearchId = SearchConfig().getField("id")
        if(!configSearchId.isEmpty) {
            url = url+"/"+configSearchId
            params = params+"&id="+configSearchId
            Request().put(url, params:params,successHandler: {(response) in self.afterPost(response)});
        } else {
            Request().post(url, params:params,successHandler: {(response) in self.afterPost(response)});
        }
    }
    
    func formValidation()->Bool {
     let out = true
     return out
    }
    
    func afterPost(let response: NSData) {
        let result = JSON(data: response)
        if(result["result"].bool == true ) {
            dispatch_async(dispatch_get_main_queue()) {
                SearchConfig().saveIfExists(result)
                Utility().goHome(self)
            }
        } else {
            var msg = "Error saving, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }
    
    func findSearcConfig(){
        let configSearchId = SearchConfig().getField("id")
        if(!configSearchId.isEmpty && 1 == 2) {
            self.loadSearchConfig()
        } else {
            let url = AppConfig.APP_URL+"/get_search_config/\(User().getField("id"))"
            Request().get(url, successHandler: {(response) in self.afterGet(response)});
        }
    }
    
    func loadSearchConfig() {
        let type = SearchConfig().getField("type_property")
        if(type == "1"){self.swType.on = true}else{self.swType.on = false}
        let area = SearchConfig().getField("area")
        self.txtArea.text = area
        
        self.propertySelectedClass = SearchConfig().getField("property_class")
        let className = SearchConfig().getField("property_class_name")
        if(!className.isEmpty) {
            self.btnClass.setTitle(className, forState: .Normal)
        }
        self.propertySelectedClassName = className
        let beds = SearchConfig().getField("beds")
        if(!beds.isEmpty) {
            self.bedRooms = beds
            setBedsAndBaths("bedrooms", value: beds)
        }
        
        let baths = SearchConfig().getField("baths")
        if(!baths.isEmpty) {
            self.bathRooms = baths
            setBedsAndBaths("bathrooms", value: baths)
        }
        let pool = SearchConfig().getField("pool")
        if(pool == "1"){self.swPool.on = true}else{self.swPool.on = false}
        
        let priceFrom = SearchConfig().getField("price_range_less")
        self.txtPriceFrom.text = priceFrom
        let priceTo = SearchConfig().getField("price_range_higher")
        self.txtPriceTo.text = priceTo
    }
    
    func afterGet(let response: NSData) {
        let result = JSON(data: response)
        if(result["result"].bool == true ) {
            dispatch_async(dispatch_get_main_queue()) {
                SearchConfig().saveIfExists(result)
                self.loadSearchConfig()
            }
        }
    }
    
    func createPicker(){
        picker.frame = CGRect(x: ((self.view.frame.width / 2) - 143), y: 200, width: 286, height: 400)
        picker.alpha = 0
        picker.hidden = true
        picker.userInteractionEnabled = true
        var offset = 35
        for (index, feeling) in properties.moods.enumerate() {
            let button = UIButton()
            button.frame = CGRect(x: 13, y: offset, width: 260, height: 12)
            button.setTitleColor(UIColor(rgba: feeling["color"]!), forState: .Normal)
            button.setTitle(feeling["title"], forState: .Normal)
            button.tag = index
            button.addTarget(self, action: "clickPicker:", forControlEvents: .TouchUpInside)
            picker.addSubview(button)
            offset += 35
        }
        view.addSubview(picker)
    }
    
    @IBAction func clickPicker(sender:UIButton) {
        let index = sender.tag
        self.btnClass.setTitle(properties.moods[index]["title"], forState: .Normal)
        self.propertySelectedClass = properties.moods[index]["class"]!
        self.propertySelectedClassName = properties.moods[index]["title"]!
        closePicker()
    }
    
    func openPicker() {
        self.picker.hidden = false
        UIView.animateWithDuration(0.3,
            animations: {
                self.picker.frame = CGRect(x: ((self.view.frame.width / 2) - 143), y: 100, width: 286, height: 420)
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let popupView = segue.destinationViewController
        if let popup = popupView.popoverPresentationController {
            popup.delegate = self
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }

}
