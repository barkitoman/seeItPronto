//
//  AppointmentsViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 3/14/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class AppointmentsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var countPage = 0    //number of current page
    var stepPage  = 6   //number of records by page
    var maxRow    = 0    //maximum limit records of your parse table class
    var maxPage   = 0    //maximum page
    var appoiments:NSMutableArray! = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.findAppoiments()
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appoiments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! AppointmentsTableViewCell
        let appoiment      = JSON(self.appoiments[indexPath.row])
        cell.address.text  = appoiment["property"][0]["address"].stringValue
        cell.lblPrice.text = Utility().formatCurrency(appoiment["property"][0]["price"].stringValue)
        let state = appoiment["showing_status"].stringValue
        cell.lblState.text = self.getState(state)
        cell.niceDate.text = appoiment["nice_date"].stringValue
        let url = AppConfig.APP_URL+"/real_state_property_basics/get_photos_property/"+appoiment["property"][0]["id"].stringValue+"/1"
        if cell.propertyImage.image == nil {
            Request().get(url, successHandler: {(response) in self.loadImage(cell.propertyImage, response: response)})
        }
        return cell
    }
    
    func loadImage(img:UIImageView,let response: NSData) {
        let result = JSON(data: response)
        dispatch_async(dispatch_get_main_queue()) {
           Utility().showPhoto(img, imgPath: result[0]["url"].stringValue)
        }
    }
    
    func getState(state:String)->String {
        var out = ""
        if(state == "0") {
            out = "Pending"
        } else if(state == "1") {
            out = "Accepted"
        } else if(state == "2") {
            out = "Rejected"
        } else if(state == "3") {
            out = "Completed"
        } else if(state == "4") {
            out = "Cancelled"
        }
        return out
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let appoiment = JSON(self.appoiments[indexPath.row])
        let alertController = UIAlertController(title:"Action", message: "Select an action", preferredStyle: .Alert)
        if(appoiment["showing_status"].stringValue == "1" || appoiment["showing_status"].stringValue == "0" ) {
            let deleteAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                self.cancelShowingRequest(indexPath)
            }
            alertController.addAction(deleteAction)
            let editAction = UIAlertAction(title: "Edit", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                self.showEditDatePicker(indexPath)
            }
            alertController.addAction(editAction)
        }
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        alertController.addAction(closeAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showEditDatePicker(indexPath:NSIndexPath){
        DatePickerDialog().show("Select Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .DateAndTime) {
            (date) -> Void in
            var dateTime = "\(date)"
            dateTime     = dateTime.stringByReplacingOccurrencesOfString(" +0000",  withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            let appoiment = JSON(self.appoiments[indexPath.row])
            let params = self.editRequestParams(appoiment, dateTime:dateTime)
            var url = AppConfig.APP_URL+"/showings/"+appoiment["id"].stringValue
            Request().put(url,params: params, successHandler: {(response) in })
            let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! AppointmentsTableViewCell
            url = AppConfig.APP_URL+"/real_state_property_basics/get_photos_property/"+appoiment["property"][0]["id"].stringValue+"/1"
            if cell.propertyImage.image == nil {
                Request().get(url, successHandler: {(response) in self.loadImage(cell.propertyImage, response: response)})
            }
            cell.niceDate.text = dateTime
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    func editRequestParams(appoiment:JSON,dateTime:String)->String{
        let fullUsername = User().getField("first_name")+" "+User().getField("last_name")
        var params = "id=\(appoiment["id"].stringValue)&date="+dateTime
        params = params+"&notification=1&from_user_id="+User().getField("id")+"&to_user_id="+appoiment["buyer_id"].stringValue
        params = params+"&title=Showing request edited"
        params = params+"&description=Agent \(fullUsername) has requested a change on the showing date/time for a property"
        params = params+"&parent_id="+appoiment["id"].stringValue+"&notification_type=showing_cancelled&parent_type=showings"
        return params
    }
    
    func cancelShowingRequest(indexPath:NSIndexPath){
        let alertController = UIAlertController(title:"Confirmation", message: "Do you really want to cancel this showing request?", preferredStyle: .Alert)
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            
            var appoiment = JSON(self.appoiments[indexPath.row])
            let url = AppConfig.APP_URL+"/showings/"+appoiment["id"].stringValue
            let params = self.cancelParams(appoiment)
            Request().put(url,params: params, successHandler: {(response) in })
            
            let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! AppointmentsTableViewCell
            cell.lblState.text = "Cancelled"
            appoiment["showing_status"].int = 4
            self.appoiments[indexPath.row] = appoiment.object
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        let noAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            
        }
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func cancelParams(appoiment:JSON)->String{
        let fullUsername = User().getField("first_name")+" "+User().getField("last_name")
        var params = "id=\(appoiment["id"].stringValue)&showing_status="+AppConfig.SHOWING_CANCELED_STATUS
        params = params+"&notification=1&from_user_id="+User().getField("id")+"&to_user_id="+appoiment["buyer_id"].stringValue
        params = params+"&title=Showing request cancelled"
        params = params+"&description=Agent \(fullUsername) has cancelled the showing for a property"
        params = params+"&parent_id="+appoiment["id"].stringValue+"&notification_type=showing_cancelled&parent_type=showings"
        return params
    }
    
    //Pagination
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
        let row = indexPath.row
        let lastRow = self.appoiments.count - 1
        let pageLimit = (((self.countPage+1) * (self.stepPage)) - 1)  //prevision of the page limit based on step and countPage
        
        // 1) The last rown and is the last
        // 2) To avoid two calls in a short space from time, while the data is downloading
        if (row == lastRow) && (row == pageLimit)  {
            self.countPage++
            print("Loading Page \(self.countPage) from \(self.maxPage)")
            self.findAppoiments()
        }
    }
    
    func findAppoiments() {
        let userId = User().getField("id")
        let role   = User().getField("role")
        let url    = AppConfig.APP_URL+"/list_showings/\(userId)/\(role)/"+String(self.stepPage)+"/?page="+String(self.countPage + 1)
        Request().get(url, successHandler: {(response) in self.loadAppoiments(response)})
    }
    
    func loadAppoiments(let response: NSData){
        let result = JSON(data: response)
        dispatch_async(dispatch_get_main_queue()) {
            for (_,subJson):(String, JSON) in result["data"] {
                let jsonObject: AnyObject = subJson.object
                self.appoiments.addObject(jsonObject)
            }
            self.tableView.reloadData()
        }
    }

}
