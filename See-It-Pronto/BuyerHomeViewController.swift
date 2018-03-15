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
    var latitude     = "0"
    var longintude   = "0"
    var session:Bool = true
    var viewData:JSON        = []
    var propertyId:String    = ""
    var propertyClass:String = ""
    var propertyIdTemporal:String    = ""
    var propertyClassTemporal:String = ""
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var btnViewList: UIButton!
    var typeTimer: Timer? = nil
    var logOutMenu = false
    
    var autocompleteTableView = UITableView(frame: CGRect(x: 0,y: 110,width: 320,height: 210), style: UITableViewStyle.plain)
    var autocompleteUrls:NSMutableArray! = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selfDelegate()
        if logOutMenu == true {
            User().deleteAllData()
        }
        if User().getField("id") != "" && logOutMenu == false {
            btnViewList.isHidden = false
            btnSignUp.isHidden = true
            btnLogin.isHidden = true
        } else {
            btnViewList.isHidden = true
            btnSignUp.isHidden = false
            btnLogin.isHidden = false
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
    
    func selfDelegate() {
        self.webView.delegate = self;
        self.txtSearch.delegate = self
            
        //autocomplete tableview configuration
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
        if(User().getField("id").isEmpty) {
            self.loadNosessionMap()
        } else {
            self.loadSessionMap()
        }
    }
    
    func loadSessionMap() {
        let url = AppConfig.APP_URL+"/map/\(User().getField("id"))?lat=\(self.latitude)&lon=\(self.longintude)&role=\(User().getField("role"))&property=\(self.propertyId)&property_class=\(self.propertyClass)"
        self.propertyId = ""
        self.propertyClass = ""
        let requestURL = URL(string:url)
        let request = URLRequest(url: requestURL!)
        self.webView.loadRequest(request)
    }
    
    func loadNosessionMap() {
        var url = AppConfig.APP_URL+"/map/0"
        url =  url+"?lat=\(self.latitude)"
        url =  url+"&lon=\(self.longintude)"
        url =  url+"&role=\(User().getField("role"))"
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
                    self.performSegue(withIdentifier: "ViewBuyerHouse", sender: self)
                }
            }
            return false
        }
        return true
    }
    
    @IBAction func btnMenu(_ sender: AnyObject) {
        self.textFieldShouldReturn(self.txtSearch)
        if(User().getField("id") != "") {
            DispatchQueue.main.async {
                self.menuToReturn.removeAll()
                self.createMenu()
                self.createContainerView()
                self.onSlideMenuButtonPressed(sender as! UIButton)
            }
        }
    }
    
    @IBAction func btnSearchMenu(_ sender: AnyObject) {
        self.onSlideSearchButtonPressed(sender as! UIButton)
    }

    @IBAction func btnViewList(_ sender: AnyObject) {
        DispatchQueue.main.async {
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "PropertyListViewController") as! PropertyListViewController
            VC.propertyId = self.propertyIdTemporal
            VC.propertyClass = self.propertyClassTemporal
            VC.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
            let navController = UINavigationController(rootViewController: VC)
        
            let popOver = navController.popoverPresentationController
            popOver?.delegate = self
            popOver?.barButtonItem = sender as? UIBarButtonItem
        
            self.present(navController, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnSingUP(_ sender: AnyObject) {
        DispatchQueue.main.async {
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "SelectRoleViewController") as! SelectRoleViewController
            VC.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
            let navController = UINavigationController(rootViewController: VC)
        
            let popOver = navController.popoverPresentationController
            popOver?.delegate = self
            popOver?.barButtonItem = sender as? UIBarButtonItem
        
            self.present(navController, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func btnLogin(_ sender: AnyObject) {
        DispatchQueue.main.async {
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        typeTimer?.invalidate()
        typeTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(BuyerHomeViewController.stopTypingSearch(_:)), userInfo: textField, repeats: false)
        return true
    }
    
    func stopTypingSearch(_ timer: Timer) {
        self.clearSearchTable()
        let substring = txtSearch.text
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
    
    func loadProperties( _ response: Data) {
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
                self.txtSearch.text = selectedCell.textLabel!.text
                self.propertyId = item["id"].stringValue
                self.propertyClass = item["class"].stringValue
                
                self.propertyIdTemporal = item["id"].stringValue
                self.propertyClassTemporal = item["class"].stringValue
                self.loadMap()
            }
        }
    }
    
    func clearSearchTable() {
        self.autocompleteUrls.removeAllObjects()
        self.autocompleteTableView.reloadData()
    }
}
