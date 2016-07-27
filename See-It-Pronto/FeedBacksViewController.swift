//
//  FeedBacksViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 3/28/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class FeedBacksViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var countPage = 0    //number of current page
    var stepPage  = 20   //number of records by page
    var maxRow    = 0    //maximum limit records of your parse table class
    var maxPage   = 0    //maximum page
    var feedbacks:NSMutableArray! = NSMutableArray()
    var viewData:JSON = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        BProgressHUD.showLoadingViewWithMessage("Loading")
        self.findFeedBacks()
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
        return feedbacks.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! FeedBacksTableViewCell
        let feedback = JSON(self.feedbacks[indexPath.row])
        cell.lblDescription.text = feedback["feedback_realtor_comment"].stringValue
        if(!feedback["user_rating_value"].stringValue.isEmpty) {
            cell.rating.image = UIImage(named: feedback["user_rating_value"].stringValue+"stars")
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let feedback = JSON(self.feedbacks[indexPath.row])
        Utility().displayAlert(self, title: "Feedback", message: feedback["feedback_realtor_comment"].stringValue, performSegue: "")
    }
    
    //Pagination
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
        let row = indexPath.row
        let lastRow = self.feedbacks.count - 1
        let pageLimit = (((self.countPage+1) * (self.stepPage)) - 1)  //prevision of the page limit based on step and countPage
        
        // 1) The last rown and is the last
        // 2) To avoid two calls in a short space from time, while the data is downloading
        if (row == lastRow) && (row == pageLimit)  {
            self.countPage++
            print("Loading Page \(self.countPage) from \(self.maxPage)")
            self.findFeedBacks()
        }
    }
    
    func findFeedBacks() {
        let url = AppConfig.APP_URL+"/my_feedbacks/\(User().getField("id"))/\(self.stepPage)/?page="+String(self.countPage + 1)
        Request().get(url, successHandler: {(response) in self.loadFeedBacks(response)})
    }
    
    func loadFeedBacks(let response: NSData){
        let result = JSON(data: response)
        dispatch_async(dispatch_get_main_queue()) {
            for (_,subJson):(String, JSON) in result["data"] {
                let jsonObject: AnyObject = subJson.object
                self.feedbacks.addObject(jsonObject)
            }
            self.tableView.reloadData()
            BProgressHUD.dismissHUD(0)
        }
    }


}
