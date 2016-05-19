//
//  NotificationsViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 2/23/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var countPage = 0    //number of current page
    var stepPage  = 20   //number of records by page
    var maxRow    = 0    //maximum limit records of your parse table class
    var maxPage   = 0    //maximum page
    var notifications:NSMutableArray! = NSMutableArray()
    var viewData:JSON = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    BProgressHUD.showLoadingViewWithMessage("Loading")
        self.findNotifications()
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        let notification = JSON(self.notifications[indexPath.row])
        cell.detailTextLabel?.text = notification["created_at_nice"].stringValue
        cell.textLabel!.text = notification["title"].stringValue
        if(notification["type"] == "see_it_later" || notification["type"] == "see_it_pronto") {
            cell.textLabel!.text = notification["title"].stringValue
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let notification = JSON(self.notifications[indexPath.row])
        let role   = User().getField("role")
        self.viewData = notification
        
        if(role == "realtor" && (notification["type"] == "see_it_later" || notification["type"] == "see_it_pronto")) {
                Utility().displayAlert(self,title: notification["title"].stringValue, message:notification["description"].stringValue, performSegue:"ShowingRequestDetail")
        } else {
            var title = "Notificacion"
            if(!notification["description"].stringValue.isEmpty) {
                title = notification["title"].stringValue
            }
            print(notification)
            if(notification["type"] == "showing_completed" && notification["feedback"].stringValue != "1") {
                print("was here 1")
                self.viewData = ["showing":["id":notification["parent_id"].stringValue,"property_id":notification["property_id"].stringValue, "realtor_id":notification["from_user_id"].stringValue,"notification_id":notification["id"].stringValue]]
                Utility().displayAlert(self,title: title, message:notification["description"].stringValue, performSegue:"showFeedback1")
            } else {
                if(notification["feedback"].stringValue == "1") {
                    print("was here 2")
                    self.performSegueWithIdentifier("NotificationDetail", sender: self)
                } else {
                    print("was here 3")
                    Utility().displayAlert(self,title: title, message:notification["description"].stringValue, performSegue:"NotificationDetail")
                }
            }

        }
    }
    
    //Pagination
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
        let row = indexPath.row
        let lastRow = self.notifications.count - 1
        let pageLimit = (((self.countPage+1) * (self.stepPage)) - 1)  //prevision of the page limit based on step and countPage
        
        // 1) The last rown and is the last
        // 2) To avoid two calls in a short space from time, while the data is downloading
        if (row == lastRow) && (row == pageLimit)  {
            self.countPage++
            print("Loading Page \(self.countPage) from \(self.maxPage)")
            self.findNotifications()
        }
    }
    
    func findNotifications() {
        let userId = User().getField("id")
        let url = AppConfig.APP_URL+"/list_notifications/"+userId+"/"+String(self.stepPage)+"/?page="+String(self.countPage + 1)
        Request().get(url, successHandler: {(response) in self.loadNotifications(response)})
    }
    
    func loadNotifications(let response: NSData){
        let result = JSON(data: response)
        dispatch_async(dispatch_get_main_queue()) {
            BProgressHUD.dismissHUD(0)
            for (_,subJson):(String, JSON) in result["data"] {
                let jsonObject: AnyObject = subJson.object
                self.notifications.addObject(jsonObject)
            }
            if self.notifications.count > 0{
                self.tableView.reloadData()
                BProgressHUD.dismissHUD(0)
            }else{
                BProgressHUD.dismissHUD(0)
                let msg = "¡No notifications found!"
                Utility().displayAlert(self,title: "Notification", message:msg, performSegue:"")
            }
        }
    }
    
    @IBAction func btnBack(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "NotificationDetail") {
            let view: NotificationDetailViewController = segue.destinationViewController as! NotificationDetailViewController
            view.showingId  = self.viewData["parent_id"].stringValue
        }
        if (segue.identifier == "ShowingRequestDetail") {
            let view: ShowingRequestViewController = segue.destinationViewController as! ShowingRequestViewController
            view.showingId  = self.viewData["parent_id"].stringValue
        }
        if (segue.identifier == "showFeedback1") {
            let view: FeedBack1ViewController = segue.destinationViewController as! FeedBack1ViewController
            view.viewData  = self.viewData
        }
    }
    
}
