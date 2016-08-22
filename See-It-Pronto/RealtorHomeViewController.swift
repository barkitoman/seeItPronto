//
//  RealtorHomeViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/5/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class RealtorHomeViewController: BaseViewController,UIWebViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate, UIPopoverPresentationControllerDelegate {

    var manager: OneShotLocationManager?
    var latitude   = "0"
    var longintude = "0"
    
    @IBOutlet weak var searchTextField: UITextField!
    var viewData:JSON    = []
    var propertyId:String = ""
    var propertyClass:String = ""
    var executeFind = true
    @IBOutlet weak var webView: UIWebView!
    var typeTimer: NSTimer? = nil
    
    var autocompleteTableView = UITableView(frame: CGRectMake(0,75,320,210), style: UITableViewStyle.Plain)
    var autocompleteUrls:NSMutableArray! = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selfDelegate()
        BProgressHUD.showLoadingViewWithMessage("Loading")
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
    @IBAction func btnViewLIst(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue()) {
            let VC = self.storyboard?.instantiateViewControllerWithIdentifier("PropertyListViewController") as! PropertyListViewController
            VC.preferredContentSize = CGSize(width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.width)
            let navController = UINavigationController(rootViewController: VC)
        
            let popOver = navController.popoverPresentationController
            popOver?.delegate = self
            popOver?.barButtonItem = sender as? UIBarButtonItem
        
            self.presentViewController(navController, animated: true, completion: nil)
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
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
        self.autocompleteTableView = UITableView(frame: CGRectMake(0,75,self.view.frame.size.width, 210), style: UITableViewStyle.Plain)
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
        let url = AppConfig.APP_URL+"/map/\(User().getField("id"))?lat=\(self.latitude)&lon=\(self.longintude)&role=\(User().getField("role"))&property=\(self.propertyId)&property_class=\(self.propertyClass)"
        self.propertyId = ""
        self.propertyClass = ""
        let requestURL = NSURL(string:url)
        let request = NSURLRequest(URL: requestURL!)
        self.webView.loadRequest(request)
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.LinkClicked {
            let url:String = request.URL!.absoluteString
            if(url.containsString(AppConfig.APP_URL)) {
                let saveData: JSON =  Utility().getIdFromUrl(url)
                Property().saveOne(saveData)
                dispatch_async(dispatch_get_main_queue()) {
                    self.performSegueWithIdentifier("RealtorHomePropertyDetails", sender: self)
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                BProgressHUD.dismissHUD(2)
            }
            return false
        }
        dispatch_async(dispatch_get_main_queue()) {
            BProgressHUD.dismissHUD(2)
        }
        return true
    }
    
    @IBAction func btnMenu(sender: AnyObject) {
        self.textFieldShouldReturn(self.searchTextField)
        self.onSlideMenuButtonPressed(sender as! UIButton)
    }
    
    @IBAction func btnSearch(sender: AnyObject) {
        self.onSlideSearchButtonPressed(sender as! UIButton)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        typeTimer?.invalidate()
        typeTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("stopTypingSearch:"), userInfo: textField, repeats: false)
        return true
    }
    
    func stopTypingSearch(timer: NSTimer) {
        self.clearSearchTable()
        let substring = searchTextField.text
        if(substring!.isEmpty) {
            autocompleteTableView.hidden = true
            self.loadMap()
        }else {
            autocompleteTableView.hidden = false
            self.findproperties(substring!)
        }
    }
    
    func findproperties(substring:String) {
        self.clearSearchTable()
        dispatch_async(dispatch_get_main_queue()) {
            let params = "q=\(substring)"
            let url = AppConfig.APP_URL+"/real_state_property_basics/find_by_address/\(User().getField("id"))"
            Request().homePost(url, params: params, controller: self, successHandler: { (response) -> Void in
                self.loadProperties(response)
            })
        }
    }
    
    func loadProperties(let response: NSData) {
        self.clearSearchTable()
        dispatch_async(dispatch_get_main_queue()) {
            let properties = JSON(data: response)
            if(properties["result"].stringValue.isEmpty) {
                for (_,subJson):(String, JSON) in properties {
                    let jsonObject: AnyObject = subJson.object
                    self.autocompleteUrls.addObject(jsonObject)
                }
            } else {
                let objet:JSON = ["id":"","class":"", "description":"No Results Found!"]
                let obj: AnyObject = objet.object
                self.autocompleteUrls.addObject(obj)
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
        if let _:AnyObject = self.autocompleteUrls[indexPath.row] {
            let item = JSON(self.autocompleteUrls[indexPath.row])
            cell.textLabel!.text = item["description"].stringValue
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let _ = tableView.cellForRowAtIndexPath(indexPath) {
            let selectedCell : UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
            let item = JSON(self.autocompleteUrls[indexPath.row])
            self.autocompleteTableView.hidden = true
            if(!item["id"].stringValue.isEmpty) {
                self.searchTextField.text = selectedCell.textLabel!.text
                self.propertyId = item["id"].stringValue
                self.propertyClass = item["class"].stringValue
                self.loadMap()
            }
        }
    }
    
    func clearSearchTable() {
        self.autocompleteUrls.removeAllObjects()
        self.autocompleteTableView.reloadData()
    }

}
