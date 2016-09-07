//
//  PropertyListViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 4/8/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class PropertyListViewController: BaseViewController, UIWebViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,UITextViewDelegate   {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var tableView: UITableView!
    var countPage = 0   //number of current page
    var stepPage  = 0   //number of records by page
    var maxRow    = 0   //maximum limit records of your parse table class
    var maxPage   = 0   //maximum page
    var properties:NSMutableArray! = NSMutableArray()
    
    var manager: OneShotLocationManager?
    var latitude   = "0"
    var longintude = "0"
    var cache      = ImageLoadingWithCache()
    var model      = [Model]()
    var models     = [String:Model]()
    var count      = 0
    var propertyId:String    = ""
    var propertyClass:String = ""
    
    lazy var configuration : NSURLSessionConfiguration = {
        let config = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        config.allowsCellularAccess = false
        config.URLCache = nil
        return config
    }()
    
    lazy var downloader : MyDownloader = {
        return MyDownloader(configuration:self.configuration)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.selfDelegate()
        
        self.webView.hidden = true
        manager = OneShotLocationManager()
        manager!.fetchWithCompletion {location, error in
            // fetch location or an error
            if let loc = location {
                self.latitude   = (AppConfig.MODE == "PROD") ? "\(loc.coordinate.latitude)" : "26.189244"
                self.longintude = (AppConfig.MODE == "PROD") ? "\(loc.coordinate.longitude)": "-80.1824587"
                self.loadMap()
            } else if let _ = error {
                print("ERROR GETTING LOCATION")
                self.loadMap()
            }
            // destroy the object immediately to save memory
            self.manager = nil
        }
    }
    
    func selfDelegate() {
        self.webView.delegate = self;
    }
    
    func loadMap() {
        let url = AppConfig.APP_URL+"/get_current_location/\(User().getField("id"))?lat=\(self.latitude)&lon=\(self.longintude)"
        let requestURL = NSURL(string:url)
        let request = NSURLRequest(URL: requestURL!)
        self.webView.loadRequest(request)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        dispatch_async(dispatch_get_main_queue()) {
            BProgressHUD.showLoadingViewWithMessage("Loading...")
        }
        self.findProperties()
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
        //navigationController?.popViewControllerAnimated(true)
         self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnMenu(sender: AnyObject) {
        //self.textFieldShouldReturn(self.txtSearch)
        self.onSlideMenuButtonPressed(sender as! UIButton)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return properties.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell   = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PropertyListTableViewCell
        let property = JSON(self.properties[indexPath.row])
        var description = property["address"].stringValue+"\n"+Utility().formatCurrency(property["price"].stringValue)
        description = description+" \n"+property["bedrooms"].stringValue+" Bd / "+property["bathrooms"].stringValue+" Ba"
        if(!property["square_feed"].stringValue.isEmpty) {
            description = description+" / \(property["square_feed"].stringValue) Sq Ft"
        }
        cell.lblDescription.text = description
        cell.btnViewDetails.tag = indexPath.row
        cell.btnViewDetails.addTarget(self, action: "viewDetails:", forControlEvents: .TouchUpInside)
        if let _ = self.models[property["id"].stringValue] {
            self.showCell(cell, property: property, indexPath: indexPath)
        } else {
            cell.propertyImage.image = nil
            self.models[property["id"].stringValue] = Model()
            self.showCell(cell, property: property, indexPath: indexPath)
        }
        return cell
    }
    
    func showCell(cell:PropertyListTableViewCell, property:JSON,indexPath: NSIndexPath){
        // have we got a picture?
        if let im = self.models[property["id"].stringValue]!.im {
            cell.propertyImage.image = im
        } else {
            if self.models[property["id"].stringValue]!.task == nil &&  self.models[property["id"].stringValue]!.reloaded == false {
                // no task? start one!
                let url = AppConfig.APP_URL+"/real_state_property_basics/get_photos_property/"+property["id"].stringValue+"/1"
                Request().get(url, successHandler: {(response) in self.imageCell(indexPath, img:cell.propertyImage, response: response)})
            }
        }
    }
    
    func imageCell(indexPath: NSIndexPath, img:UIImageView,let response: NSData) {
        let property = JSON(self.properties[indexPath.row])
        let result = JSON(data: response)
        let url = AppConfig.APP_URL+"/"+result[0]["url"].stringValue
        self.models[property["id"].stringValue]!.task = self.downloader.download(url) {
            [weak self] url in // *
            if let _ = self?.models[property["id"].stringValue] {
                self!.models[property["id"].stringValue]!.task = nil
                if url == nil {
                    return
                }
                let data = NSData(contentsOfURL: url)!
                let im = UIImage(data:data)
                self!.models[property["id"].stringValue]!.im = im
                dispatch_async(dispatch_get_main_queue()) {
                    self!.models[property["id"].stringValue]!.reloaded = true
                    self!.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                }
            }
        }
    }
    
    @IBAction func viewDetails(sender:UIButton) {
        let property = JSON(self.properties[sender.tag])
        Utility().goPropertyDetails(self,propertyId: property["id"].stringValue, PropertyClass:property["class"].stringValue)
    }
    
    func findProperties() {
        var url = AppConfig.APP_URL+"/property_list/\(User().getField("id"))"
        url = self.propertiesUrlParams(url);
        Request().get(url, successHandler: {(response) in self.loadProperties(response)})
    }
    
    func propertiesUrlParams(var url:String)->String {
        url =  url+"?role=\(User().getField("role"))"
        url =  url+"&property=\(self.propertyId)"
        url =  url+"&type_property=\(SearchConfig().getField("type_property"))"
        url =  url+"&area=\(SearchConfig().getField("area"))"
        url =  url+"&beds=\(SearchConfig().getField("beds"))"
        url =  url+"&baths=\(SearchConfig().getField("baths"))"
        url =  url+"&pool=\(SearchConfig().getField("pool"))"
        url =  url+"&price_range_less=\(SearchConfig().getField("price_range_less"))"
        url =  url+"&price_range_higher=\(SearchConfig().getField("price_range_higher"))"
        url =  url+"&fast_search=1"
        if(self.propertyClass != "") {
            url =  url+"&property_class=\(self.propertyClass)"
        } else {
            url =  url+"&property_class=\(SearchConfig().getField("property_class"))"
        }
        self.propertyId = ""
        self.propertyClass = ""
        return url;
    }
    
    func loadProperties(let response: NSData){
        let result = JSON(data: response)
        self.properties.removeAllObjects()
        dispatch_async(dispatch_get_main_queue()) {
            for (_,subJson):(String, JSON) in result {
                if(!subJson["id"].stringValue.isEmpty) {
                    let jsonObject: AnyObject = subJson.object
                    self.properties.addObject(jsonObject)
                }
            }
            if self.properties.count > 0 {
                self.tableView.reloadData()
                BProgressHUD.dismissHUD(3)
            }else{
                BProgressHUD.dismissHUD(0)
                let msg = "No Properties Found"
                Utility().displayAlert(self,title: "Notification", message:msg, performSegue:"")
            }
            
        }
    }
    
    var pickSeletion: String = "Unfiltered"
    
    @IBAction func filter(sender: AnyObject) {
        let pickerView = CustomPickerDialog.init()
        var arrayDataSource:[String] = ["Unfiltered","Higher Price", "Lower Price",  "Greater nº of Bedrooms" ,"Fewer nº of Bedrooms","Greater nº of Bathrooms" ,"Fewer nº of Bathrooms","More Sq.Ft." ,"Less Sq.Ft."]
        let array_name:[String] = ["-", "price","price", "bedrooms", "bedrooms", "bathrooms", "bathrooms", "square_feed", "square_feed"]
        let array_asc_desc:[String] = ["-","desc","asc","desc","asc","desc", "asc","desc","asc"]
        
        pickerView.setDataSource(arrayDataSource)
        pickerView.selectValue(self.pickSeletion)
       
        pickerView.showDialog("Filter property", doneButtonTitle: "Done", cancelButtonTitle: "Cancel")
        { (result) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                BProgressHUD.showLoadingViewWithMessage("Loading...")
            }
            self.pickSeletion = result
            var url:String = ""
            if result == "Unfiltered" {
                var url = AppConfig.APP_URL+"/property_list/\(User().getField("id"))"
                url     = self.propertiesUrlParams(url)
            }else {
                for var i=0; i < array_name.count; i++ {
                    if arrayDataSource[i] == result {
                      url = AppConfig.APP_URL+"/map_properties_list/\(User().getField("id"))"
                      url = self.propertiesUrlParams(url)
                      url = url+"&orderby=\(array_name[i])&order=\(array_asc_desc[i])"
                    }
                }
            }
            Request().get(url, successHandler: {(response) in self.loadProperties(response)})
        }
    }
}
