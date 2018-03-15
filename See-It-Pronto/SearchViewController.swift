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
    var animateDistance: CGFloat!
    
    var propertySelectedClass:String = "1"
    var propertySelectedClassName:String = "Single Family"
    var defaultColor     = "#4870b7"
    var selectedColor    = "#5cb85c"
    var selectedIndex    = 0
    var bedRooms:String  = ""
    var bathRooms:String = ""
    
    struct properties {
        static let moods = [
            ["title" : "Single Family",             "class":"1"],
            ["title" : "Condo/Coop/Villa/Twnhse",   "class":"2"],
            /*
                ["title" : "Residential Rental",        "class":"6"],
                ["title" : "Business Opportunity",      "class":"8"],
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
        
        self.addButtonTarget()
        DispatchQueue.main.async {
            self.btnClass.setTitle(self.propertySelectedClassName, for: UIControlState())
        }
        self.selfDelegate()
        self.findSearcConfig()
        scrollView.contentSize.height = 1100
    }
    
    func addButtonTarget() {
        self.beds1.addTarget(self, action: #selector(SearchViewController.setBedrooms(_:)), for: .touchUpInside)
        self.beds2.addTarget(self, action: #selector(SearchViewController.setBedrooms(_:)), for: .touchUpInside)
        self.beds3.addTarget(self, action: #selector(SearchViewController.setBedrooms(_:)), for: .touchUpInside)
        self.beds4.addTarget(self, action: #selector(SearchViewController.setBedrooms(_:)), for: .touchUpInside)
        self.beds5.addTarget(self, action: #selector(SearchViewController.setBedrooms(_:)), for: .touchUpInside)
        
        self.baths1.addTarget(self, action: #selector(SearchViewController.setBathrooms(_:)), for: .touchUpInside)
        self.baths2.addTarget(self, action: #selector(SearchViewController.setBathrooms(_:)), for: .touchUpInside)
        self.baths3.addTarget(self, action: #selector(SearchViewController.setBathrooms(_:)), for: .touchUpInside)
        self.baths4.addTarget(self, action: #selector(SearchViewController.setBathrooms(_:)), for: .touchUpInside)
        self.baths5.addTarget(self, action: #selector(SearchViewController.setBathrooms(_:)), for: .touchUpInside)
    }
    
    @IBAction func setBedrooms(_ button:UIButton) {
        var selectedBeds = (button.titleLabel?.text)! as String
        selectedBeds     = selectedBeds.replacingOccurrences(of: "+",  with: "", options: NSString.CompareOptions.literal, range: nil)
        self.bedRooms    = selectedBeds
        setBedsAndBaths("bedrooms", value: self.bedRooms)
    }
    
    @IBAction func setBathrooms(_ button:UIButton) {
        var selectedBaths = (button.titleLabel?.text)! as String
        selectedBaths     = selectedBaths.replacingOccurrences(of: "+",  with: "", options: NSString.CompareOptions.literal, range: nil)
        self.bathRooms    = selectedBaths
        setBedsAndBaths("bathrooms", value: self.bathRooms)
    }
    
    func setBedsAndBaths(_ type:String, value:String) {
        DispatchQueue.main.async {
        if(type == "bedrooms") {
            self.beds1.backgroundColor = UIColor(rgba: "#45B5DC")
            self.beds2.backgroundColor = UIColor(rgba: "#45B5DC")
            self.beds3.backgroundColor = UIColor(rgba: "#45B5DC")
            self.beds4.backgroundColor = UIColor(rgba: "#45B5DC")
            self.beds5.backgroundColor = UIColor(rgba: "#45B5DC")
            if(value == "1") {
                self.beds1.backgroundColor = UIColor(rgba: "#5cb85c")
            } else if(value == "2") {
                self.beds2.backgroundColor = UIColor(rgba: "#5cb85c")
            } else if(value == "3") {
                self.beds3.backgroundColor = UIColor(rgba: "#5cb85c")
            } else if(value == "4") {
                self.beds4.backgroundColor = UIColor(rgba: "#5cb85c")
            } else if(value == "5") {
                self.beds5.backgroundColor = UIColor(rgba: "#5cb85c")
            }
            
        } else if(type == "bathrooms") {
            self.baths1.backgroundColor = UIColor(rgba: "#45B5DC")
            self.baths2.backgroundColor = UIColor(rgba: "#45B5DC")
            self.baths3.backgroundColor = UIColor(rgba: "#45B5DC")
            self.baths4.backgroundColor = UIColor(rgba: "#45B5DC")
            self.baths5.backgroundColor = UIColor(rgba: "#45B5DC")
            if(value == "1") {
                self.baths1.backgroundColor = UIColor(rgba: "#5cb85c")
            } else if(value == "2") {
                self.baths2.backgroundColor = UIColor(rgba: "#5cb85c")
            } else if(value == "3") {
                self.baths3.backgroundColor = UIColor(rgba: "#5cb85c")
            } else if(value == "4") {
                self.baths4.backgroundColor = UIColor(rgba: "#5cb85c")
            } else if(value == "5") {
                self.baths5.backgroundColor = UIColor(rgba: "#5cb85c")
            }
        }
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
        self.txtArea.delegate = self
        self.txtPriceFrom.delegate = self
        self.txtPriceTo.delegate = self
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
        let item = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SearchViewController.endEditingNow) )
        let toolbarButtons = [item]
        
        //Put the buttons into the ToolBar and display the tool bar
        keyboardDoneButtonView.setItems(toolbarButtons, animated: false)
        textField.inputAccessoryView = keyboardDoneButtonView
        
        return true
    }
    
    // called when 'return' key pressed. return NO to ignore.
    // Requires having the text fields using the view controller as the delegate.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Sends the keyboard away when pressing the "done" button
        resign()
        return true
        
    }
    
    @IBAction func btnClass(_ sender: AnyObject) {
        picker.isHidden ? openPicker() : closePicker()
    }
    
    @IBAction func btnBack(_ sender: AnyObject) {
        self.goBack()
    }
    
    func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSearch(_ sender: AnyObject) {
        let userId = User().getField("id")
        if(userId.isEmpty) {
            self.saveLocalSearchConfiguration()
        } else {
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
                Request().put(url, params:params,controller:self,successHandler: {(response) in self.afterPost(response)});
            } else {
                Request().post(url, params:params,controller: self,successHandler: {(response) in self.afterPost(response)});
            }
        }
    }
    
    func formValidation()->Bool {
        let out = true
        return out
    }
    
    func afterPost(_ response: Data) {
        let result = JSON(data: response)
        if(result["result"].bool == true ) {
            DispatchQueue.main.async {
                SearchConfig().saveOne(result)
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
        if(!configSearchId.isEmpty) {
            self.loadSearchConfig()
        } else {
            let url = AppConfig.APP_URL+"/get_search_config/\(User().getField("id"))"
            Request().get(url, successHandler: {(response) in self.afterGet(response)});
        }
    }
    
    func loadSearchConfig() {
        let type = SearchConfig().getField("type_property")
        if(type == "rental"){self.swType.isOn = true}else{self.swType.isOn = false}
        let area = SearchConfig().getField("area")
        self.txtArea.text = area
        
        self.propertySelectedClass = SearchConfig().getField("property_class")
        let className = SearchConfig().getField("property_class_name")
        if(!className.isEmpty) {
            DispatchQueue.main.async {
                self.btnClass.setTitle(className, for: UIControlState())
            }
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
        if(pool == "1"){self.swPool.isOn = true}else{self.swPool.isOn = false}
        
        let priceFrom = SearchConfig().getField("price_range_less")
        self.txtPriceFrom.text = priceFrom
        let priceTo = SearchConfig().getField("price_range_higher")
        self.txtPriceTo.text = priceTo
        self.createPicker()
    }
    
    func afterGet(_ response: Data) {
        let result = JSON(data: response)
        DispatchQueue.main.async {
            SearchConfig().saveOne(result)
            self.loadSearchConfig()
        }
    }
    
    func createPicker(){
        picker.frame = CGRect(x: ((self.view.frame.width / 2) - 143), y: 100, width: 286, height: 208)
        picker.alpha = 0
        picker.isHidden = true
        picker.isUserInteractionEnabled = true
        var offset = 21
        for (index, feeling) in properties.moods.enumerated() {
            let button = UIButton()
            button.tag = index
            button.frame = CGRect(x: 13, y: offset, width: 260, height: 43)
            var color = self.defaultColor
            if(feeling["title"] == self.propertySelectedClassName) {
                color = self.selectedColor
                self.selectedIndex = index
            }
            DispatchQueue.main.async {
                button.setTitleColor(UIColor(rgba: color), for: UIControlState())
                button.setTitle(feeling["title"], for: UIControlState())
            }
            button.addTarget(self, action: #selector(SearchViewController.clickPicker(_:)), for: .touchUpInside)
            picker.addSubview(button)
            offset += 44
        }
        view.addSubview(picker)
    }
    
    @IBAction func clickPicker(_ sender:UIButton) {
        let index = sender.tag
        self.selectedIndex = index
        DispatchQueue.main.async {
            self.btnClass.setTitle(properties.moods[index]["title"], for: UIControlState())
        }
        self.propertySelectedClass = properties.moods[index]["class"]!
        self.propertySelectedClassName = properties.moods[index]["title"]!
        closePicker()
    }
    
    func openPicker() {
        for v in self.picker.subviews {
            if (v is UIButton) {
                let button = v as! UIButton
                DispatchQueue.main.async {
                    button.setTitleColor(UIColor(rgba: self.defaultColor), for: UIControlState())
                    if(v.tag == self.selectedIndex) {
                        button.setTitleColor(UIColor(rgba: "#5cb85c"), for: UIControlState())
                    }
                }
            }
        }
        self.picker.isHidden = false
        UIView.animate(withDuration: 0.3,
            animations: {
                self.picker.frame = CGRect(x: ((self.view.frame.width / 2) - 143), y: 120, width: 286, height: 120)
                self.picker.alpha = 1
        })
    }
    
    func closePicker(){
        UIView.animate(withDuration: 0.3,
            animations: {
                self.picker.frame = CGRect(x: ((self.view.frame.width / 2) - 143), y: 200, width: 286, height: 120)
                self.picker.alpha = 0
            },
            completion: { finished in
                self.picker.isHidden = true
            }
        )
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let popupView = segue.destination
        if let popup = popupView.popoverPresentationController {
            popup.delegate = self
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func saveLocalSearchConfiguration(){
        let saveData:JSON = [
            "id":"99999999" as AnyObject,
            "type_property":Utility().switchValue(self.swType, onValue: "rental", offValue: "sale"),
            "area":self.txtArea.text!,
            "beds":self.bedRooms,
            "baths":self.bathRooms,
            "pool":Utility().switchValue(self.swPool, onValue: "1", offValue: "0"),
            "price_range_less":txtPriceFrom.text!,
            "price_range_higher":txtPriceTo.text!,
            "user_id":"",
            "property_class":self.propertySelectedClass,
            "property_class_name":self.propertySelectedClassName,
        ]
        SearchConfig().saveOne(saveData)
        Utility().goHome(self)
    }
    
    @IBAction func clearDataFilter(_ sender: AnyObject) {
        self.clearFields()
        var userId = User().getField("id")
        if(userId.isEmpty) {
            userId = "99999999"
        }
        let url = AppConfig.APP_URL+"/delete_search_config/\(userId)"
        Request().get(url, successHandler: {(response) in self.afterSend(response)})
    }
    
    func afterSend(_ response: Data) {
        SearchConfig().deleteAllData()
        self.txtArea.text = ""
        DispatchQueue.main.async {
            self.btnClass.setTitle("-----------------------", for: UIControlState())
        }
        setBedsAndBaths("bedrooms", value: "0")
        setBedsAndBaths("bathrooms", value: "0")
        self.txtPriceFrom.text = ""
        self.txtPriceTo.text = ""
        
    }
    
    func clearFields() {
        self.txtArea.text      = ""
        self.txtPriceFrom.text = ""
        self.txtPriceTo.text   = ""
        self.beds1.backgroundColor = UIColor(rgba: "#45B5DC")
        self.beds2.backgroundColor = UIColor(rgba: "#45B5DC")
        self.beds3.backgroundColor = UIColor(rgba: "#45B5DC")
        self.beds4.backgroundColor = UIColor(rgba: "#45B5DC")
        self.beds5.backgroundColor = UIColor(rgba: "#45B5DC")
        
        self.baths1.backgroundColor = UIColor(rgba: "#45B5DC")
        self.baths2.backgroundColor = UIColor(rgba: "#45B5DC")
        self.baths3.backgroundColor = UIColor(rgba: "#45B5DC")
        self.baths4.backgroundColor = UIColor(rgba: "#45B5DC")
        self.baths5.backgroundColor = UIColor(rgba: "#45B5DC")
        
        self.bedRooms  = ""
        self.bathRooms = ""
        
        self.swPool.isOn = false
        self.swType.isOn = false
        self.propertySelectedClass = "1"
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
