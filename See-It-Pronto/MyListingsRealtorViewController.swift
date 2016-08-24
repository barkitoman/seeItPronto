//
//  ListPropertiesViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/4/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class MyListingsRealtorViewController: UIViewController, UIPopoverPresentationControllerDelegate, UITableViewDelegate{

    @IBOutlet weak var tableView: UITableView!
    var countPage = 0    //number of current page
    var stepPage  = 20   //number of records by page
    var maxRow    = 0    //maximum limit records of your parse table class
    var maxPage   = 0    //maximum page
    var myListings:NSMutableArray! = NSMutableArray()
    var viewData:JSON = []
    var propertyId:String = ""
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dispatch_async(dispatch_get_main_queue()) {
            BProgressHUD.showLoadingViewWithMessage("Loading")
        }
        self.tableView.delegate = self
        self.findListings()
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
        
        cell.selectedBackgroundView!.layer.borderColor = UIColor.yellowColor().CGColor
        cell.selectedBackgroundView!.layer.borderWidth = 3
        cell.selectedBackgroundView!.backgroundColor = UIColor(white: 0.8, alpha: 0.9)
        
        var listing = JSON(self.myListings[indexPath.row])
        var description = listing["property"]["address"].stringValue+"\n"+Utility().formatCurrency(listing["property"]["price"].stringValue)
        description = description+" "+listing["property"]["bedrooms"].stringValue+" Bd / "+listing["property"]["bathrooms"].stringValue+" Ba "
        cell.lblInformation.text = description
        cell.btnBeacon.tag = indexPath.row
        cell.btnBeacon.addTarget(self, action: "openBeaconView:", forControlEvents: .TouchUpInside)
        
        cell.btnEdit.tag = indexPath.row
        cell.btnEdit.addTarget(self, action: "openEditView:", forControlEvents: .TouchUpInside)
        cell.swBeacon.on = false
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
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Cancel"){(UITableViewRowAction,NSIndexPath) -> Void in
            self.cancelShowingRequest(indexPath)
        }
        return [delete]
    }
    
    func cancelShowingRequest(indexPath:NSIndexPath){
        dispatch_async(dispatch_get_main_queue()) {
            let alertController = UIAlertController(title:"Confirmation", message: "Do you really want to delete this property listing?", preferredStyle: .Alert)
            let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) {
                UIAlertAction in
            
                var listing = JSON(self.myListings[indexPath.row])
                self.myListings.removeObjectAtIndex(indexPath.row)
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                let url = AppConfig.APP_URL+"/realtor_properties/"+listing["id"].stringValue
                Request().delete(url,params:"", successHandler: {(response) in })
            }
            let noAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Default) {
                UIAlertAction in
            
            }
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
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
            if let _ = self?.models[property["id"].stringValue] {
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
    }
    
    @IBAction func openBeaconView(sender:UIButton) {
        let listing = JSON(self.myListings[sender.tag])
        self.viewData = listing
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("MyListingToAddBeacon", sender: self)
        }
    }
    
    @IBAction func openEditView(sender:UIButton) {
        let listing = JSON(self.myListings[sender.tag])
        self.viewData = listing
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("MyListingToEditListng", sender: self)
        }
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
        let url = AppConfig.APP_URL+"/my_listings/\(User().getField("id"))/\(self.stepPage)/?page="+String(self.countPage + 1)
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
            if self.myListings.count > 0 {
                self.tableView.reloadData()
                BProgressHUD.dismissHUD(5)
            }else{
                BProgressHUD.dismissHUD(0)
                let msg = "No properties found!"
                Utility().displayAlert(self,title: "Notification", message:msg, performSegue:"")
                
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "MyListingToAddBeacon") {
            let view: AddBeaconViewController = segue.destinationViewController as! AddBeaconViewController
            view.viewData = self.viewData
            
        }else if (segue.identifier == "MyListingToEditListng") {
            let view: ListingDetailsViewController = segue.destinationViewController as! ListingDetailsViewController
            view.viewData = self.viewData
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
}
