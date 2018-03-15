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
    var canSelectBeacon  = false
    weak var addBeaconVC : AddBeaconViewController?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.findBeacons()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnBack(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: {});
    }

    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beacons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell   = self.tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        let beacon = JSON(self.beacons[indexPath.row])
        cell.textLabel?.text = beacon["beacon_id"].stringValue
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        if(canSelectBeacon == true) {
            let beacon = JSON(self.beacons[indexPath.row])
                addBeaconVC!.beaconId = beacon["beacon_id"].stringValue
            addBeaconVC!.reloadButtonTitle()
            self.dismiss(animated: true, completion: {});
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAtIndexPath indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete"){
            (UITableViewRowAction,NSIndexPath) -> Void in
            self.deleteBeacon(indexPath)
        }
        return [delete]
    }
    
    func deleteBeacon(_ indexPath: IndexPath) {
        let beacon = JSON(self.beacons[indexPath.row])
        self.beacons.removeObject(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        let url = AppConfig.APP_URL+"/destroy_beacon/\(beacon["id"].stringValue)/\(User().getField("id"))"
        Request().delete(url, params: "", successHandler: {(response) in })
    }
    
    //Pagination
    func tableView(_ tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: IndexPath){
        let row = indexPath.row
        let lastRow = self.beacons.count - 1
        let pageLimit = (((self.countPage+1) * (self.stepPage)) - 1)  //prevision of the page limit based on step and countPage
        
        // 1) The last rown and is the last
        // 2) To avoid two calls in a short space from time, while the data is downloading
        if (row == lastRow) && (row == pageLimit)  {
            self.countPage += 1
            print("Loading Page \(self.countPage) from \(self.maxPage)")
            self.findBeacons()
        }
    }
    
    func findBeacons() {
        let url = AppConfig.APP_URL+"/list_beacons/"+User().getField("id")
        Request().get(url, successHandler: {(response) in self.loadBeacons(response)})
    }
    
    func loadBeacons(_ response: Data) {
        let result = JSON(data: response)
        DispatchQueue.main.async {
        for (_,subJson):(String, JSON) in result["data"] {
                let jsonObject: AnyObject = subJson.object
                self.beacons.add(jsonObject)
            }
            if self.beacons.count > 0 {
                self.tableView.reloadData()
            }else{
                let msg = "No Beacons Found"
                Utility().displayAlert(self,title: "Notification", message:msg, performSegue:"")
            }
        }
    }

}
