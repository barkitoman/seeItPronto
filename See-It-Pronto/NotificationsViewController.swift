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
    var showNewNotificationMsg = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(self.showNewNotificationMsg == true) {
            Utility().displayAlert(self, title: "Message", message: "New notification received", performSegue: "")
            DispatchQueue.main.async {
                BProgressHUD.showLoadingViewWithMessage("Loading...")
            }
        } else {
            DispatchQueue.main.async {
                BProgressHUD.showLoadingViewWithMessage("Loading...")
            }
        }
        self.findNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        let notification = JSON(self.notifications[indexPath.row])
        cell.detailTextLabel?.text = notification["created_at_nice"].stringValue
        cell.textLabel!.text = notification["title"].stringValue
        cell.textLabel!.textColor = UIColor(rgba: "#000000")
        cell.detailTextLabel!.textColor = UIColor(rgba: "#000000")
        if(notification["seen"].stringValue == "0") {
            cell.textLabel!.textColor = UIColor(rgba: "#5cb85c")
            cell.detailTextLabel!.textColor = UIColor(rgba: "#5cb85c")
        }
        if(notification["type"] == "see_it_later" || notification["type"] == "see_it_pronto") {
            cell.textLabel!.text = notification["title"].stringValue
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        var notification = JSON(self.notifications[indexPath.row])
        let role   = User().getField("role")
        self.viewData = notification
        DispatchQueue.main.async {
            if(notification["seen"].stringValue == "0") {
                let cell = self.tableView.cellForRow(at: indexPath)! as UITableViewCell
                cell.textLabel!.textColor = UIColor(rgba: "#000000")
                cell.detailTextLabel!.textColor = UIColor(rgba: "#000000")
                notification["seen"].string = "1"
                self.notifications[indexPath.row] = notification.object
                self.seenNotificationRequest(notification["id"].stringValue)
            }
        }
        if(role == "realtor" && (notification["type"] == "see_it_later" || notification["type"] == "see_it_pronto")) {
                Utility().displayAlert(self,title: notification["title"].stringValue, message:notification["description"].stringValue, performSegue:"ShowingRequestDetail")
        } else {
            var title = "Notificacion"
            if(!notification["description"].stringValue.isEmpty) {
                title = notification["title"].stringValue
            }
            if(notification["type"] == "showing_completed" && notification["feedback"].stringValue != "1") {
                self.viewData = ["showing":["id":notification["parent_id"].stringValue,"property_id":notification["property_id"].stringValue, "realtor_id":notification["from_user_id"].stringValue,"notification_id":notification["id"].stringValue]]
                Utility().displayAlert(self,title: title, message:notification["description"].stringValue, performSegue:"showFeedback1")
            } else {
                if(notification["feedback"].stringValue == "1") {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "NotificationDetail", sender: self)
                    }
                } else {
                    Utility().displayAlert(self,title: title, message:notification["description"].stringValue, performSegue:"NotificationDetail")
                }
            }

        }
    }
    
    //Pagination
    func tableView(_ tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: IndexPath){
        let row = indexPath.row
        let lastRow = self.notifications.count - 1
        let pageLimit = (((self.countPage+1) * (self.stepPage)) - 1)  //prevision of the page limit based on step and countPage
        
        // 1) The last rown and is the last
        // 2) To avoid two calls in a short space from time, while the data is downloading
        if (row == lastRow) && (row == pageLimit)  {
            self.countPage += 1
            print("Loading Page \(self.countPage) from \(self.maxPage)")
            self.findNotifications()
        }
    }
    
    func findNotifications() {
        let userId = User().getField("id")
        let url = AppConfig.APP_URL+"/list_notifications/"+userId+"/"+String(self.stepPage)+"/?page="+String(self.countPage + 1)
        Request().get(url, successHandler: {(response) in self.loadNotifications(response)})
    }
    
    func loadNotifications(_ response: Data){
        let result = JSON(data: response)
        DispatchQueue.main.async {
            BProgressHUD.dismissHUD(0)
            for (_,subJson):(String, JSON) in result["data"] {
                let jsonObject: AnyObject = subJson.object
                self.notifications.add(jsonObject)
            }
            if self.notifications.count > 0{
                self.tableView.reloadData()
                BProgressHUD.dismissHUD(0)
            }else{
                BProgressHUD.dismissHUD(0)
                let msg = "No notifications found!"
                Utility().displayAlert(self,title: "Notification", message:msg, performSegue:"")
            }
        }
    }
    
    @IBAction func btnBack(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func seenNotificationRequest(_ notificationId:String) {
        let url = AppConfig.APP_URL+"/seen_notification/\(notificationId)"
        Request().get(url) { (response) -> Void in
            let val = UIApplication.shared.applicationIconBadgeNumber.description
            if let currentCount = Int(val) {
                if(currentCount > 0) {
                    UIApplication.shared.applicationIconBadgeNumber = currentCount - 1
                } else {
                    UIApplication.shared.applicationIconBadgeNumber = 0
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "NotificationDetail") {
            let view: NotificationDetailViewController = segue.destination as! NotificationDetailViewController
            view.showingId  = self.viewData["parent_id"].stringValue
        }
        if (segue.identifier == "ShowingRequestDetail") {
            let view: ShowingRequestViewController = segue.destination as! ShowingRequestViewController
            view.showingId  = self.viewData["parent_id"].stringValue
        }
        if (segue.identifier == "showFeedback1") {
            let view: FeedBack1ViewController = segue.destination as! FeedBack1ViewController
            view.viewData  = self.viewData
        }
    }
    
}
