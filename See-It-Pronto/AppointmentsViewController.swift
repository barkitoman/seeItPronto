//
//  AppointmentsViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 3/14/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class AppointmentsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var countPage = 0    //number of current page
    var stepPage  = 20   //number of records by page
    var maxRow    = 0    //maximum limit records of your parse table class
    var maxPage   = 0    //maximum page
    var appoiments:NSMutableArray! = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.findAppoiments()
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
        return appoiments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! AppointmentsTableViewCell
        let appoiment      = JSON(self.appoiments[indexPath.row])
        cell.address.text  = appoiment["property"][0]["address"].stringValue
        cell.lblPrice.text = Utility().formatCurrency(appoiment["property"][0]["price"].stringValue)
        let state = appoiment["showing_status"].stringValue
        cell.lblState.text = self.getState(state)
        cell.niceDate.text = appoiment["nice_date"].stringValue
        let url = AppConfig.APP_URL+"/real_state_property_basics/get_photos_property/"+appoiment["property"][0]["id"].stringValue+"/1"
        if cell.propertyImage.image == nil {
            Request().get(url, successHandler: {(response) in self.loadImage(cell.propertyImage, response: response)})
        }
        return cell
    }
    
    func loadImage(img:UIImageView,let response: NSData) {
        let result = JSON(data: response)
        dispatch_async(dispatch_get_main_queue()) {
           Utility().showPhoto(img, imgPath: result[0]["url"].stringValue)
        }
    }
    
    func getState(state:String)->String {
        var out = ""
        if(state == "0") {
            out = "Pending"
        } else if(state == "1") {
            out = "Accepted"
        } else if(state == "2") {
            out = "Rejected"
        } else if(state == "3") {
            out = "Completed"
        } else if(state == "4") {
            out = "Cancelled"
        }
        return out
    }
    
    //Pagination
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
        let row = indexPath.row
        let lastRow = self.appoiments.count - 1
        let pageLimit = (((self.countPage+1) * (self.stepPage)) - 1)  //prevision of the page limit based on step and countPage
        
        // 1) The last rown and is the last
        // 2) To avoid two calls in a short space from time, while the data is downloading
        if (row == lastRow) && (row == pageLimit)  {
            self.countPage++
            print("Loading Page \(self.countPage) from \(self.maxPage)")
            self.findAppoiments()
        }
    }
    
    func findAppoiments() {
        let userId = User().getField("id")
        let role   = User().getField("role")
        let url    = AppConfig.APP_URL+"/list_showings/\(userId)/\(role)/"+String(self.stepPage)+"/?page="+String(self.countPage + 1)
        Request().get(url, successHandler: {(response) in self.loadAppoiments(response)})
    }
    
    func loadAppoiments(let response: NSData){
        let result = JSON(data: response)
        dispatch_async(dispatch_get_main_queue()) {
            for (_,subJson):(String, JSON) in result["data"] {
                let jsonObject: AnyObject = subJson.object
                self.appoiments.addObject(jsonObject)
            }
            self.tableView.reloadData()
        }
    }

}
