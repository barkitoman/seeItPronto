//
//  SearchViewController.swift
//  See-It-Pronto
//
//  Created by user114136 on 2/16/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate  {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var swType: UISwitch!
    @IBOutlet weak var txtArea: UITextField!
    @IBOutlet weak var slBeds: UISlider!
    @IBOutlet weak var slBaths: UISlider!
    @IBOutlet weak var swPool: UISwitch!
    @IBOutlet weak var slPriceRange: UISlider!
    @IBOutlet weak var swPreQualified: UISwitch!
    @IBOutlet weak var swLikeToBe: UISwitch!

    @IBOutlet weak var lblBeds: UILabel!
    @IBOutlet weak var lblBaths: UILabel!
    @IBOutlet weak var lblPriceRange: UILabel!
    
    @IBOutlet weak var btnScan: UIButton!
    @IBOutlet weak var lblLikeTobe: UILabel!
    @IBOutlet weak var lblNoLikeTobe: UILabel!
    @IBOutlet weak var lblYesLikeTobe: UILabel!
    
    var priceRangeLess:String = "100000"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentSize.height = 1100
        self.selfDelegate()
        self.loadSearcConfig()
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
    
    @IBAction func selectBeds(sender: AnyObject) {
        let beds = String(Int(roundf(slBeds.value)))
        self.showSlidersValues(beds,baths: "",priceRange: "")
    }
    
    @IBAction func selectBaths(sender: AnyObject) {
        let baths = String(Int(roundf(slBaths.value)))
        self.showSlidersValues("",baths: baths,priceRange: "")
    }
    
    @IBAction func selectPriceRange(sender: AnyObject) {
        let priceRange = String(Int(roundf(slPriceRange.value)))
        self.showSlidersValues("",baths: "",priceRange: priceRange)
    }
    
    @IBAction func swPrequalification(sender: AnyObject) {
        self.preQualificationFields(!self.swPreQualified.on)
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
            params = params+"&beds="+Utility().sliderValue(self.slBeds)+"&baths="+Utility().sliderValue(self.slBaths)
            params = params+"&pool="+Utility().switchValue(self.swLikeToBe, onValue: "1", offValue: "0")
            params = params+"&price_range_less="+self.priceRangeLess+"&price_range_higher="+Utility().sliderValue(self.slPriceRange)
            params = params+"&pre_qualified="+Utility().switchValue(self.swPreQualified, onValue: "1", offValue: "0")
            params = params+"&like_pre_qualification="+Utility().switchValue(self.swLikeToBe, onValue: "1", offValue: "0")+"&user_id="+userId
        
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
    
    func afterPost(let response: NSData) {
        let result = JSON(data: response)
        if(result["result"].bool == true ) {
            dispatch_async(dispatch_get_main_queue()) {
                SearchConfig().saveIfExists(result)
                self.goBack()
            }
        } else {
            var msg = "Error saving, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }
    
    func loadSearcConfig(){
        let configSearchId = SearchConfig().getField("id")
        if(!configSearchId.isEmpty) {
            let type = SearchConfig().getField("type_property")
            if(type == "1"){self.swType.on = true}else{self.swType.on = false}
            let area = SearchConfig().getField("area")
            self.txtArea.text = area
            let beds = SearchConfig().getField("beds")
            if(!beds.isEmpty) {
                self.slBeds.value = Float(beds)!
                self.showSlidersValues(beds, baths: "", priceRange: "")
            }
            
            let baths = SearchConfig().getField("baths")
            if(!baths.isEmpty) {
                self.slBaths.value = Float(baths)!
                self.showSlidersValues("", baths: baths, priceRange: "")
            }
            let pool = SearchConfig().getField("pool")
            if(pool == "1"){self.swPool.on = true}else{self.swPool.on = false}
            
            let price = SearchConfig().getField("id")
            if(!price.isEmpty) {
                self.slPriceRange.value = Float(beds)!
                self.showSlidersValues("", baths: "", priceRange: price)
            }
            
            let preQualified = SearchConfig().getField("pre_qualified")
            if(preQualified == "1") {
                self.swPreQualified.on = true
                self.preQualificationFields(false)
            }else{
                self.swPreQualified.on = false
                self.preQualificationFields(true)
            }
            
            let likeToBe = SearchConfig().getField("like_pre_qualification")
            if(likeToBe == "1"){self.swLikeToBe.on = true}else{self.swLikeToBe.on = false}
        }
    }
    
    func showSlidersValues(beds:String,baths:String, var priceRange:String) {
        if(!beds.isEmpty){
            self.lblBeds.text = "Your Preference: \(beds) Beds"
        }
        if(!baths.isEmpty){
            self.lblBaths.text = "Your Preference: \(baths) Baths"
        }
        if(!priceRange.isEmpty){
            priceRange = Utility().formatCurrency(priceRange)
            self.lblPriceRange.text  = "Your Preference: \(priceRange)"
        }
    }
    
    func preQualificationFields(preQuealificationIsEnabled:Bool){
        if(preQuealificationIsEnabled == true) {
            self.btnScan.enabled       = true
            self.lblLikeTobe.hidden    = true
            self.lblYesLikeTobe.hidden = true
            self.lblNoLikeTobe.hidden  = true
            self.swLikeToBe.hidden     = true
        } else {
            self.btnScan.enabled       = false
            self.lblLikeTobe.hidden    = false
            self.lblYesLikeTobe.hidden = false
            self.lblNoLikeTobe.hidden  = false
            self.swLikeToBe.hidden     = false
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    }

}
