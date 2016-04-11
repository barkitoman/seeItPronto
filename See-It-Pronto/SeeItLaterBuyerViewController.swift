//
//  MyListingsBuyerViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 3/21/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class SeeItLaterBuyerViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var countPage = 0    //number of current page
    var stepPage  = 6   //number of records by page
    var maxRow    = 0    //maximum limit records of your parse table class
    var maxPage   = 0    //maximum page
    var myListings:NSMutableArray! = NSMutableArray()
    var viewData:JSON = []
    var propertyId:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! SeeItLaterBuyerTableViewCell
        let showing = JSON(self.myListings[indexPath.row])
        cell.lblAddress.text  = showing["property"][0]["address"].stringValue
        cell.lblPrice.text = Utility().formatCurrency(showing["property"][0]["price"].stringValue)
        cell.lblNiceDate.text = showing["nice_date"].stringValue
        let url = AppConfig.APP_URL+"/real_state_property_basics/get_photos_property/"+showing["property"][0]["id"].stringValue+"/1"
        if cell.propertyImage.image == nil {
            Request().get(url, successHandler: {(response) in self.loadImage(cell.propertyImage, response: response)})
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let alertController = UIAlertController(title:"Action", message: "Select an action", preferredStyle: .Alert)
        let deleteAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            self.cancelShowingRequest(indexPath)
        }
        let editAction = UIAlertAction(title: "Edit", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            self.showEditDatePicker(indexPath)
        }
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        alertController.addAction(deleteAction)
        alertController.addAction(editAction)
        alertController.addAction(closeAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showEditDatePicker(indexPath:NSIndexPath){
        DatePickerDialog().show("Select Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .DateAndTime) {
            (date) -> Void in
            var dateTime = "\(date)"
            dateTime     = dateTime.stringByReplacingOccurrencesOfString(" +0000",  withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            let showing = JSON(self.myListings[indexPath.row])
            let params = self.editRequestParams(showing, dateTime:dateTime)
            let url = AppConfig.APP_URL+"/showings/"+showing["id"].stringValue
            Request().put(url,params: params, successHandler: {(response) in })
            let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! SeeItLaterBuyerTableViewCell
            cell.lblNiceDate.text = dateTime
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    func editRequestParams(showing:JSON,dateTime:String)->String{
        let fullUsername = User().getField("first_name")+" "+User().getField("last_name")
        var params = "id=\(showing["id"].stringValue)&date="+dateTime
        params = params+"&notification=1&from_user_id="+User().getField("id")+"&to_user_id="+showing["realtor_id"].stringValue
        params = params+"&title=Showing request edited"
        params = params+"&description=Customer \(fullUsername) has requested a change on the showing date/time for a property"
        params = params+"&parent_id="+showing["id"].stringValue+"&notification_type=showing_cancelled&parent_type=showings"
        return params
    }
    
    
    func cancelShowingRequest(indexPath:NSIndexPath){
        let alertController = UIAlertController(title:"Confirmation", message: "Do you really want to cancel this showing request?", preferredStyle: .Alert)
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            
            let showing = JSON(self.myListings[indexPath.row])
            self.myListings.removeObjectAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            let url = AppConfig.APP_URL+"/showings/"+showing["id"].stringValue
            let params = self.cancelParams(showing)
            Request().put(url,params: params, successHandler: {(response) in })
        }
        let noAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            
        }
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func cancelParams(showing:JSON)->String{
        let fullUsername = User().getField("first_name")+" "+User().getField("last_name")
        var params = "id=\(showing["id"].stringValue)&showing_status="+AppConfig.SHOWING_CANCELED_STATUS
        params = params+"&notification=1&from_user_id="+User().getField("id")+"&to_user_id="+showing["realtor_id"].stringValue
        params = params+"&title=Showing request cancelled"
        params = params+"&description=  The customer \(fullUsername) has cancelled the showing for a property"
        params = params+"&parent_id="+showing["id"].stringValue+"&notification_type=showing_cancelled&parent_type=showings"
        return params
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
            self.tableView.reloadData()
        }
    }

}
