//
//  FullPropertyDetailsViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/5/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class FullPropertyDetailsViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UIPopoverPresentationControllerDelegate {

    var viewData:JSON = []
    
    @IBOutlet weak var lbContImage: UILabel!
    @IBOutlet weak var lbAddress: UILabel!
    //@IBOutlet weak var lbCity: UILabel!
    //@IBOutlet weak var lbZipCode: UILabel!
    @IBOutlet weak var lbTypeProperty: UILabel!
    @IBOutlet weak var lbPrice: UILabel!
    @IBOutlet weak var lbRemarks: UILabel!
    @IBOutlet weak var lbGarage: UILabel!
    @IBOutlet weak var lbInternet: UILabel!
    @IBOutlet weak var lbPets: UILabel!
    @IBOutlet weak var lbPool: UILabel!
    @IBOutlet weak var lbSpa: UILabel!
    @IBOutlet weak var scrollImages: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    //@IBOutlet weak var lblEstPayment: UILabel!
    //@IBOutlet weak var lblYourCredits: UILabel!
    @IBOutlet weak var lblBedrooms: UILabel!
    @IBOutlet weak var lblBathrooms: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblSize: UILabel!
    @IBOutlet weak var lblLot: UILabel!
    @IBOutlet weak var lblYearBuilt: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblNeighborhood: UILabel!
    @IBOutlet weak var lblAddedOn: UILabel!
    
    @IBOutlet weak var btnSeeItNow: UIButton!
    @IBOutlet weak var btnSeeItLater: UIButton!
    //@IBOutlet weak var btnSearchAgain: UIButton!
    
    var cont = 0
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollImages.frame = CGRectMake(0, 0, self.view.frame.width, self.scrollImages.frame.height)
        self.findPropertyDetails()
        BProgressHUD.showLoadingViewWithMessage("Loading")
        self.showHideButtons()
        self.tableView.delegate = self
    }
    
    func showHideButtons() {
        let role = User().getField("role")
        if(role == "realtor" || User().getField("id") == "") {
            //btnSearchAgain.hidden = true
            btnSeeItLater.hidden  = true
            btnSeeItNow.hidden    = true
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
    
    @IBAction func btnBack(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
//    @IBAction func btnSearchAgain(sender: AnyObject) {
//        Utility().goHome(self)
//    }
    
    
    @IBAction func btnSeeitPronto(sender: AnyObject) {
        if(self.viewData["user"]["current_zip_code"].stringValue == self.viewData["zipcode"].stringValue) {
            let propertyActionData: JSON =  ["type":"see_it_pronto"]
            PropertyAction().saveOne(propertyActionData)
            self.performSegueWithIdentifier("selectAgentForProperty", sender: self)
        } else {
            Utility().displayAlert(self, title: "Message", message: " \"See it pronto” is only available for nearby properties.", performSegue: "")
        }
    }
    
    @IBAction func btnSeeItLater(sender: AnyObject) {
        let propertyActionData: JSON =  ["type":"see_it_later"]
        PropertyAction().saveOne(propertyActionData)
        self.performSegueWithIdentifier("selectAgentForProperty", sender: self)
    }
    
    func findPropertyDetails(){
        let url = AppConfig.APP_URL+"/real_state_property_basics/get_property_details/\(Property().getField("id"))/\(Property().getField("property_class"))/\(User().getField("id"))?user_info=1&role=\(User().getField("role"))"
        Request().get(url, successHandler: {(response) in self.loadPropertyDetails(response)})
    }
    
    var sections = [String]()
    var dataSection:NSMutableArray = NSMutableArray()
    func loadPropertyDetails(let response: NSData) {
        let result = JSON(data: response)
        dispatch_async(dispatch_get_main_queue()) {
            self.viewData = result
            let propertyId = result["id"].stringValue
            BProgressHUD.dismissHUD(3)
            if(propertyId.isEmpty) {
                self.propertyNoExistMessage()
            }
            for (_,category):(String, JSON) in result["order"] {
                self.sections.append(category.stringValue)
                self.dataSection.addObject(result["extra_fields"][category.stringValue].object)
            }
            self.tableView.reloadData()
            Property().saveOne(result)
            self.showPropertydetails()
        }
    }
    
    func propertyNoExistMessage() {
        let alertController = UIAlertController(title:"Message", message: "The property is not available at this time", preferredStyle: .Alert)
        let homeAction = UIAlertAction(title: "Home", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            Utility().goHome(self)
        }
        alertController.addAction(homeAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showPropertydetails() {
        dispatch_async(dispatch_get_main_queue()) {
            let scrollViewWidth:CGFloat = self.scrollImages.frame.width
            let scrollViewHeight:CGFloat = self.scrollImages.frame.height
            let images = self.viewData["images"].arrayObject
            self.cont = (images?.count)!
            
                        var numberImage:CGFloat = 0
            for img in images! {
                let imgView = UIImageView(frame: CGRectMake(scrollViewWidth * numberImage, 0,scrollViewWidth, scrollViewHeight))
                let property = JSON(img)
                
                Utility().showPhoto(imgView, imgPath: property.stringValue, defaultImg: "default_user_photo")
                self.scrollImages.addSubview(imgView)
                numberImage++
                
            }
            self.lbContImage.text = "1 of \(self.cont)"
            self.scrollImages.contentSize = CGSizeMake(self.scrollImages.frame.width * CGFloat(self.cont), self.scrollImages.frame.height)
            self.scrollImages.delegate = self
            self.pageControl.numberOfPages = self.cont
            self.pageControl.currentPage = 0
            
            //self.lblEstPayment.text   = Property().getField("est_payments")
            //self.lblYourCredits.text  = Property().getField("your_credits")
            self.lblBedrooms.text     = Property().getField("bedrooms")
            self.lblBathrooms.text    = Property().getField("bathrooms")
            self.lblType.text         = Property().getField("property_type")
            self.lblSize.text         = Property().getField("size")
            self.lblLot.text          = Property().getField("lot")
            self.lblYearBuilt.text    = Property().getField("year_built")
            self.lblNeighborhood.text = Property().getField("neighborhood")
            self.lblAddedOn.text      = Property().getField("added_on")
            self.lblLocation.text     = Property().getField("location")
            
            self.lbAddress.text       = Property().getField("address")
            //            self.lbCity.text          = Property().getField("location")
            //            self.lbZipCode.text       = Property().getField("lot")
            print(Property().getField("rs"))
            if Property().getField("rs") == "For sale"{
                self.lbTypeProperty.text  = "For Sale"
            }else if Property().getField("rs") == "For rental" {
                self.lbTypeProperty.text  = "For Rental"
            }
            //self.lbTypeProperty.text  = Property().getField("rs")
            
            self.lbPrice.text         = Utility().formatCurrency(Property().getField("price"))
            self.lbRemarks.text       = Property().getField("remarks")
            self.lbGarage.text        = Property().getField("garage")
            self.lbInternet.text      = Property().getField("internet")
            self.lbPets.text          = Property().getField("petsAllowed")
            self.lbPool.text          = Property().getField("pool")
            self.lbSpa.text           = Property().getField("spa")
            
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView){
        // Test the offset and calculate the current page after scrolling ends
        let pageWidth:CGFloat = CGRectGetWidth(scrollView.frame)
        let currentPage:CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1
        // Change the indicator
        self.pageControl.currentPage = Int(currentPage);
        
        self.lbContImage.text = "\(Int(currentPage)+1) of \(self.cont)"
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSection[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell   = UITableViewCell.init(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
        cell.textLabel?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightRegular)
        cell.detailTextLabel?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightRegular)
        let dat = JSON(self.dataSection[indexPath.section][indexPath.row])
        
        cell.textLabel?.text = dat["label"].stringValue
        cell.detailTextLabel?.text = dat["value"].stringValue
        //let tema  = self.sections[indexPath.row]
        //cell.imgLogo.tag = indexPath.row
        //cell.imgLogo.setImage(UIImage(named: tema.url_logo), forState: UIControlState.Normal)
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
        
    }
    
    @IBAction func btnMoreImage(sender: AnyObject) {
        print(self.viewData)
        self.performSegueWithIdentifier("showImages", sender: self)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sections.count
    }

    func goHomeView(role:String) {
        dispatch_async(dispatch_get_main_queue()) {
            if(role == "realtor") {
                self.performSegueWithIdentifier("LoginRealtor", sender: self)
            } else {
                self.performSegueWithIdentifier("LoginBuyer", sender: self)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showImages") {
//            let view: MoreImageViewController = segue.destinationViewController as! MoreImageViewController
//                view.viewData  = self.viewData
            let view = segue.destinationViewController as! MoreImageViewController
            let controller = view.popoverPresentationController
            view.viewData  = self.viewData
            if controller != nil {
                controller?.delegate = self
            }

            
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }

}
