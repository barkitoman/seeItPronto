//
//  MyListingsBuyerViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 3/21/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit
import EventKit

class SeeItLaterBuyerViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var countPage = 0  //number of current page
    var stepPage  = 6  //number of records by page
    var maxRow    = 0  //maximum limit records of your parse table class
    var maxPage   = 0  //maximum page
    var myListings:NSMutableArray! = NSMutableArray()
    var viewData:JSON = []
    var propertyId:String = ""
    var savedEventId:String = ""
    var cache = ImageLoadingWithCache()
    var model = [Model]()
    var models = [String:Model]()
    var count = 0
    var isAddingTocalendar = false;
    
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
        BProgressHUD.showLoadingViewWithMessage("Loading")
        self.findListings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myListings.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell    = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! SeeItLaterBuyerTableViewCell
        let showing = JSON(self.myListings[indexPath.row])
        let address = showing["property"][0]["address"].stringValue
        let price   = (showing["property"][0]["price"].stringValue.isEmpty) ? showing["property_price"].stringValue : showing["property"][0]["price"].stringValue
        
        cell.lblAddress.text  = address
        cell.lblPrice.text = Utility().formatCurrency(price)
        cell.lblNiceDate.text = showing["nice_date"].stringValue
        
        cell.btnViewDetails.tag = indexPath.row
        cell.btnViewDetails.addTarget(self, action: "openViewDetails:", forControlEvents: .TouchUpInside)
        //let property = showing["property"][0]
        if let _ = self.models[showing["property_id"].stringValue] {
            self.showCell(cell, showing: showing, indexPath: indexPath)
        } else {
            cell.propertyImage.image = nil
            self.models[showing["property_id"].stringValue] = Model()
            self.showCell(cell, showing: showing, indexPath: indexPath)
        }
        return cell
    }
    
    func showCell(cell:SeeItLaterBuyerTableViewCell, showing:JSON,indexPath: NSIndexPath){
        // have we got a picture?
        if let im = self.models[showing["property_id"].stringValue]!.im {
            cell.propertyImage.image = im
        } else {
            if self.models[showing["property_id"].stringValue]!.task == nil &&  self.models[showing["property_id"].stringValue]!.reloaded == false {
                // no task? start one!
                let url = AppConfig.APP_URL+"/real_state_property_basics/get_photos_property/"+showing["property_id"].stringValue+"/1"
                Request().get(url, successHandler: {(response) in self.imageCell(indexPath, img:cell.propertyImage, response: response)})
            }
        }
    }
    
    func imageCell(indexPath: NSIndexPath, img:UIImageView,let response: NSData) {
        let showing = JSON(self.myListings[indexPath.row])
        //let property = showing["property"][0]
        let result = JSON(data: response)
        let url = AppConfig.APP_URL+"/"+result[0]["url"].stringValue
        self.models[showing["property_id"].stringValue]!.task = self.downloader.download(url) {
            [weak self] url in // *
            if let _ = self?.models[showing["property_id"].stringValue] {
                self!.models[showing["property_id"].stringValue]!.task = nil
                if url == nil {
                    return
                }
                
                
                let data = NSData(contentsOfURL: url)!
                //if photo is empty
                if data.length <= 116 {
                    let im = UIImage(named: "default_property_photo")
                    self!.models[showing["property_id"].stringValue]!.im = im
                }else {
                    let im = UIImage(data:data)
                    self!.models[showing["property_id"].stringValue]!.im = im
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self!.models[showing["property_id"].stringValue]!.reloaded = true
                    self!.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let showing = JSON(self.myListings[indexPath.row])
        let delete = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Cancel"){(UITableViewRowAction,NSIndexPath) -> Void in
            self.cancelShowingRequest(indexPath)
        }
        let edit = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Reschedule"){(UITableViewRowAction,NSIndexPath) -> Void in
            self.showEditDatePicker(indexPath)
        }
        var calendar = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Add\nEvent"){(UITableViewRowAction,NSIndexPath) -> Void in
            if(self.isAddingTocalendar == false) {
                self.isAddingTocalendar = true
                self.addShowingCalendar(indexPath)
            }
        }
        if(!showing["buyer_calendar_id"].stringValue.isEmpty) {
            calendar = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "View\nEvent"){(UITableViewRowAction,NSIndexPath) -> Void in
                let dateString = "\(showing["date"].stringValue) EST"
                let dateFormatter = NSDateFormatter()
                dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
                let date: NSDate? = dateFormatter.dateFromString(dateString)
                self.gotoAppleCalendar(date!)
            }
        }
        return [delete, edit, calendar]
    }
    
    @IBAction func openViewDetails(sender:UIButton) {
        let showing = JSON(self.myListings[sender.tag])
        Utility().goPropertyDetails(self,propertyId: showing["property"][0]["id"].stringValue, PropertyClass: showing["property_class"].stringValue)
    }
    
    func showEditDatePicker(indexPath:NSIndexPath){
        DatePickerDialog().show("Select Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .DateAndTime) {
            (date) -> Void in
            var dateTime = "\(date)"
            dateTime     = dateTime.stringByReplacingOccurrencesOfString(" +0000",  withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            let showing  = JSON(self.myListings[indexPath.row])
            let params   = self.editRequestParams(showing, dateTime:dateTime)
            let url = AppConfig.APP_URL+"/showings/"+showing["id"].stringValue
            Request().put(url, params:params,controller:self,successHandler: {(response) in self.afterEditRequest(response, indexPath:indexPath)});
        }
    }
    
    func afterEditRequest(let response: NSData, indexPath: NSIndexPath) {
        let result = JSON(data: response)
        if(result["result"].bool == true) {
            dispatch_async(dispatch_get_main_queue()) {
                let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! SeeItLaterBuyerTableViewCell
                cell.lblNiceDate.text = result["showing_date"].stringValue
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                self.tableView.setEditing(false, animated: true)
            }
        } else {
            var msg = "Error saving, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }
    
    func editRequestParams(showing:JSON,dateTime:String)->String{
        let fullUsername = User().getField("first_name")+" "+User().getField("last_name")
        var params = "id=\(showing["id"].stringValue)&date="+dateTime
        params = params+"&notification=1&from_user_id="+User().getField("id")+"&to_user_id="+showing["realtor_id"].stringValue
        params = params+"&title=Showing Request Edited&property_id="+showing["property_id"].stringValue
        params = params+"&description=Customer \(fullUsername) has requested a change on the showing date/time for a property"
        params = params+"&parent_id="+showing["id"].stringValue+"&notification_type=showing_cancelled&parent_type=showings"
        return params
    }
    
    func cancelShowingRequest(indexPath:NSIndexPath){
        dispatch_async(dispatch_get_main_queue()) {
            let alertController = UIAlertController(title:"Confirmation", message: "Do you really want to cancel this showing request?", preferredStyle: .Alert)
            let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) {
                UIAlertAction in
            
                let showing = JSON(self.myListings[indexPath.row])
                self.myListings.removeObjectAtIndex(indexPath.row)
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                let url = AppConfig.APP_URL+"/showings/"+showing["id"].stringValue
                let params = self.cancelParams(showing)
                Request().put(url,params: params, controller:self,successHandler: {(response) in })
                self.removeAppleCalendarEvent(showing["buyer_calendar_id"].stringValue)
            }
            let noAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Default) {
                UIAlertAction in
            
            }
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func cancelParams(showing:JSON)->String{
        let fullUsername = User().getField("first_name")+" "+User().getField("last_name")
        var params = "id=\(showing["id"].stringValue)&showing_status="+AppConfig.SHOWING_CANCELED_STATUS
        params = params+"&notification=1&from_user_id="+User().getField("id")+"&to_user_id="+showing["realtor_id"].stringValue
        params = params+"&title=Showing Request Cancelled&property_id="+showing["property_id"].stringValue
        params = params+"&description=  The customer \(fullUsername) has cancelled the showing for a property"
        params = params+"&parent_id="+showing["id"].stringValue+"&notification_type=showing_cancelled&parent_type=showings&property_class=\(Property().getField("property_class"))&refund=1"
        return params
    }
    
    func addShowingCalendar(indexPath:NSIndexPath) {
        let store = EKEventStore()
        var showing = JSON(self.myListings[indexPath.row])
        //add showing to calendar
        store.requestAccessToEntityType(.Event) {(granted, error) in
            if !granted { return }
            let event = EKEvent(eventStore: store)
            event.title = "See it pronto, showing request.\n \(showing["property"][0]["address"].stringValue)"
            let dateString = "\(showing["date"].stringValue) EST"
            let dateFormatter = NSDateFormatter()
            dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
            let date: NSDate? = dateFormatter.dateFromString(dateString)
            event.startDate = date!
            event.endDate = event.startDate.dateByAddingTimeInterval(60*60) //30 min long meeting
            event.calendar = store.defaultCalendarForNewEvents
            do {
                try store.saveEvent(event, span: .ThisEvent, commit: true)
                self.savedEventId = event.eventIdentifier
                showing["buyer_calendar_id"].stringValue = self.savedEventId
                self.myListings[indexPath.row] = showing.object
                dispatch_async(dispatch_get_main_queue()) {
                    self.saveCalendarId(showing)
                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                    self.tableView.setEditing(false, animated: true)
                    self.isAddingTocalendar = false
                    self.gotoAppleCalendar(event.startDate)
                }
                //save event id to access this particular event later
            } catch {
                self.isAddingTocalendar = false
                Utility().displayAlert(self, title: "Error", message: "Error saving, please try later", performSegue: "")
            }
        }
    }
    
    func removeAppleCalendarEvent(eventId:String) {
        if(!eventId.isEmpty){
            let store = EKEventStore()
                store.requestAccessToEntityType(EKEntityType.Event) {(granted, error) in
                if !granted { return }
                let eventToRemove = store.eventWithIdentifier(eventId)
                if eventToRemove != nil {
                    do {
                    try store.removeEvent(eventToRemove!, span: .ThisEvent, commit: true)
                    } catch {
                    // Display error to user
                    }
                }
            }
        }
    }
    
    func loadImage(img:UIImageView,let response: NSData) {
        let result = JSON(data: response)
        dispatch_async(dispatch_get_main_queue()) {
            Utility().showPhoto(img, imgPath: result[0]["url"].stringValue)
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
        let url = AppConfig.APP_URL+"/see_it_later_buyer/\(User().getField("id"))/\(self.stepPage)/?page="+String(self.countPage + 1)
        Request().get(url, successHandler: {(response) in self.loadListings(response)})
    }
    
    func loadListings(let response: NSData){
        let result = JSON(data: response)
        dispatch_async(dispatch_get_main_queue()) {
            for (_,subJson):(String, JSON) in result["data"] {
                let jsonObject: AnyObject = subJson.object
                self.myListings.addObject(jsonObject)
            }
            if self.myListings.count > 0 {
                self.tableView.reloadData()
                BProgressHUD.dismissHUD(4)
            }else{
                BProgressHUD.dismissHUD(0)
                let msg = "No properties found!"
                Utility().displayAlert(self,title: "Notification", message:msg, performSegue:"")
            }
            
            
        }
    }
    
    func saveCalendarId(showing:JSON) {
        let params = "id=\(showing["id"].stringValue)&buyer_calendar_id=\(self.savedEventId)"
        let url = AppConfig.APP_URL+"/showings/\(showing["id"].stringValue)"
        Request().put(url,params: params, controller:self,successHandler: {(response) in })
    }
    
    func gotoAppleCalendar(date: NSDate) {
        let interval = date.timeIntervalSinceReferenceDate
        let url = NSURL(string: "calshow:\(interval)")!
        UIApplication.sharedApplication().openURL(url)
    }

}
