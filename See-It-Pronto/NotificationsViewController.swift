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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        if(role == "realtor" && (notification["type"] == "see_it_later" || notification["type"] == "see_it_pronto")) {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let viewController : ShowingRequestViewController = mainStoryboard.instantiateViewControllerWithIdentifier("ShowingRequestViewController") as! ShowingRequestViewController
            viewController.showingId = notification["parent_id"].stringValue
            self.navigationController?.showViewController(viewController, sender: nil)
        } else {
            var title = "Notificacion"
            if(!notification["description"].stringValue.isEmpty) {
                title = notification["title"].stringValue
            }
            Utility().displayAlert(self,title: title, message:notification["description"].stringValue, performSegue:"")
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
            for (_,subJson):(String, JSON) in result["data"] {
                let jsonObject: AnyObject = subJson.object
                self.notifications.addObject(jsonObject)
            }
            self.tableView.reloadData()
        }
    }
    
    @IBAction func btnBack(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
}
