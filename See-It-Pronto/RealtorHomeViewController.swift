//
//  RealtorHomeViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/5/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class RealtorHomeViewController: BaseViewController,UIWebViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var searchTextField: UITextField!
    var viewData:JSON = []
    @IBOutlet weak var webView: UIWebView!
    
     private let baseURLString = "http://oauthtest-nyxent.rhcloud.com/real_state_property_basics/find_by_address"
    let autocompleteTableView = UITableView(frame: CGRectMake(0,70,320,120), style: UITableViewStyle.Plain)
    var pastUrls = []
    var autocompleteUrls = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selfDelegate()
        loadMap()
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
        let requestURL = NSURL(string:AppConfig.APP_URL+"/real_state_property_basics/map/"+self.viewData["id"].stringValue)
        let request = NSURLRequest(URL: requestURL!)
        self.webView.loadRequest(request)
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.LinkClicked {
            self.performSegueWithIdentifier("RealtorHomeShowingRequest", sender: self)
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
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
        autocompleteTableView.hidden = false
        let substring = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        //searchAutocompleteEntriesWithSubstring(substring)
        self.findproperties(substring)
        return true
    }
    
    func findproperties(substring:String) {
        let url = baseURLString
        Request().get(url, successHandler: {(response) in self.loadProperties(response)})
    }
    
    func loadProperties(let response: NSData) {
        autocompleteUrls.removeAll(keepCapacity: false)
        dispatch_async(dispatch_get_main_queue()) {
            let properties = JSON(data: response)
            for (_,subJson):(String, JSON) in properties {
                let descripcion = subJson["description"].stringValue
                self.autocompleteUrls.append(descripcion)
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
        let index = indexPath.row as Int
        cell.textLabel!.text = autocompleteUrls[index]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell : UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        self.searchTextField.text = selectedCell.textLabel!.text
        self.autocompleteTableView.hidden = true
    }
    
}
