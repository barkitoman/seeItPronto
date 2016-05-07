//
//  PastListingsBuyerViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 3/30/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class PastListingsBuyerViewController: UIViewController {

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
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PastListingBuyerTableViewCell
        let showing = JSON(self.myListings[indexPath.row])
        let property = showing["property"][0]
        cell.lblAddress.text  = showing["property"][0]["address"].stringValue
        cell.lblPrice.text = Utility().formatCurrency(showing["property"][0]["price"].stringValue)
        cell.lblNiceDate.text = showing["nice_date"].stringValue
        if(!showing["showing_rating_value"].stringValue.isEmpty) {
            cell.showingRating.image = UIImage(named: showing["showing_rating_value"].stringValue+"stars")
        }
        if(!showing["home_rating_value"].stringValue.isEmpty) {
            cell.propertyRating.image = UIImage(named: showing["home_rating_value"].stringValue+"stars")
        }
        if(!showing["user_rating_value"].stringValue.isEmpty) {
            cell.agentRating.image = UIImage(named: showing["user_rating_value"].stringValue+"stars")
        }
        if let _ = self.models[property["id"].stringValue] {
            self.showCell(cell, property: property, indexPath: indexPath)
        } else {
            cell.propertyImage.image = nil
            self.models[property["id"].stringValue] = Model()
            self.showCell(cell, property: property, indexPath: indexPath)
        }
        return cell
    }
    
    func showCell(cell:PastListingBuyerTableViewCell, property:JSON,indexPath: NSIndexPath){
        // have we got a picture?
        if let im = self.models[property["id"].stringValue]!.im {
            cell.propertyImage.image = im
        } else {
            if self.models[property["id"].stringValue]!.task == nil &&  self.models[property["id"].stringValue]!.reloaded == false {
                // no task? start one!
                let url = AppConfig.APP_URL+"/real_state_property_basics/get_photos_property/"+property["id"].stringValue+"/1"
                Request().get(url, successHandler: {(response) in self.imageCell(indexPath, img:cell.propertyImage, response: response)})
            }
        }
    }
    
    func imageCell(indexPath: NSIndexPath, img:UIImageView,let response: NSData) {
        let showing = JSON(self.myListings[indexPath.row])
        let property = showing["property"][0]
        let result = JSON(data: response)
        let url = AppConfig.APP_URL+"/"+result[0]["url"].stringValue
        self.models[property["id"].stringValue]!.task = self.downloader.download(url) {
            [weak self] url in // *
            if let _ = self?.models[property["id"].stringValue] {
                self!.models[property["id"].stringValue]!.task = nil
                if url == nil {
                    return
                }
                let data = NSData(contentsOfURL: url)!
                let im = UIImage(data:data)
                self!.models[property["id"].stringValue]!.im = im
                dispatch_async(dispatch_get_main_queue()) {
                    self!.models[property["id"].stringValue]!.reloaded = true
                    self!.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let seeItAgain = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "See it again"){(UITableViewRowAction,NSIndexPath) -> Void in
            self.openPropertyDetailView(indexPath)
        }
        let comments = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Comments"){(UITableViewRowAction,NSIndexPath) -> Void in
            self.viewShowingComments(indexPath)
        }
        return [seeItAgain,comments]
    }
    
    func openPropertyDetailView(indexPath: NSIndexPath) {
        let showing = JSON(self.myListings[indexPath.row])
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let viewController : PropertyDetailsViewController = mainStoryboard.instantiateViewControllerWithIdentifier("PropertyDetailsViewController") as! PropertyDetailsViewController
        
        let saveData: JSON =  ["id":showing["property"][0]["id"].stringValue,"property_class":showing["property_class"].stringValue]
        Property().saveIfExists(saveData)
        self.navigationController?.showViewController(viewController, sender:self)
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
        let url = AppConfig.APP_URL+"/past_listing_buyer/\(User().getField("id"))/\(self.stepPage)/?page="+String(self.countPage + 1)
        Request().get(url, successHandler: {(response) in self.loadListings(response)})
    }
    
    func loadListings(let response: NSData){
        let result = JSON(data: response)
        dispatch_async(dispatch_get_main_queue()) {
            for (_,subJson):(String, JSON) in result["data"] {
                if(!subJson["property"][0]["id"].stringValue.isEmpty) {
                    let jsonObject: AnyObject = subJson.object
                    self.myListings.addObject(jsonObject)
                }
            }
            self.tableView.reloadData()
        }
    }

}
