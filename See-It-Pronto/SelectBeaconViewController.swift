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
    var propertyId:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    func findPropertyBeacon() {
        let url = AppConfig.APP_URL+"/get_property_beacons/"+User().getField("id")+"/"+self.propertyId
        Request().get(url, successHandler: {(response) in self.loadBeacons(response)})
    }
    
    func loadBeacons(let response: NSData) {
        let result = JSON(data: response)
        dispatch_async(dispatch_get_main_queue()) {
            for (_,subJson):(String, JSON) in result {
                let jsonObject: AnyObject = subJson.object
                self.beacons.addObject(jsonObject)
            }
        }
    }

}
