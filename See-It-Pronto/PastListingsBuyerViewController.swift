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
        if(!showing["property"][0]["id"].stringValue.isEmpty) {
            cell.lblAddress.text  = showing["property"][0]["address"].stringValue
            cell.lblPrice.text = Utility().formatCurrency(showing["property"][0]["price"].stringValue)
            cell.lblNiceDate.text = showing["nice_date"].stringValue
            let url = AppConfig.APP_URL+"/real_state_property_basics/get_photos_property/"+showing["property"][0]["id"].stringValue+"/1"
            if cell.propertyImage.image == nil {
                Request().get(url, successHandler: {(response) in self.loadImage(cell.propertyImage, response: response)})
            }
            if(!showing["showing_rating_value"].stringValue.isEmpty) {
                cell.showingRating.image = UIImage(named: showing["showing_rating_value"].stringValue+"stars")
            }
            if(!showing["home_rating_value"].stringValue.isEmpty) {
                cell.propertyRating.image = UIImage(named: showing["home_rating_value"].stringValue+"stars")
            }
            if(!showing["user_rating_value"].stringValue.isEmpty) {
                cell.agentRating.image = UIImage(named: showing["user_rating_value"].stringValue+"stars")
            }
        }
        return cell
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
                let jsonObject: AnyObject = subJson.object
                self.myListings.addObject(jsonObject)
            }
            self.tableView.reloadData()
        }
    }

}
