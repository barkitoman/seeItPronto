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
    
    lazy var configuration : URLSessionConfiguration = {
        let config = URLSessionConfiguration.ephemeral
        config.allowsCellularAccess = false
        config.urlCache = nil
        return config
    }()
    
    lazy var downloader : MyDownloader = {
        return MyDownloader(configuration:self.configuration)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            BProgressHUD.showLoadingViewWithMessage("Loading...")
        }
        self.findListings()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if (navigationController?.topViewController != self) {
            navigationController?.isNavigationBarHidden = false
        }
        super.viewWillDisappear(animated)
    }
    
    @IBAction func btnBack(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myListings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PropertyViewedTableViewCell
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
    
    func showCell(_ cell:PropertyViewedTableViewCell, showing:JSON, indexPath: IndexPath){
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
    
    func imageCell(_ indexPath: IndexPath, img:UIImageView,response: Data) {
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
                let data = try! Data(contentsOf: url)
                //if photo is empty
                if data.count <= 116 {
                    let im = UIImage(named: "default_property_photo")
                    self!.models[showing["property_id"].stringValue]!.im = im
                }else {
                    let im = UIImage(data:data)
                    self!.models[showing["property_id"].stringValue]!.im = im
                }
                DispatchQueue.main.async {
                    self!.models[showing["property_id"].stringValue]!.reloaded = true
                    self!.tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAtIndexPath indexPath: IndexPath) -> [UITableViewRowAction]? {
        let seeItAgain = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "See It Again"){(UITableViewRowAction,NSIndexPath) -> Void in
            self.openPropertyDetailView(indexPath)
        }
        let comments = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Comments"){(UITableViewRowAction,NSIndexPath) -> Void in
            self.viewShowingComments(indexPath)
        }
        let viewDetails = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "View\nDetails"){(UITableViewRowAction,NSIndexPath) -> Void in
            let showing = JSON(self.myListings[indexPath.row])
            Utility().goPropertyDetails(self,propertyId: showing["property_id"].stringValue, PropertyClass: showing["property_class"].stringValue)
        }
        return [seeItAgain,comments,viewDetails]
    }
    
    func openPropertyDetailView(_ indexPath: IndexPath) {
        let showing = JSON(self.myListings[indexPath.row])
        Utility().goPropertyDetails(self,propertyId: showing["property_id"].stringValue, PropertyClass: showing["property_class"].stringValue)
    }
    
    func viewShowingComments(_ indexPath: IndexPath) {
        let showing  = JSON(self.myListings[indexPath.row])
        var comments = "Showing Comments:\n"+showing["feedback_showing_comment"].stringValue+"\n\n"
        comments     = comments+" Reviews for the agent:\n"+showing["feedback_realtor_comment"].stringValue
        Utility().displayAlert(self, title: "My comments", message: comments, performSegue: "")
    }
    
    func loadImage(_ img:UIImageView,response: Data) {
        let result = JSON(data: response)
        DispatchQueue.main.async {
            Utility().showPhoto(img, imgPath: result[0]["url"].stringValue)
        }
    }
    
    //Pagination
    func tableView(_ tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: IndexPath){
        let row = indexPath.row
        let lastRow = self.myListings.count - 1
        let pageLimit = (((self.countPage+1) * (self.stepPage)) - 1)  //prevision of the page limit based on step and countPage
        
        // 1) The last rown and is the last
        // 2) To avoid two calls in a short space from time, while the data is downloading
        if (row == lastRow) && (row == pageLimit)  {
            self.countPage += 1
            print("Loading Page \(self.countPage) from \(self.maxPage)")
            self.findListings()
        }
    }
    
    func findListings() {
        let url = AppConfig.APP_URL+"/properties_viewed/\(User().getField("id"))/\(self.stepPage)/?page="+String(self.countPage + 1)
        Request().get(url, successHandler: {(response) in self.loadListings(response)})
    }
    
    func loadListings(_ response: Data){
        let result = JSON(data: response)
        DispatchQueue.main.async {
            for (_,subJson):(String, JSON) in result["data"] {
                let jsonObject: AnyObject = subJson.object
                self.myListings.add(jsonObject)
            }
            if self.myListings.count > 0 {
                self.tableView.reloadData()
                BProgressHUD.dismissHUD(4)
            }else {
                BProgressHUD.dismissHUD(0)
                let msg = "No properties found!"
                Utility().displayAlert(self,title: "Notification", message:msg, performSegue:"")
            }
        }
    }
    
}
