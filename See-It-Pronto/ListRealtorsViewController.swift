//
//  ListRealtorsViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 2/9/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class ListRealtorsViewController: UIViewController,UIWebViewDelegate {
    
    var viewData:JSON = []
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var tableView: UITableView!
    var countPage = 0    //number of current page
    var stepPage  = 20   //number of records by page
    var maxRow    = 0    //maximum limit records of your parse table class
    var maxPage   = 0    //maximum page
    var realtors:NSMutableArray! = NSMutableArray()
    
    var manager: OneShotLocationManager?
    var latitude   = "0"
    var longintude = "0"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.isHidden = true
        self.selfDelegate()
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
    
    func selfDelegate() {
        self.webView.delegate = self;
    }
    
    func loadMap() {
        var url = AppConfig.APP_URL+"/calculate_distances/\(User().getField("id"))/\(String(self.stepPage))"
        url     = url+"/?page=\(String(self.countPage + 1))"
        url     = url+"&lat=\(self.latitude)&lon=\(self.longintude)"
        let requestURL = URL(string:url)
        let request = URLRequest(url: requestURL!)
        self.webView.loadRequest(request)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        DispatchQueue.main.async {
            BProgressHUD.showLoadingViewWithMessage("Loading...")
        }
        self.findRealtors()
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
        return realtors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell    = self.tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ListRealtorsTableViewCell
        let realtor = JSON(self.realtors[indexPath.row])
        let name    = realtor["first_name"].stringValue+" "+realtor["last_name"].stringValue
        cell.lblName.text = name
        cell.lblBrokerage.text   = realtor["brokerage"].stringValue
        cell.lblShowingRate.text = (!realtor["showing_rate"].stringValue.isEmpty) ? "$"+realtor["showing_rate"].stringValue  : ""
        cell.lblTravelRange.text = realtor["distance"].stringValue
        cell.lblStaring.text     = (!realtor["rating"].stringValue.isEmpty) ? realtor["rating"].stringValue+" of 5" : ""
        if(!realtor["image"].stringValue.isEmpty) {
            cell.photo.image = nil
            Utility().showPhoto(cell.photo, imgPath: realtor["image"].stringValue, defaultImg: "default_user_photo")
        }
        if(!realtor["rating"].stringValue.isEmpty) {
            cell.ratingImage.image = UIImage(named: realtor["rating"].stringValue+"stars")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        self.viewData = JSON(self.realtors[indexPath.row])
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "showRealtorProfile", sender: self)
        }
    }
    
    //Pagination
    func tableView(_ tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: IndexPath){
        let row = indexPath.row
        let lastRow = self.realtors.count - 1
        let pageLimit = (((self.countPage+1) * (self.stepPage)) - 1)  //prevision of the page limit based on step and countPage

        // 1) The last rown and is the last
        // 2) To avoid two calls in a short space from time, while the data is downloading
        if (row == lastRow) && (row == pageLimit)  {
            self.countPage += 1
            self.findRealtors()
        }
    }
    
    func findRealtors() {
        let url = AppConfig.APP_URL+"/get_property_realtors/\(User().getField("id"))/0/\(String(self.stepPage))/?page="+String(self.countPage + 1)
        Request().get(url, successHandler: {(response) in self.loadRealtors(response)})
    }
    
    func loadRealtors(_ response: Data){
        let result = JSON(data: response)
        DispatchQueue.main.async {
            for (_,subJson):(String, JSON) in result {
                let jsonObject: AnyObject = subJson.object
                self.realtors.add(jsonObject)
            }
            if self.realtors.count > 0 {
                self.tableView.reloadData()
                BProgressHUD.dismissHUD(5)
            }else {
                BProgressHUD.dismissHUD(0)
                let msg = "Currently no available agents!"
                Utility().displayAlert(self,title: "Notification", message:msg, performSegue:"")
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showRealtorProfile") {
            let view: RealtorProfileViewController = segue.destination as! RealtorProfileViewController
            view.viewData  = self.viewData
        }
    }

}
