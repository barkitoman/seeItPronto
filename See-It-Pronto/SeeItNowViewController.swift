//
//  SeeItNowViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/5/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class SeeItNowViewController: UIViewController,UIWebViewDelegate {

    var viewData:JSON = []
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var propertyPhoto: UIImageView!
    @IBOutlet weak var lblPropertyAddress: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var countPage = 0 //number of current page
    var stepPage  = 5 //number of records by page
    var maxRow    = 0 //maximum limit records of your parse table class
    var maxPage   = 0 //maximum page
    var realtors:NSMutableArray! = NSMutableArray()
    
    var manager: OneShotLocationManager?
    var latitude   = "0"
    var longintude = "0"
    var cache      = ImageLoadingWithCache()
    var model      = [Model]()
    var models     = [String:Model]()
    var count      = 0
    
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
        self.webView.isHidden = false
        self.selfDelegate()
        self.loadPropertyData()
        manager = OneShotLocationManager()
        manager!.fetchWithCompletion {location, error in
            // fetch location or an error
            if let loc = location {
                print("WAS HERE 1")
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
    
    func selfDelegate() {
        self.webView.delegate = self;
    }
    
    func loadMap() {
        DispatchQueue.main.async {
            BProgressHUD.showLoadingViewWithMessage("Loading...")
        }
        var url = AppConfig.APP_URL+"/calculate_distances/\(User().getField("id"))/\(String(self.stepPage))/"
        url     = url+"?page=\(String(self.countPage + 1))"
        url     = url+"&lat=\(self.latitude)&lon=\(self.longintude)"
        url     = url+"&property_zipcode=\(Property().getField("zipcode"))"
        url     = url+"&license=\(Property().getField("license"))"
        url     = url+"&showing_type=\(PropertyAction().getField("type"))"
        let requestURL = URL(string:url)
        let request = URLRequest(url: requestURL!)
        self.webView.loadRequest(request)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("WAS HERE 2")
        self.findPropertyRealtors()
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
    
    func loadPropertyData() {
        let image = Property().getField("image")
        self.lblPropertyAddress.text = Property().getField("address")
        if(!image.isEmpty) {
            Utility().showPhoto(self.propertyPhoto, imgPath: image)
        }
    }
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return realtors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell    = self.tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SeeitNowTableViewCell
        let realtor = JSON(self.realtors[indexPath.row])
        let name    = realtor["first_name"].stringValue+" "+realtor["last_name"].stringValue
        cell.lblCompany.text     = realtor["brokerage"].stringValue
        cell.lblName.text        = name
        //cell.lblShowingRate.text = (!realtor["showing_rate"].stringValue.isEmpty) ? "$"+realtor["showing_rate"].stringValue  : ""
        cell.lblDistance.text    = realtor["distance"].stringValue
        cell.lblRating.text      = (!realtor["rating"].stringValue.isEmpty) ? realtor["rating"].stringValue+" of 5" : ""
        cell.btnViewDetails.tag  = indexPath.row
        cell.btnViewDetails.addTarget(self, action: #selector(SeeItNowViewController.openPropertyAction(_:)), for: .touchUpInside)
        let image = (!realtor["image"].stringValue.isEmpty) ? realtor["image"].stringValue : realtor["url_image"].stringValue
        
        cell.photo.image = nil
        cell.photo.tag   = indexPath.row
        let tap = UITapGestureRecognizer(target: self, action: #selector(SeeItNowViewController.imageClickOpenProfile(_:)))
        cell.photo.addGestureRecognizer(tap)
        cell.photo.isUserInteractionEnabled = true
        Utility().showPhoto(cell.photo, imgPath: image, defaultImg: "default_user_photo")
        
        if(!realtor["rating"].stringValue.isEmpty) {
            cell.ratingImage.image = UIImage(named: realtor["rating"].stringValue+"stars")
        }
        cell.lblListingAgent.isHidden = true
        if(realtor["is_listing"].stringValue == "1") {
            cell.lblListingAgent.isHidden = false
        }
        cell.btnStopShareInfo.tag = indexPath.row
        cell.btnStopShareInfo.isHidden = true
        if(realtor["share_info"].stringValue == "1") {
            cell.btnStopShareInfo.isHidden = false
        }
        cell.btnStopShareInfo.addTarget(self, action: #selector(SeeItNowViewController.stopShareInfo(_:)), for: .touchUpInside)
        return cell
    }
    
    @IBAction func openPropertyAction(_ sender:UIButton) {
        let realtor = JSON(self.realtors[sender.tag])
        PropertyRealtor().saveOne(realtor)
        let propertyTypeAction = PropertyAction().getField("type")
        DispatchQueue.main.async {
            if(propertyTypeAction == "see_it_later") {
                //open view for see it later process
                self.performSegue(withIdentifier: "seeItNowConfirmation", sender: self)
            } else {
                //open view for see it pronto process
                self.performSegue(withIdentifier: "SeeItNowAgentConfirmation", sender: self)
            }
        }
    }
    
    @IBAction func stopShareInfo(_ sender:UIButton) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title:"Confirmation", message: "Do you really want to stop sharing your info with this agent?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) {
                UIAlertAction in
                let realtor = JSON(self.realtors[sender.tag])
                DispatchQueue.main.async {
                    let url    = AppConfig.APP_URL+"/stop_share_info"
                    let params = "buyer_id=\(User().getField("id"))&realtor_id=\(realtor["id"])"
                    Request().post(url, params: params, controller: self, successHandler: { (response) -> Void in
                        self.afterStopShareInfo(response)
                    })
                }
            }
            let noAction = UIAlertAction(title: "No", style: UIAlertActionStyle.default) {
                UIAlertAction in
            }
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    fileprivate func afterStopShareInfo( _ response: Data) {
        let result = JSON(data: response)
        if(result["result"].bool == true) {
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            Utility().displayAlert(self,title: "Error", message:"Error saving, please try later", performSegue:"")
        }
    }
    
    func imageClickOpenProfile(_ gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        if let imageView = gesture.view as? UIImageView {
            let realtor = JSON(self.realtors[imageView.tag])
            
            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let vc : RealtorProfileViewController = mainStoryboard.instantiateViewController(withIdentifier: "RealtorProfileViewController") as! RealtorProfileViewController
            vc.viewData = realtor
            self.navigationController?.show(vc, sender: nil)
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
            print("Loading Page \(self.countPage) from \(self.maxPage)")
            self.loadMap()
        }
    }

    func findPropertyRealtors() {
        let propertyId = Property().getField("id")
        let url = AppConfig.APP_URL+"/get_property_realtors/\(User().getField("id"))/\(propertyId)/\(String(self.stepPage))/?page="+String(self.countPage + 1)
        Request().get(url, successHandler: {(response) in self.loadRealtors(response)})
    }
    
    func loadRealtors( _ response: Data){
        let result = JSON(data: response)
        DispatchQueue.main.async {
            for (_,subJson):(String, JSON) in result {
                if(!subJson["id"].stringValue.isEmpty) {
                    let jsonObject: AnyObject = subJson.object
                    self.realtors.add(jsonObject)
                }
            }
            if(self.realtors.count == 0 && self.countPage == 0) {
                BProgressHUD.dismissHUD(0)
                Utility().displayAlert(self, title: "Message", message: "There are no agents available to show this property", performSegue: "")
            }
            self.tableView.reloadData()
            BProgressHUD.dismissHUD(0)
        }
    }
    
}
