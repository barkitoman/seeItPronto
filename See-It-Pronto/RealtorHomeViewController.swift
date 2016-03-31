//
//  RealtorHomeViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/5/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class RealtorHomeViewController: BaseViewController,UIWebViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate {

    var manager: OneShotLocationManager?
    var latitude   = "0"
    var longintude = "0"
    
    @IBOutlet weak var searchTextField: UITextField!
    var viewData:JSON    = []
    var propertyId:String = ""
    @IBOutlet weak var webView: UIWebView!
    
    let autocompleteTableView = UITableView(frame: CGRectMake(0,110,320,210), style: UITableViewStyle.Plain)
    var autocompleteUrls:NSMutableArray! = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selfDelegate()
        manager = OneShotLocationManager()
        manager!.fetchWithCompletion {location, error in
            // fetch location or an error
            if let loc = location {
                self.latitude   = (AppConfig.MODE == "PROD") ? "\(loc.coordinate.latitude)" : "26.187858"
                self.longintude = (AppConfig.MODE == "PROD") ? "\(loc.coordinate.longitude)": "-80.169112"
                self.loadMap()
            } else if let _ = error {
                print("ERROR GETTING LOCATION")
                self.loadMap()
            }
            // destroy the object immediately to save memory
            self.manager = nil
        }
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
    
    //selfDelegate, textFieldShouldReturn are functions for hide keyboard when press 'return' key
    func selfDelegate() {
        self.webView.delegate = self
        self.searchTextField.delegate = self
        
        //autocomple tableViewAutoSugges
        autocompleteTableView.delegate = self
        autocompleteTableView.dataSource = self
        autocompleteTableView.scrollEnabled = true
        autocompleteTableView.hidden = true
        self.view.addSubview(autocompleteTableView)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func loadMap() {
        let url = AppConfig.APP_URL+"/map/\(User().getField("id"))?lat=\(self.latitude)&lon=\(self.longintude)&role=\(User().getField("role"))&property=\(self.propertyId)"
        self.propertyId = ""
        let requestURL = NSURL(string:url)
        let request = NSURLRequest(URL: requestURL!)
        self.webView.loadRequest(request)
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.LinkClicked {
            let url:String = request.URL!.absoluteString
            if(url.containsString(AppConfig.APP_URL)) {
                let id = Utility().getIdFromUrl(url)
                let saveData: JSON =  ["id":id]
                Property().saveIfExists(saveData)
                self.performSegueWithIdentifier("RealtorHomePropertyDetails", sender: self)
            }
            return false
        }
        return true
    }
    
    @IBAction func btnMenu(sender: AnyObject) {
        self.onSlideMenuButtonPressed(sender as! UIButton)
    }
    
    @IBAction func btnSearch(sender: AnyObject) {
        self.onSlideSearchButtonPressed(sender as! UIButton)
    }
    
    //MARK autocomplete text
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
        let substring = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        if(substring.isEmpty) {
            autocompleteTableView.hidden = true
        }else {
            autocompleteTableView.hidden = false
            self.findproperties(substring)
        }
        return true
    }
    
    func findproperties(substring:String) {
        let urlString = "\(AppConfig.APP_URL)/real_state_property_basics/find_by_address/\(substring)"
        let url = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        Request().get(url!, successHandler: {(response) in self.loadProperties(response)})
    }
    
    func loadProperties(let response: NSData) {
        autocompleteUrls = NSMutableArray()
        dispatch_async(dispatch_get_main_queue()) {
            let properties = JSON(data: response)
            for (_,subJson):(String, JSON) in properties {
                let jsonObject: AnyObject = subJson.object
                self.autocompleteUrls.addObject(jsonObject)
            }
            self.autocompleteTableView.reloadData()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autocompleteUrls.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default , reuseIdentifier: "Cell")
        let item = JSON(self.autocompleteUrls[indexPath.row])
        cell.textLabel!.text = item["description"].stringValue
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell : UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        self.searchTextField.text = selectedCell.textLabel!.text
        self.autocompleteTableView.hidden = true
        let item = JSON(self.autocompleteUrls[indexPath.row])
        self.propertyId = item["id"].stringValue
        self.loadMap()
    }
    
}
