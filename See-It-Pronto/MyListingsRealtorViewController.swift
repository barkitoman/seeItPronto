//
//  ListPropertiesViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/4/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class MyListingsRealtorViewController: UIViewController, UIPopoverPresentationControllerDelegate, UITableViewDelegate{

    @IBOutlet weak var tableView: UITableView!
    var countPage = 0    //number of current page
    var stepPage  = 20   //number of records by page
    var maxRow    = 0    //maximum limit records of your parse table class
    var maxPage   = 0    //maximum page
    var myListings:NSMutableArray! = NSMutableArray()
    var viewData:JSON = []
    var propertyId:String = ""
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
        self.tableView.delegate = self
        self.findListings()
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MyListingsRealtorTableViewCell
        
        cell.selectedBackgroundView!.layer.borderColor = UIColor.yellow.cgColor
        cell.selectedBackgroundView!.layer.borderWidth = 3
        cell.selectedBackgroundView!.backgroundColor = UIColor(white: 0.8, alpha: 0.9)
        
        var listing = JSON(self.myListings[indexPath.row])
        var description = listing["property"]["address"].stringValue+"\n"+Utility().formatCurrency(listing["property"]["price"].stringValue)
        description = description+" "+listing["property"]["bedrooms"].stringValue+" Bd / "+listing["property"]["bathrooms"].stringValue+" Ba "
        cell.lblInformation.text = description
        cell.btnBeacon.tag = indexPath.row
        cell.btnBeacon.addTarget(self, action: #selector(MyListingsRealtorViewController.openBeaconView(_:)), for: .touchUpInside)
        
        cell.btnEdit.tag = indexPath.row
        cell.btnEdit.addTarget(self, action: #selector(MyListingsRealtorViewController.openEditView(_:)), for: .touchUpInside)
        cell.swBeacon.isOn = false
        if(listing["state_beacon"].int == 1) {
            cell.swBeacon.isOn = true
        }
        cell.swBeacon.tag = Int(listing["property"]["id"].stringValue)!
        cell.swBeacon.addTarget(self, action: #selector(MyListingsRealtorViewController.turnBeaconOnOff(_:)), for: .touchUpInside)
        let property = listing["property"]
        
        if let _ = self.models[property["id"].stringValue] {
            self.showCell(cell, property: property, indexPath: indexPath)
        } else {
            cell.PropertyImage.image = nil
            self.models[property["id"].stringValue] = Model()
            self.showCell(cell, property: property, indexPath: indexPath)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Cancel"){(UITableViewRowAction,NSIndexPath) -> Void in
            self.cancelShowingRequest(indexPath)
        }
        return [delete]
    }
    
    func cancelShowingRequest(_ indexPath:IndexPath){
        DispatchQueue.main.async {
            let alertController = UIAlertController(title:"Confirmation", message: "Do you really want to delete this property listing?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) {
                UIAlertAction in
            
                var listing = JSON(self.myListings[indexPath.row])
                self.myListings.removeObject(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                let url = AppConfig.APP_URL+"/realtor_properties/"+listing["id"].stringValue
                Request().delete(url,params:"", successHandler: {(response) in })
            }
            let noAction = UIAlertAction(title: "No", style: UIAlertActionStyle.default) {
                UIAlertAction in
            
            }
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func showCell(_ cell:MyListingsRealtorTableViewCell, property:JSON,indexPath: IndexPath){
        // have we got a picture?
        if let im = self.models[property["id"].stringValue]!.im {
            cell.PropertyImage.image = im
        } else {
            if self.models[property["id"].stringValue]!.task == nil &&  self.models[property["id"].stringValue]!.reloaded == false {
                // no task? start one!
                let url = AppConfig.APP_URL+"/real_state_property_basics/get_photos_property/"+property["id"].stringValue+"/1"
                Request().get(url, successHandler: {(response) in self.imageCell(indexPath, img:cell.PropertyImage, response: response)})
            }
        }
    }
    
    func imageCell(_ indexPath: IndexPath, img:UIImageView,response: Data) {
        var listing = JSON(self.myListings[indexPath.row])
        let property = listing["property"]
        let result = JSON(data: response)
        let url = AppConfig.APP_URL+"/"+result[0]["url"].stringValue
        self.models[property["id"].stringValue]!.task = self.downloader.download(url) {
            [weak self] url in // *
            if let _ = self?.models[property["id"].stringValue] {
                self!.models[property["id"].stringValue]!.task = nil
                if url == nil {
                    return
                }
                let data = try! Data(contentsOf: url)
                let im = UIImage(data:data)
                self!.models[property["id"].stringValue]!.im = im
                DispatchQueue.main.async {
                    self!.models[property["id"].stringValue]!.reloaded = true
                    self!.tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
        }
    }
    
    @IBAction func openBeaconView(_ sender:UIButton) {
        let listing = JSON(self.myListings[sender.tag])
        self.viewData = listing
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "MyListingToAddBeacon", sender: self)
        }
    }
    
    @IBAction func openEditView(_ sender:UIButton) {
        let listing = JSON(self.myListings[sender.tag])
        self.viewData = listing
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "MyListingToEditListng", sender: self)
        }
    }
    
    @IBAction func turnBeaconOnOff(_ sender:UISwitch) {
        self.propertyId = String(sender.tag)
        let url = AppConfig.APP_URL+"/turn_beacon_on_off/"+User().getField("id")+"/"+self.propertyId+"/"+Utility().switchValue(sender, onValue: "1", offValue: "0")
        Request().get(url, successHandler: {(response) in self.afterTurnOnOffBeacon(response, sw: sender)})
    }
    
    func afterTurnOnOffBeacon(_ response: Data, sw:UISwitch) {
        let result = JSON(data: response)
        if(result["result"].bool == false ) {
            var msg = "Error saving, please try later"
            if(result["msg"].stringValue != "") {
                DispatchQueue.main.async {
                    sw.isOn = false
                }
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }
    
    //Pagination
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath){
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
        let url = AppConfig.APP_URL+"/my_listings/\(User().getField("id"))/\(self.stepPage)/?page="+String(self.countPage + 1)
        Request().get(url, successHandler: {(response) in self.loadListings(response)})
    }
    
    func loadListings(_ response: Data){
        let result = JSON(data: response)
        DispatchQueue.main.async {
            for (_,subJson):(String, JSON) in result{
                if(!subJson["property"]["id"].stringValue.isEmpty) {
                    let jsonObject: AnyObject = subJson.object
                    self.myListings.add(jsonObject)
                }
            }
            if self.myListings.count > 0 {
                self.tableView.reloadData()
                BProgressHUD.dismissHUD(5)
            }else{
                BProgressHUD.dismissHUD(0)
                let msg = "No properties found!"
                Utility().displayAlert(self,title: "Notification", message:msg, performSegue:"")
                
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "MyListingToAddBeacon") {
            let view: AddBeaconViewController = segue.destination as! AddBeaconViewController
            view.viewData = self.viewData
            
        }else if (segue.identifier == "MyListingToEditListng") {
            let view: ListingDetailsViewController = segue.destination as! ListingDetailsViewController
            view.viewData = self.viewData
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}
