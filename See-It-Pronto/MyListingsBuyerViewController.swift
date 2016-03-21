//
//  MyListingsBuyerViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 3/21/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class MyListingsBuyerViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var countPage = 0    //number of current page
    var stepPage  = 20   //number of records by page
    var maxRow    = 0    //maximum limit records of your parse table class
    var maxPage   = 0    //maximum page
    var myListings:NSMutableArray! = NSMutableArray()
    var viewData:JSON = []
    var propertyId:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.findListings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @IBAction func btnSearchAgain(sender: AnyObject) {
        Utility().goHome(self)
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myListings.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! MyListingsBuyerTableViewCell
        var listing = JSON(self.myListings[indexPath.row])
        var description = listing["address"].stringValue+" $"+listing["price"].stringValue
        description = description+" "+listing["bedrooms"].stringValue+"Br / "+listing["bathrooms"].stringValue+"Ba"
        cell.lblDescription.text = description
        if(!listing["image"].stringValue.isEmpty) {
            Utility().showPhoto(cell.imageProperty, imgPath: listing["image"].stringValue)
        }
        return cell
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
        let url = AppConfig.APP_URL+"/my_listings/\(User().getField("id"))/\(self.stepPage)/\(User().getField("mls_id"))/?page="+String(self.countPage + 1)
        Request().get(url, successHandler: {(response) in self.loadListings(response)})
    }
    
    func loadListings(let response: NSData){
        let result = JSON(data: response)
        dispatch_async(dispatch_get_main_queue()) {
            for (_,subJson):(String, JSON) in result {
                let jsonObject: AnyObject = subJson.object
                self.myListings.addObject(jsonObject)
            }
            self.tableView.reloadData()
        }
    }

}
