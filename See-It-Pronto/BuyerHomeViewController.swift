//
//  BuyerHomeViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/5/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class BuyerHomeViewController: BaseViewController, UIWebViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,UITextViewDelegate, UIPopoverPresentationControllerDelegate {

    var manager: OneShotLocationManager?
    var latitude   = "0"
    var longintude = "0"
    var session:Bool = true
    var viewData:JSON     = []
    var propertyId:String = ""
    var propertyClass:String = ""
    var executeFind = true
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var btnViewList: UIButton!
    
    let autocompleteTableView = UITableView(frame: CGRectMake(0,110,320,210), style: UITableViewStyle.Plain)
    var autocompleteUrls:NSMutableArray! = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selfDelegate()
        if !session{
            btnViewList.hidden = true
            btnSignUp.hidden = false
            btnLogin.hidden = false
        }else{
            btnViewList.hidden = false
            btnSignUp.hidden = true
            btnLogin.hidden = true
        }
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

   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func selfDelegate() {
        self.webView.delegate = self;
        self.txtSearch.delegate = self
            
        //autocomplete tableview configuration
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
                Property().saveIfExists(saveData)
                self.performSegueWithIdentifier("ViewBuyerHouse", sender: self)
            }
            return false
        }
        return true
    }
    
    @IBAction func btnMenu(sender: AnyObject) {
        if session {
            self.textFieldShouldReturn(self.txtSearch)
            self.onSlideMenuButtonPressed(sender as! UIButton)
        }
    }
    
    @IBAction func btnSearchMenu(sender: AnyObject) {
        self.onSlideSearchButtonPressed(sender as! UIButton)
    }
    
    @IBAction func btnViewList(sender: AnyObject) {
        let VC = storyboard?.instantiateViewControllerWithIdentifier("PropertyListViewController") as! PropertyListViewController
        VC.preferredContentSize = CGSize(width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.width)
        let navController = UINavigationController(rootViewController: VC)
        
        let popOver = navController.popoverPresentationController
        popOver?.delegate = self
        popOver?.barButtonItem = sender as? UIBarButtonItem
        
        self.presentViewController(navController, animated: true, completion: nil)
    }
    
    @IBAction func btnSingUP(sender: AnyObject) {
        let VC = storyboard?.instantiateViewControllerWithIdentifier("SelectRoleViewController") as! SelectRoleViewController
        VC.preferredContentSize = CGSize(width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.width)
        let navController = UINavigationController(rootViewController: VC)
        
        let popOver = navController.popoverPresentationController
        popOver?.delegate = self
        popOver?.barButtonItem = sender as? UIBarButtonItem
        
        self.presentViewController(navController, animated: true, completion: nil)
        
    }
    
    @IBAction func btnLogin(sender: AnyObject) {
        let VC = storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        VC.preferredContentSize = CGSize(width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.width)
        let navController = UINavigationController(rootViewController: VC)
        
        let popOver = navController.popoverPresentationController
        popOver?.delegate = self
        popOver?.barButtonItem = sender as? UIBarButtonItem
        
        self.presentViewController(navController, animated: true, completion: nil)
    }
    
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
        let substring = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        if(substring.isEmpty) {
            autocompleteTableView.hidden = true
            self.loadMap()
        }else {
            autocompleteTableView.hidden = false
            self.findproperties(substring)
        }
        return true
    }
    
    func findproperties(substring:String) {
        if(self.executeFind == true) {
            self.executeFind = false
            let urlString = "\(AppConfig.APP_URL)/real_state_property_basics/find_by_address/\(substring)"
            let url = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            Request().get(url!, successHandler: {(response) in self.loadProperties(response)})
        }
    }
    
    func loadProperties(let response: NSData) {
        self.autocompleteUrls = NSMutableArray()
        dispatch_async(dispatch_get_main_queue()) {
            let properties = JSON(data: response)
            if(properties["result"].stringValue.isEmpty) {
                for (_,subJson):(String, JSON) in properties {
                    let jsonObject: AnyObject = subJson.object
                    self.autocompleteUrls.addObject(jsonObject)
                }
                self.autocompleteTableView.reloadData()
            }
            self.executeFind = true
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
        self.txtSearch.text = selectedCell.textLabel!.text
        self.autocompleteTableView.hidden = true
        let item = JSON(self.autocompleteUrls[indexPath.row])
        self.propertyId = item["id"].stringValue
        self.propertyClass = item["class"].stringValue
        self.loadMap()
    }
}
