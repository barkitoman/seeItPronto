//
//  ListBuyersViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 2/22/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class ListBuyersViewController: UIViewController {

    var viewData:JSON = []
    @IBOutlet weak var tableView: UITableView!
    var countPage = 0    //number of current page
    var stepPage  = 6   //number of records by page
    var maxRow    = 0    //maximum limit records of your parse table class
    var maxPage   = 0    //maximum page
    var buyers:NSMutableArray! = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.findBuyers()
    BProgressHUD.showLoadingViewWithMessage("Loading")
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
        return buyers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell   = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ListBuyersTableViewCell
        let buyer  = JSON(self.buyers[indexPath.row])
        let name   = buyer["first_name"].stringValue+" "+buyer["last_name"].stringValue
        cell.lblName.text = name
        if(!buyer["url_image"].stringValue.isEmpty) {
            cell.photo.image = nil
            Utility().showPhoto(cell.photo, imgPath: buyer["url_image"].stringValue)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.viewData = JSON(self.buyers[indexPath.row])
        self.performSegueWithIdentifier("showBuyerProfile", sender: self)
    }
    
    //Pagination
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
        let row = indexPath.row
        let lastRow = self.buyers.count - 1
        let pageLimit = (((self.countPage+1) * (self.stepPage)) - 1)  //prevision of the page limit based on step and countPage
        
        // 1) The last rown and is the last
        // 2) To avoid two calls in a short space from time, while the data is downloading
        if (row == lastRow) && (row == pageLimit)  {
            self.countPage++
            print("Loading Page \(self.countPage) from \(self.maxPage)")
            self.findBuyers()
        }
    }
    
    func findBuyers() {
        let url = AppConfig.APP_URL+"/list_realtor_buyers/\(User().getField("id"))/"+String(self.stepPage)+"/?page="+String(self.countPage + 1)
        Request().get(url, successHandler: {(response) in self.loadBuyers(response)})
    }
    
    func loadBuyers(let response: NSData){
        let result = JSON(data: response)
        dispatch_async(dispatch_get_main_queue()) {
            for (_,subJson):(String, JSON) in result["data"] {
                let jsonObject: AnyObject = subJson.object
                self.buyers.addObject(jsonObject)
            }
            if(self.buyers.count == 0 && self.countPage == 0) {
                Utility().displayAlertBack(self, title: "Message", message: "There are no buyers to show")
            }
            self.tableView.reloadData()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showBuyerProfile") {
            let view: BuyerProfileViewController = segue.destinationViewController as! BuyerProfileViewController
            view.viewData  = self.viewData
        }
    }

}
