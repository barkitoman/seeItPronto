//
//  PropertyListViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 4/8/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class PropertyListViewController: UIViewController, UIWebViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,UITextViewDelegate  {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var tableView: UITableView!
    var countPage = 0   //number of current page
    var stepPage  = 6   //number of records by page
    var maxRow    = 0   //maximum limit records of your parse table class
    var maxPage   = 0   //maximum page
    var properties:NSMutableArray! = NSMutableArray()
    
    var manager: OneShotLocationManager?
    var latitude   = "0"
    var longintude = "0"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selfDelegate()
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
        print(url)
        let requestURL = NSURL(string:url)
        let request = NSURLRequest(URL: requestURL!)
        self.webView.loadRequest(request)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        print("cargado correctamente...")
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
        navigationController?.popViewControllerAnimated(true)
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
        let url = AppConfig.APP_URL+"/real_state_property_basics/get_photos_property/"+property["id"].stringValue+"/1"
        if cell.propertyImage.image == nil {
            Request().get(url, successHandler: {(response) in self.loadImage(cell.propertyImage, response: response)})
        }
        if(!property["id"].stringValue.isEmpty) {
            cell.btnViewDetails.tag = Int(property["id"].stringValue)!
            cell.btnViewDetails.addTarget(self, action: "viewDetails:", forControlEvents: .TouchUpInside)
        }
        return cell
    }
    
    @IBAction func viewDetails(sender:UIButton) {
        let propertyId = String(sender.tag)
        let saveData: JSON =  ["id":propertyId]
        Property().saveIfExists(saveData)
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc : PropertyDetailsViewController = mainStoryboard.instantiateViewControllerWithIdentifier("PropertyDetailsViewController") as! PropertyDetailsViewController
        self.navigationController?.showViewController(vc, sender: nil)
        
    }
    
    func loadImage(img:UIImageView,let response: NSData) {
        let result = JSON(data: response)
        dispatch_async(dispatch_get_main_queue()) {
            Utility().showPhoto(img, imgPath: result[0]["url"].stringValue)
        }
    }
    
    //Pagination
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
        let row = indexPath.row
        let lastRow = self.properties.count - 1
        let pageLimit = (((self.countPage+1) * (self.stepPage)) - 1)  //prevision of the page limit based on step and countPage
        
        // 1) The last rown and is the last
        // 2) To avoid two calls in a short space from time, while the data is downloading
        if (row == lastRow) && (row == pageLimit)  {
            self.countPage++
            print("Loading Page \(self.countPage) from \(self.maxPage)")
            self.findProperties()
        }
    }
    
    func findProperties() {
        let url = AppConfig.APP_URL+"/property_list/\(User().getField("id"))"
        Request().get(url, successHandler: {(response) in self.loadProperties(response)})
    }
    
    func loadProperties(let response: NSData){
        let result = JSON(data: response)
        dispatch_async(dispatch_get_main_queue()) {
            for (_,subJson):(String, JSON) in result {
                let jsonObject: AnyObject = subJson.object
                self.properties.addObject(jsonObject)
            }
            self.tableView.reloadData()
        }
    }

    
}
