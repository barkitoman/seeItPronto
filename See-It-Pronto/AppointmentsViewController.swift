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
        let appoiment = JSON(self.appoiments[indexPath.row])
        
        let address = appoiment["property"][0]["address"].stringValue
        let price   = (appoiment["property"][0]["price"].stringValue.isEmpty) ? appoiment["property_price"].stringValue : appoiment["property"][0]["price"].stringValue
        
        cell.address.text  = address
        cell.lblPrice.text = Utility().formatCurrency(price)
        let state = appoiment["showing_status"].stringValue
        cell.lblState.text = self.getState(state)
        cell.niceDate.text = appoiment["nice_date"].stringValue
        
        if let _ = self.models[appoiment["property_id"].stringValue] {
            self.showCell(cell, appoiment: appoiment, indexPath: indexPath)
        } else {
            cell.propertyImage.image = nil
            self.models[appoiment["property_id"].stringValue] = Model()
            self.showCell(cell, appoiment: appoiment, indexPath: indexPath)
        }
        return cell
    }
    
    func showCell(cell:AppointmentsTableViewCell, appoiment:JSON, indexPath: NSIndexPath){
        // have we got a picture?
        if let im = self.models[appoiment["property_id"].stringValue]!.im {
            cell.propertyImage.image = im
        } else {
            if self.models[appoiment["property_id"].stringValue]!.task == nil &&  self.models[appoiment["property_id"].stringValue]!.reloaded == false {
                // no task? start one!
                let url = AppConfig.APP_URL+"/real_state_property_basics/get_photos_property/"+appoiment["property_id"].stringValue+"/1"
                Request().get(url, successHandler: {(response) in self.imageCell(indexPath, img:cell.propertyImage, response: response)})
            }
        }
    }
    
    func imageCell(indexPath: NSIndexPath, img:UIImageView,let response: NSData) {
        let appoiment = JSON(self.appoiments[indexPath.row])
        let result = JSON(data: response)
        let url = AppConfig.APP_URL+"/"+result[0]["url"].stringValue
        self.models[appoiment["property_id"].stringValue]!.task = self.downloader.download(url) {
            [weak self] url in // *
            if let _ = self?.models[appoiment["property_id"].stringValue] {
                self!.models[appoiment["property_id"].stringValue]!.task = nil
                if url == nil {
                    return
                }
                let data = NSData(contentsOfURL: url)!
                //if photo is empty
                if data.length <= 116 {
                    let im = UIImage(named: "default_property_photo")
                    self!.models[appoiment["property_id"].stringValue]!.im = im
                } else {
                    let im = UIImage(data:data)
                    self!.models[appoiment["property_id"].stringValue]!.im = im
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self!.models[appoiment["property_id"].stringValue]!.reloaded = true
                    self!.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
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
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let appoiment = JSON(self.appoiments[indexPath.row])
        if(appoiment["showing_status"].stringValue == "1" || appoiment["showing_status"].stringValue == "0" ) {
            return true
        }
        return false
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let appoiment = JSON(self.appoiments[indexPath.row])
        let delete = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Cancel"){
            (UITableViewRowAction,NSIndexPath) -> Void in
            self.cancelShowingRequest(indexPath)
        }
        let edit = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Reschedule"){
            (UITableViewRowAction,NSIndexPath) -> Void in
            self.showEditDatePicker(indexPath)
        }
        let chat = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Chat With\nCustomer"){(UITableViewRowAction,NSIndexPath) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                let vc : ChatViewController = mainStoryboard.instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
                vc.to = appoiment["buyer_id"].stringValue
                self.navigationController?.showViewController(vc, sender: nil)
            }
        }
        return [delete, edit, chat]
    }
    
    func showEditDatePicker(indexPath:NSIndexPath){
        DatePickerDialog().show("Select Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .DateAndTime) {
            (date) -> Void in
            var dateTime  = "\(date)"
            dateTime      = dateTime.stringByReplacingOccurrencesOfString(" +0000",  withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            let appoiment = JSON(self.appoiments[indexPath.row])
            let params = self.editRequestParams(appoiment, dateTime:dateTime)
            let url = AppConfig.APP_URL+"/showings/"+appoiment["id"].stringValue
            Request().put(url, params:params,controller:self,successHandler: {(response) in self.afterEditRequest(response, indexPath:indexPath, appoiment:appoiment)});
        }
    }
    
    func afterEditRequest(let response: NSData, indexPath: NSIndexPath,appoiment:JSON) {
        let result = JSON(data: response)
        if(result["result"].bool == true) {
            dispatch_async(dispatch_get_main_queue()) {
                let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! AppointmentsTableViewCell
                cell.niceDate.text = result["showing_date"].stringValue
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
    
    func editRequestParams(appoiment:JSON,dateTime:String)->String{
        let fullUsername = User().getField("first_name")+" "+User().getField("last_name")
        var params = "id=\(appoiment["id"].stringValue)&date="+dateTime
        params = params+"&notification=1&from_user_id="+User().getField("id")+"&to_user_id="+appoiment["buyer_id"].stringValue
        params = params+"&title=Showing Request Edited&property_id="+appoiment["property_id"].stringValue
        params = params+"&description=Agent \(fullUsername) has requested a change on the showing date/time for a property"
        params = params+"&parent_id="+appoiment["id"].stringValue+"&notification_type=showing_cancelled&parent_type=showings"
        return params
    }
    
    func cancelShowingRequest(indexPath:NSIndexPath){
        dispatch_async(dispatch_get_main_queue()) {
            let alertController = UIAlertController(title:"Confirmation", message: "Do you really want to cancel this showing request?", preferredStyle: .Alert)
            let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) {
                UIAlertAction in
            
                var appoiment = JSON(self.appoiments[indexPath.row])
                let url = AppConfig.APP_URL+"/showings/"+appoiment["id"].stringValue
                let params = self.cancelParams(appoiment)
                Request().put(url,params: params,controller:self, successHandler: {(response) in })
            
                let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! AppointmentsTableViewCell
                cell.lblState.text = "Cancelled"
                appoiment["showing_status"].int = 4
                self.appoiments[indexPath.row] = appoiment.object
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                self.tableView.setEditing(false, animated: true)
            }
            let noAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Default) {
                UIAlertAction in
            }
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func cancelParams(appoiment:JSON)->String{
        let fullUsername = User().getField("first_name")+" "+User().getField("last_name")
        var params = "id=\(appoiment["id"].stringValue)&showing_status="+AppConfig.SHOWING_CANCELED_STATUS
        params = params+"&notification=1&from_user_id="+User().getField("id")+"&to_user_id="+appoiment["buyer_id"].stringValue
        params = params+"&title=Showing Request Cancelled&property_id="+appoiment["property_id"].stringValue
        params = params+"&description=Agent \(fullUsername) has cancelled the showing for a property"
        params = params+"&parent_id="+appoiment["id"].stringValue+"&notification_type=showing_cancelled&parent_type=showings&refund=1"
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
            if(self.appoiments.count == 0 && self.countPage == 0) {
                BProgressHUD.dismissHUD(0)
                Utility().displayAlert(self, title: "Message", message: "There are no appointments available to show", performSegue: "")
                
            }
            self.tableView.reloadData()
            BProgressHUD.dismissHUD(4)
        }
    }

}
