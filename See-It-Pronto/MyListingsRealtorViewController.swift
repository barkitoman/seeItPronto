//
//  ListPropertiesViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/4/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class MyListingsRealtorViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var countPage = 0    //number of current page
    var stepPage  = 20   //number of records by page
    var maxRow    = 0    //maximum limit records of your parse table class
    var maxPage   = 0    //maximum page
    var myListings:NSMutableArray! = NSMutableArray()
    var viewData:JSON = []
    var propertyId:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    @IBAction func btnSearchAgain(sender: AnyObject) {
        Utility().goHome(self)
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
        var description = listing["address"].stringValue+" $"+listing["price"].stringValue
        description = description+" "+listing["bedrooms"].stringValue+"Br / "+listing["bathrooms"].stringValue+"Ba"
        cell.lblInformation.text = description
        if(!listing["image"].stringValue.isEmpty) {
            Utility().showPhoto(cell.PropertyImage, imgPath: listing["image"].stringValue)
        }
        cell.btnBeacon.tag = Int(listing["id"].stringValue)!
        cell.btnBeacon.addTarget(self, action: "openBeaconView:", forControlEvents: .TouchUpInside)
        
        cell.btnEdit.tag = Int(listing["id"].stringValue)!
        cell.btnEdit.addTarget(self, action: "openEditView:", forControlEvents: .TouchUpInside)
        if(listing["state_beacon"].int == 1) {
            cell.swBeacon.on = true
        }
        cell.swBeacon.tag = Int(listing["id"].stringValue)!
        cell.swBeacon.addTarget(self, action: "turnBeaconOnOff:", forControlEvents: .TouchUpInside)
        return cell
    }
    
    @IBAction func openBeaconView(sender:UIButton) {
        self.propertyId = String(sender.tag)
        self.performSegueWithIdentifier("MyListingToAddBeacon", sender: self)
    }
    
    @IBAction func openEditView(sender:UIButton) {
        self.propertyId = String(sender.tag)
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
        let url = AppConfig.APP_URL+"/my_listings/\(User().getField("id"))/\(self.stepPage)/\(User().getField("mls_id"))/?page="+String(self.countPage + 1)
        Request().get(url, successHandler: {(response) in self.loadListings(response)})
    }
    
    func loadListings(let response: NSData){
        let result = JSON(data: response)
        dispatch_async(dispatch_get_main_queue()) {
            for (_,subJson):(String, JSON) in result {
                let jsonObject: AnyObject = subJson.object
                self.myListings.addObject(jsonObject)
            }
            self.tableView.reloadData()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "MyListingToAddBeacon") {
            let view: AddBeaconViewController = segue.destinationViewController as! AddBeaconViewController
            view.propertyId = self.propertyId
            
        }else if (segue.identifier == "MyListingToEditListng") {
            let view: ListingDetailsViewController = segue.destinationViewController as! ListingDetailsViewController
            view.propertyId = self.propertyId
        }
    }

}
