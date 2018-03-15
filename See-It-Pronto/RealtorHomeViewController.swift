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
    var typeTimer: Timer? = nil
    
    var autocompleteTableView = UITableView(frame: CGRect(x: 0,y: 75,width: 320,height: 210), style: UITableViewStyle.plain)
    var autocompleteUrls:NSMutableArray! = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selfDelegate()
        DispatchQueue.main.async {
            BProgressHUD.showLoadingViewWithMessage("Loading...")
        }
        manager = OneShotLocationManager()
        manager!.fetchWithCompletion {location, error in
            // fetch location or an error
            if let loc = location {
                self.latitude   = (AppConfig.MODE == "PROD") ? "\(loc.coordinate.latitude)" : AppConfig().develop_lat()
                self.longintude = (AppConfig.MODE == "PROD") ? "\(loc.coordinate.longitude)": AppConfig().develop_lon()
                self.loadMap()
            } else if let _ = error {
                print("ERROR GETTING LOCATION")
                self.loadMap()
            }
            // destroy the object immediately to save memory
            self.manager = nil
        }
    }
    @IBAction func btnViewLIst(_ sender: AnyObject) {
        DispatchQueue.main.async {
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "PropertyListViewController") as! PropertyListViewController
            VC.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
            let navController = UINavigationController(rootViewController: VC)
        
            let popOver = navController.popoverPresentationController
            popOver?.delegate = self
            popOver?.barButtonItem = sender as? UIBarButtonItem
        
            self.present(navController, animated: true, completion: nil)
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
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
    
    //selfDelegate, textFieldShouldReturn are functions for hide keyboard when press 'return' key
    func selfDelegate() {
        self.webView.delegate = self
        self.searchTextField.delegate = self
        
        //autocomple tableViewAutoSugges
        self.autocompleteTableView = UITableView(frame: CGRect(x: 0,y: 75,width: self.view.frame.size.width, height: 210), style: UITableViewStyle.plain)
        autocompleteTableView.delegate = self
        autocompleteTableView.dataSource = self
        autocompleteTableView.isScrollEnabled = true
        autocompleteTableView.isHidden = true
        self.view.addSubview(autocompleteTableView)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func loadMap() {
        let url = AppConfig.APP_URL+"/map/\(User().getField("id"))?lat=\(self.latitude)&lon=\(self.longintude)&role=\(User().getField("role"))&property=\(self.propertyId)&property_class=\(self.propertyClass)"
        self.propertyId = ""
        self.propertyClass = ""
        let requestURL = URL(string:url)
        let request = URLRequest(url: requestURL!)
        self.webView.loadRequest(request)
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.linkClicked {
            let url:String = request.url!.absoluteString
            if(url.contains(AppConfig.APP_URL)) {
                let saveData: JSON =  Utility().getIdFromUrl(url)
                Property().saveOne(saveData)
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "RealtorHomePropertyDetails", sender: self)
                }
            }
            DispatchQueue.main.async {
                BProgressHUD.dismissHUD(2)
            }
            return false
        }
        DispatchQueue.main.async {
            BProgressHUD.dismissHUD(2)
        }
        return true
    }
    
    @IBAction func btnMenu(_ sender: AnyObject) {
        self.textFieldShouldReturn(self.searchTextField)
        if(User().getField("id") != "") {
            DispatchQueue.main.async {
                self.menuToReturn.removeAll()
                self.createMenu()
                self.createContainerView()
                self.onSlideMenuButtonPressed(sender as! UIButton)
            }
        }
    }
    
    @IBAction func btnSearch(_ sender: AnyObject) {
        self.onSlideSearchButtonPressed(sender as! UIButton)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        typeTimer?.invalidate()
        typeTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(RealtorHomeViewController.stopTypingSearch(_:)), userInfo: textField, repeats: false)
        return true
    }
    
    func stopTypingSearch(_ timer: Timer) {
        self.clearSearchTable()
        let substring = searchTextField.text
        if(substring!.isEmpty) {
            autocompleteTableView.isHidden = true
            self.loadMap()
        }else {
            autocompleteTableView.isHidden = false
            self.findproperties(substring!)
        }
    }
    
    func findproperties(_ substring:String) {
        self.clearSearchTable()
        DispatchQueue.main.async {
            let params = "q=\(substring)"
            let url = AppConfig.APP_URL+"/real_state_property_basics/find_by_address/\(User().getField("id"))"
            Request().homePost(url, params: params, controller: self, successHandler: { (response) -> Void in
                self.loadProperties(response)
            })
        }
    }
    
    func loadProperties(_ response: Data) {
        self.clearSearchTable()
        DispatchQueue.main.async {
            let properties = JSON(data: response)
            if(properties["result"].stringValue.isEmpty) {
                for (_,subJson):(String, JSON) in properties {
                    let jsonObject: AnyObject = subJson.object
                    self.autocompleteUrls.add(jsonObject)
                }
            } else {
                let objet:JSON = ["id":"" as AnyObject,"class":"" as AnyObject, "description":"No Results Found!" as AnyObject]
                let obj: AnyObject = objet.object
                self.autocompleteUrls.add(obj)
            }
            self.autocompleteTableView.reloadData()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autocompleteUrls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default , reuseIdentifier: "Cell")
        if let _:AnyObject = self.autocompleteUrls[indexPath.row] {
            let item = JSON(self.autocompleteUrls[indexPath.row])
            cell.textLabel!.text = item["description"].stringValue
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let _ = tableView.cellForRow(at: indexPath) {
            let selectedCell : UITableViewCell = tableView.cellForRow(at: indexPath)!
            let item = JSON(self.autocompleteUrls[indexPath.row])
            self.autocompleteTableView.isHidden = true
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
