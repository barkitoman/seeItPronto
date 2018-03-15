//
//  FeedBacksViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 3/28/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class FeedBacksViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var countPage = 0    //number of current page
    var stepPage  = 20   //number of records by page
    var maxRow    = 0    //maximum limit records of your parse table class
    var maxPage   = 0    //maximum page
    var feedbacks:NSMutableArray! = NSMutableArray()
    var viewData:JSON = []
    var cache = ImageLoadingWithCache()
    var model = [Model]()
    var models = [String:Model]()
    var count = 0

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
        DispatchQueue.main.async {
            BProgressHUD.showLoadingViewWithMessage("Loading...")
        }
        self.findFeedBacks()
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
    
    @IBAction func btnBack(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedbacks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FeedBacksTableViewCell
        let feedback = JSON(self.feedbacks[indexPath.row])
        cell.lblAddress.text = feedback["property_address"].stringValue
        cell.lblDescription.text = feedback["feedback_property_comment"].stringValue
        cell.lblDate.text = feedback["nice_date"].stringValue
        var homeRating = "0"
        if(!feedback["home_rating_value"].stringValue.isEmpty) {
            homeRating = feedback["home_rating_value"].stringValue
        }
        cell.rating.image = UIImage(named: homeRating+"stars")
        if let _ = self.models[feedback["property_id"].stringValue] {
            self.showCell(cell, showing: feedback, indexPath: indexPath)
        } else {
            cell.imageFeedback.image = nil
            self.models[feedback["property_id"].stringValue] = Model()
            self.showCell(cell, showing: feedback, indexPath: indexPath)
        }
        return cell
    }
    
    func showCell(_ cell:FeedBacksTableViewCell, showing:JSON, indexPath: IndexPath){
        // have we got a picture?
        if let im = self.models[showing["property_id"].stringValue]!.im {
            cell.imageFeedback.image = im
        } else {
            if self.models[showing["property_id"].stringValue]!.task == nil &&  self.models[showing["property_id"].stringValue]!.reloaded == false {
                // no task? start one!
                let url = AppConfig.APP_URL+"/real_state_property_basics/get_photos_property/"+showing["property_id"].stringValue+"/1"
                Request().get(url, successHandler: {(response) in self.imageCell(indexPath, img:cell.imageFeedback, response: response)})
            }
        }
    }
    
    func imageCell(_ indexPath: IndexPath, img:UIImageView,response: Data) {
        let showing = JSON(self.feedbacks[indexPath.row])
        let result = JSON(data: response)
        let url = AppConfig.APP_URL+"/"+result[0]["url"].stringValue
        self.models[showing["property_id"].stringValue]!.task = self.downloader.download(url) {
            [weak self] url in // *
            if let _ = self?.models[showing["property_id"].stringValue] {
                self!.models[showing["property_id"].stringValue]!.task = nil
                if url == nil {
                    return
                }
                let data = try! Data(contentsOf: url)
                //if photo is empty
                if data.count <= 116 {
                    let im = UIImage(named: "default_property_photo")
                    self!.models[showing["property_id"].stringValue]!.im = im
                }else {
                    let im = UIImage(data:data)
                    self!.models[showing["property_id"].stringValue]!.im = im
                }
                DispatchQueue.main.async {
                    self!.models[showing["property_id"].stringValue]!.reloaded = true
                    self!.tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        let feedback = JSON(self.feedbacks[indexPath.row])
        Utility().displayAlert(self, title: "Feedback", message: feedback["feedback_property_comment"].stringValue, performSegue: "")
    }
    
    //Pagination
    func tableView(_ tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: IndexPath){
        let row = indexPath.row
        let lastRow = self.feedbacks.count - 1
        let pageLimit = (((self.countPage+1) * (self.stepPage)) - 1)  //prevision of the page limit based on step and countPage
        
        // 1) The last rown and is the last
        // 2) To avoid two calls in a short space from time, while the data is downloading
        if (row == lastRow) && (row == pageLimit)  {
            self.countPage += 1
            print("Loading Page \(self.countPage) from \(self.maxPage)")
            self.findFeedBacks()
        }
    }
    
    func findFeedBacks() {
        var url = AppConfig.APP_URL+"/my_feedbacks/\(User().getField("id"))/\(self.stepPage)/?page="+String(self.countPage + 1)
        url = url+"&license=\(User().getField("license"))"
        Request().get(url, successHandler: {(response) in self.loadFeedBacks(response)})
    }
    
    func loadFeedBacks(_ response: Data){
        let result = JSON(data: response)
        print(result)
        DispatchQueue.main.async {
            for (_,subJson):(String, JSON) in result["data"] {
                let jsonObject: AnyObject = subJson.object
                self.feedbacks.add(jsonObject)
            }
            self.tableView.reloadData()
            BProgressHUD.dismissHUD(0)
        }
    }


}
