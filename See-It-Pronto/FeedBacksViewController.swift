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
        cell.lblAddress.text = feedback["property_address"].stringValue
        cell.lblDescription.text = feedback["feedback_property_comment"].stringValue
        cell.lblDate.text = feedback["nice_date"].stringValue
        var homeRating = "0"
        if(!feedback["home_rating_value"].stringValue.isEmpty) {
            homeRating = feedback["home_rating_value"].stringValue
        }
        cell.rating.image = UIImage(named: homeRating+"stars")
        if let _ = self.models[feedback["property_id"].stringValue] {
            self.showCell(cell, showing: feedback, indexPath: indexPath)
        } else {
            cell.imageFeedback.image = nil
            self.models[feedback["property_id"].stringValue] = Model()
            self.showCell(cell, showing: feedback, indexPath: indexPath)
        }
        return cell
    }
    
    func showCell(cell:FeedBacksTableViewCell, showing:JSON, indexPath: NSIndexPath){
        // have we got a picture?
        if let im = self.models[showing["property_id"].stringValue]!.im {
            cell.imageFeedback.image = im
        } else {
            if self.models[showing["property_id"].stringValue]!.task == nil &&  self.models[showing["property_id"].stringValue]!.reloaded == false {
                // no task? start one!
                let url = AppConfig.APP_URL+"/real_state_property_basics/get_photos_property/"+showing["property_id"].stringValue+"/1"
                Request().get(url, successHandler: {(response) in self.imageCell(indexPath, img:cell.imageFeedback, response: response)})
            }
        }
    }
    
    func imageCell(indexPath: NSIndexPath, img:UIImageView,let response: NSData) {
        let showing = JSON(self.feedbacks[indexPath.row])
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let feedback = JSON(self.feedbacks[indexPath.row])
        Utility().displayAlert(self, title: "Feedback", message: feedback["feedback_property_comment"].stringValue, performSegue: "")
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
        print(result)
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
