//
//  SeeItNowViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/5/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class SeeItNowViewController: UIViewController {

    var viewData:JSON = []
    
    @IBOutlet weak var propertyPhoto: UIImageView!
    @IBOutlet weak var lblPropertyAddress: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var countPage = 0    //number of current page
    var stepPage  = 5   //number of records by page
    var maxRow    = 0    //maximum limit records of your parse table class
    var maxPage   = 0    //maximum page
    var realtors:NSMutableArray! = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadPropertyData()
        self.findPropertyRealtors()
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func btnBack(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func loadPropertyData(){
        let image = Property().getField("image")
        self.lblPropertyAddress.text = Property().getField("address")
        if(!image.isEmpty) {
            Utility().showPhoto(self.propertyPhoto, imgPath: image)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return realtors.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell    = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! SeeitNowTableViewCell
        let realtor = JSON(self.realtors[indexPath.row])
        let name    = realtor["first_name"].stringValue+" "+realtor["last_name"].stringValue
        cell.lblCompany.text     = realtor["brokerage"].stringValue
        cell.lblName.text        = name
        cell.lblShowingRate.text = (!realtor["showing_rate"].stringValue.isEmpty) ? "$"+realtor["showing_rate"].stringValue  : ""
        cell.lblDistance.text    = (!realtor["travel_range"].stringValue.isEmpty) ? realtor["travel_range"].stringValue+"mi" : ""
        cell.lblRating.text      = (!realtor["rating"].stringValue.isEmpty) ? realtor["rating"].stringValue+" of 5" : ""
        cell.btnViewDetails.tag  = indexPath.row
        cell.btnViewDetails.addTarget(self, action: "openPropertyAction:", forControlEvents: .TouchUpInside)
        let image = (!realtor["image"].stringValue.isEmpty) ? realtor["image"].stringValue : realtor["url_image"].stringValue
        if(!image.isEmpty) {
            Utility().showPhoto(cell.photo, imgPath: image)
        }
        if(!realtor["rating"].stringValue.isEmpty) {
            cell.ratingImage.image = UIImage(named: realtor["rating"].stringValue+"stars")
        }
        return cell
    }
    
    //Pagination
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
        let row = indexPath.row
        let lastRow = self.realtors.count - 1
        let pageLimit = (((self.countPage+1) * (self.stepPage)) - 1)  //prevision of the page limit based on step and countPage
        
        // 1) The last rown and is the last
        // 2) To avoid two calls in a short space from time, while the data is downloading
        if (row == lastRow) && (row == pageLimit)  {
            self.countPage++
            print("Loading Page \(self.countPage) from \(self.maxPage)")
            self.findPropertyRealtors()
        }
    }
    
    @IBAction func openPropertyAction(sender:UIButton) {
        let realtor = JSON(self.realtors[sender.tag])
        PropertyRealtor().saveIfExists(realtor)
        let propertyTypeAction = PropertyAction().getField("type")
        if(propertyTypeAction == "see_it_later") {
            //open view for see it later process
            self.performSegueWithIdentifier("seeItNowConfirmation", sender: self)
        } else {
            //open view for see it pronto process
            self.performSegueWithIdentifier("SeeItNowAgentConfirmation", sender: self)
        }
        
    }

    func findPropertyRealtors() {
        let propertyId = Property().getField("id")
        let url = AppConfig.APP_URL+"/real_state_property_basics/get_property_realtors/"+propertyId+"/"+String(self.stepPage)+"/?page="+String(self.countPage + 1)
        Request().get(url, successHandler: {(response) in self.loadRealtors(response)})
    }
    
    func loadRealtors(let response: NSData){
        let result = JSON(data: response)
        dispatch_async(dispatch_get_main_queue()) {
            for (_,subJson):(String, JSON) in result {
                let jsonObject: AnyObject = subJson.object
                self.realtors.addObject(jsonObject)
            }
            self.tableView.reloadData()
        }
    }
    
}
