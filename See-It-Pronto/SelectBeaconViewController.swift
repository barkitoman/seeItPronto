//
//  SelectBeaconViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 5/23/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class SelectBeaconViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var countPage = 0   //number of current page
    var stepPage  = 0   //number of records by page
    var maxRow    = 0   //maximum limit records of your parse table class
    var maxPage   = 0   //maximum page
    var beacons:NSMutableArray! = NSMutableArray()
    weak var addBeaconVC : AddBeaconViewController?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.findBeacons()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {});
    }

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beacons.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell   = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        let beacon = JSON(self.beacons[indexPath.row])
        cell.textLabel?.text = beacon["beacon_id"].stringValue
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let beacon = JSON(self.beacons[indexPath.row])
        addBeaconVC!.beaconId = beacon["id"].stringValue
        addBeaconVC!.beaconName = beacon["beacon_id"].stringValue
        addBeaconVC!.reloadButtonTitle()
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    //Pagination
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
        let row = indexPath.row
        let lastRow = self.beacons.count - 1
        let pageLimit = (((self.countPage+1) * (self.stepPage)) - 1)  //prevision of the page limit based on step and countPage
        
        // 1) The last rown and is the last
        // 2) To avoid two calls in a short space from time, while the data is downloading
        if (row == lastRow) && (row == pageLimit)  {
            self.countPage++
            print("Loading Page \(self.countPage) from \(self.maxPage)")
            self.findBeacons()
        }
    }
    
    func findBeacons() {
        let url = AppConfig.APP_URL+"/list_beacons/"+User().getField("id")
        Request().get(url, successHandler: {(response) in self.loadBeacons(response)})
    }
    
    func loadBeacons(let response: NSData) {
        let result = JSON(data: response)
        dispatch_async(dispatch_get_main_queue()) {
            for (_,subJson):(String, JSON) in result {
                let jsonObject: AnyObject = subJson.object
                self.beacons.addObject(jsonObject)
            }
            self.tableView.reloadData()
        }
    }

}
