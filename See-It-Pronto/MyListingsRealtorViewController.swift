//
//  ListPropertiesViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/4/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class MyListingsRealtorViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    let picker = UIImageView(image: UIImage(named: "picker_white"))
    @IBOutlet weak var tableView: UITableView!
    var countPage = 0    //number of current page
    var stepPage  = 20   //number of records by page
    var maxRow    = 0    //maximum limit records of your parse table class
    var maxPage   = 0    //maximum page
    var myListings:NSMutableArray! = NSMutableArray()
    var viewData:JSON = []
    var propertyId:String = ""
    struct properties {
        static let moods = [
            ["title" : "Single Family",             "class":"1"],
            ["title" : "Condo/Coop/Villa/Twnhse",   "class":"2"],
            ["title" : "Residential Income",        "class":"3"],
            ["title" : "ResidentialLand/BoatDocks", "class":"4"],
            ["title" : "Comm/Bus/Agr/Indust Land",  "class":"5"],
            ["title" : "Residential Rental",        "class":"6"],
            ["title" : "Improved Comm/Indust",      "class":"7"],
            ["title" : "Business Opportunity",      "class":"8"],
            ["title" : "Office",                    "class":"10"],
            ["title" : "Open House",                "class":"13"]
        ]
    }
    var propertySelectedClass:String = "1"
    var propertySelectedClassName:String = "Single Family"
    var defaultColor     = "#4870b7"
    var selectedColor    = "#5cb85c"
    var selectedIndex    = 0
    var cache = ImageLoadingWithCache()
    var model = [Model]()
    var models = [String:Model]()
    var count = 0
    
    lazy var configuration : NSURLSessionConfiguration = {
        let config = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        config.allowsCellularAccess = false
        config.URLCache = nil
        return config
    }()
    
    lazy var downloader : MyDownloader = {
        return MyDownloader(configuration:self.configuration)
    }()
    
    @IBOutlet weak var btnPropertyClass: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.findListings()
        self.createPicker()
        self.btnPropertyClass.setTitle(self.propertySelectedClassName, forState: .Normal)
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myListings.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! MyListingsRealtorTableViewCell
        var listing = JSON(self.myListings[indexPath.row])
        var description = listing["property"]["address"].stringValue+"\n"+Utility().formatCurrency(listing["property"]["price"].stringValue)
        description = description+" "+listing["property"]["bedrooms"].stringValue+"Bd / "+listing["property"]["bathrooms"].stringValue+"Ba"
        cell.lblInformation.text = description
        cell.btnBeacon.tag = indexPath.row
        cell.btnBeacon.addTarget(self, action: "openBeaconView:", forControlEvents: .TouchUpInside)
        
        cell.btnEdit.tag = indexPath.row
        cell.btnEdit.addTarget(self, action: "openEditView:", forControlEvents: .TouchUpInside)
        if(listing["state_beacon"].int == 1) {
            cell.swBeacon.on = true
        }
        cell.swBeacon.tag = Int(listing["property"]["id"].stringValue)!
        cell.swBeacon.addTarget(self, action: "turnBeaconOnOff:", forControlEvents: .TouchUpInside)
        let property = listing["property"]
        
        if let _ = self.models[property["id"].stringValue] {
            self.showCell(cell, property: property, indexPath: indexPath)
        } else {
            cell.PropertyImage.image = nil
            self.models[property["id"].stringValue] = Model()
            self.showCell(cell, property: property, indexPath: indexPath)
        }
        return cell
    }
    
    func showCell(cell:MyListingsRealtorTableViewCell, property:JSON,indexPath: NSIndexPath){
        // have we got a picture?
        if let im = self.models[property["id"].stringValue]!.im {
            cell.PropertyImage.image = im
        } else {
            if self.models[property["id"].stringValue]!.task == nil &&  self.models[property["id"].stringValue]!.reloaded == false {
                // no task? start one!
                let url = AppConfig.APP_URL+"/real_state_property_basics/get_photos_property/"+property["id"].stringValue+"/1"
                Request().get(url, successHandler: {(response) in self.imageCell(indexPath, img:cell.PropertyImage, response: response)})
            }
        }
    }
    
    func imageCell(indexPath: NSIndexPath, img:UIImageView,let response: NSData) {
        var listing = JSON(self.myListings[indexPath.row])
        let property = listing["property"]
        let result = JSON(data: response)
        let url = AppConfig.APP_URL+"/"+result[0]["url"].stringValue
        self.models[property["id"].stringValue]!.task = self.downloader.download(url) {
            [weak self] url in // *
            self!.models[property["id"].stringValue]!.task = nil
            if url == nil {
                return
            }
            let data = NSData(contentsOfURL: url)!
            let im = UIImage(data:data)
            self!.models[property["id"].stringValue]!.im = im
            dispatch_async(dispatch_get_main_queue()) {
                self!.models[property["id"].stringValue]!.reloaded = true
                self!.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            }
        }
    }
    
    @IBAction func openBeaconView(sender:UIButton) {
        let listing = JSON(self.myListings[sender.tag])
        self.viewData = listing
        self.performSegueWithIdentifier("MyListingToAddBeacon", sender: self)
    }
    
    @IBAction func openEditView(sender:UIButton) {
        let listing = JSON(self.myListings[sender.tag])
        self.viewData = listing
        self.performSegueWithIdentifier("MyListingToEditListng", sender: self)
    }
    
    @IBAction func turnBeaconOnOff(sender:UISwitch) {
        self.propertyId = String(sender.tag)
        let url = AppConfig.APP_URL+"/turn_beacon_on_off/"+User().getField("id")+"/"+self.propertyId+"/"+Utility().switchValue(sender, onValue: "1", offValue: "0")
        Request().get(url, successHandler: {(response) in self.afterTurnOnOffBeacon(response, sw: sender)})
    }
    
    func afterTurnOnOffBeacon(let response: NSData, sw:UISwitch) {
        let result = JSON(data: response)
        if(result["result"].bool == false ) {
            var msg = "Error saving, please try later"
            if(result["msg"].stringValue != "") {
                dispatch_async(dispatch_get_main_queue()) {
                    sw.on = false
                }
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }
    
    //Pagination
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
        let row = indexPath.row
        let lastRow = self.myListings.count - 1
        let pageLimit = (((self.countPage+1) * (self.stepPage)) - 1)  //prevision of the page limit based on step and countPage
        
        // 1) The last rown and is the last
        // 2) To avoid two calls in a short space from time, while the data is downloading
        if (row == lastRow) && (row == pageLimit)  {
            self.countPage++
            print("Loading Page \(self.countPage) from \(self.maxPage)")
            self.findListings()
        }
    }
    
    func findListings() {
        let url = AppConfig.APP_URL+"/my_listings/\(User().getField("id"))/\(self.stepPage)/\(self.propertySelectedClass)/\(User().getField("mls_id"))/?page="+String(self.countPage + 1)
        print(url)
        Request().get(url, successHandler: {(response) in self.loadListings(response)})
    }
    
    func loadListings(let response: NSData){
        let result = JSON(data: response)
        dispatch_async(dispatch_get_main_queue()) {
            for (_,subJson):(String, JSON) in result{
                if(!subJson["property"]["id"].stringValue.isEmpty) {
                    let jsonObject: AnyObject = subJson.object
                    self.myListings.addObject(jsonObject)
                }
            }
            self.tableView.reloadData()
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
            button.tag = index
            button.frame = CGRect(x: 13, y: offset, width: 260, height: 12)
            var color = self.defaultColor
            if(feeling["title"] == self.propertySelectedClassName) {
                color = self.selectedColor
                self.selectedIndex = index
            }
            button.setTitleColor(UIColor(rgba: color), forState: .Normal)
            button.setTitle(feeling["title"], forState: .Normal)
            button.addTarget(self, action: "clickPicker:", forControlEvents: .TouchUpInside)
            picker.addSubview(button)
            offset += 35
        }
        view.addSubview(picker)
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
        if (segue.identifier == "MyListingToAddBeacon") {
            let view: AddBeaconViewController = segue.destinationViewController as! AddBeaconViewController
            view.viewData = self.viewData
            
        }else if (segue.identifier == "MyListingToEditListng") {
            let view: ListingDetailsViewController = segue.destinationViewController as! ListingDetailsViewController
            view.viewData = self.viewData
        }
        let popupView = segue.destinationViewController
        if let popup = popupView.popoverPresentationController {
            popup.delegate = self
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    @IBAction func btnOpenPropertyClass(sender: AnyObject) {
            picker.hidden ? openPicker() : closePicker()
    }
    
    @IBAction func clickPicker(sender:UIButton) {
        let index = sender.tag
        self.selectedIndex = index
        self.btnPropertyClass.setTitle(properties.moods[index]["title"], forState: .Normal)
        self.propertySelectedClass = properties.moods[index]["class"]!
        self.propertySelectedClassName = properties.moods[index]["title"]!
        closePicker()
        self.myListings.removeAllObjects()
        self.tableView.reloadData()
        self.countPage = 0
        self.findListings()
    }
}
