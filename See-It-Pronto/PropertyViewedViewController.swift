//
//  PropertyViewedViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 8/8/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

import UIKit

class PropertyViewedViewController: UIViewController {
    
    
    
    @IBOutlet weak var tableView: UITableView!
    var countPage = 0    //number of current page
    var stepPage  = 6   //number of records by page
    var maxRow    = 0    //maximum limit records of your parse table class
    var maxPage   = 0    //maximum page
    var myListings:NSMutableArray! = NSMutableArray()
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
        BProgressHUD.showLoadingViewWithMessage("Loading")
        self.findListings()
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
        return myListings.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PropertyViewedTableViewCell
        let showing = JSON(self.myListings[indexPath.row])
        let address = showing["property"][0]["address"].stringValue
        let price   = (showing["property"][0]["price"].stringValue.isEmpty) ? showing["property_price"].stringValue : showing["property"][0]["price"].stringValue
        
        cell.lblAddress.text  = (address.isEmpty) ? showing["property_address"].stringValue  : address
        cell.lblPrice.text    = Utility().formatCurrency(price)
        cell.lblNiceDate.text = showing["nice_date"].stringValue
        if(!showing["home_rating_value"].stringValue.isEmpty) {
            cell.propertyRating.image = UIImage(named: showing["home_rating_value"].stringValue+"stars")
        }
        if(!showing["user_rating_value"].stringValue.isEmpty) {
            cell.agentRating.image = UIImage(named: showing["user_rating_value"].stringValue+"stars")
        }
        if let _ = self.models[showing["property_id"].stringValue] {
            self.showCell(cell, showing: showing, indexPath: indexPath)
        } else {
            cell.propertyImage.image = nil
            self.models[showing["property_id"].stringValue] = Model()
            self.showCell(cell, showing: showing, indexPath: indexPath)
        }
        return cell
    }
    
    func showCell(cell:PropertyViewedTableViewCell, showing:JSON, indexPath: NSIndexPath){
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
        let seeItAgain = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "See It Again"){(UITableViewRowAction,NSIndexPath) -> Void in
            self.openPropertyDetailView(indexPath)
        }
        let comments = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Comments"){(UITableViewRowAction,NSIndexPath) -> Void in
            self.viewShowingComments(indexPath)
        }
        let viewDetails = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "View\nDetails"){(UITableViewRowAction,NSIndexPath) -> Void in
            let showing = JSON(self.myListings[indexPath.row])
            Utility().goPropertyDetails(self,propertyId: showing["property_id"].stringValue, PropertyClass: showing["property_class"].stringValue)
        }
        return [seeItAgain,comments,viewDetails]
    }
    
    func openPropertyDetailView(indexPath: NSIndexPath) {
        let showing = JSON(self.myListings[indexPath.row])
        Utility().goPropertyDetails(self,propertyId: showing["property_id"].stringValue, PropertyClass: showing["property_class"].stringValue)
    }
    
    func viewShowingComments(indexPath: NSIndexPath) {
        let showing  = JSON(self.myListings[indexPath.row])
        var comments = "Showing Comments:\n"+showing["feedback_showing_comment"].stringValue+"\n\n"
        comments     = comments+" Reviews for the agent:\n"+showing["feedback_realtor_comment"].stringValue
        Utility().displayAlert(self, title: "My comments", message: comments, performSegue: "")
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
        let url = AppConfig.APP_URL+"/properties_viewed/\(User().getField("id"))/\(self.stepPage)/?page="+String(self.countPage + 1)
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
            }else {
                BProgressHUD.dismissHUD(0)
                let msg = "¡No properties found!"
                Utility().displayAlert(self,title: "Notification", message:msg, performSegue:"")
            }
        }
    }
    
}
