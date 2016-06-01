//
//  PropertyDetailsViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/5/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class PropertyDetailsViewController: UIViewController, UIScrollViewDelegate {

    var viewData:JSON = []
    
    @IBOutlet weak var scrollImages: UIScrollView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblBedrooms: UILabel!
    @IBOutlet weak var lblBathrooms: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblSquareFeed: UILabel!
    @IBOutlet weak var lblLotSize: UILabel!
    @IBOutlet weak var lblYearBuilt: UILabel!
    @IBOutlet weak var btnSeeItPronto: UIButton!
    @IBOutlet weak var btnSeeItLater: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollImages.frame = CGRectMake(0, 0, self.view.frame.width, self.scrollImages.frame.height)
    BProgressHUD.showLoadingViewWithMessage("Loading")
        self.findPropertyDetails()
        self.showHideButtons()
    }
    
    func showHideButtons() {
        let role = User().getField("role")
        if(role == "realtor" || User().getField("id") == "") {
            btnSeeItPronto.hidden = true
            btnSeeItLater.hidden  = true
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
    
    @IBAction func btnSeeItPronto(sender: AnyObject) {
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
        let url = AppConfig.APP_URL+"/real_state_property_basics/get_property_details/\(Property().getField("id"))/\(Property().getField("property_class"))/\(User().getField("id"))?user_info=1"
        print(url)
        Request().get(url, successHandler: {(response) in self.showPropertydetails(response)})
    }
    
    func showPropertydetails(let response: NSData) {
        let result = JSON(data: response)
        dispatch_async(dispatch_get_main_queue()) {
            self.viewData = result
            let propertyId = result["id"].stringValue
            BProgressHUD.dismissHUD(3)
            if(propertyId.isEmpty) {
                self.propertyNoExistMessage()
            }
            let scrollViewWidth:CGFloat = self.scrollImages.frame.width
            let scrollViewHeight:CGFloat = self.scrollImages.frame.height
            var cont = 0
            
            if(!result["images"][0].stringValue.isEmpty) {
                let img = UIImageView(frame: CGRectMake(0, 0,scrollViewWidth, scrollViewHeight))
                Utility().showPhoto(img, imgPath: result["images"][0].stringValue)
                self.scrollImages.addSubview(img)
                cont++
            }
            if(!result["images"][1].stringValue.isEmpty) {
                let img1 = UIImageView(frame: CGRectMake(scrollViewWidth, 0,scrollViewWidth, scrollViewHeight))
                Utility().showPhoto(img1, imgPath: result["images"][1].stringValue)
                self.scrollImages.addSubview(img1)
                cont++
            }
            if(!result["images"][2].stringValue.isEmpty) {
                let img2 = UIImageView(frame: CGRectMake(scrollViewWidth*2, 0,scrollViewWidth, scrollViewHeight))
                Utility().showPhoto(img2, imgPath: result["images"][2].stringValue)
                self.scrollImages.addSubview(img2)
                cont++
            }
            if(!result["images"][3].stringValue.isEmpty) {
                let img3 = UIImageView(frame: CGRectMake(scrollViewWidth*3, 0,scrollViewWidth, scrollViewHeight))
                Utility().showPhoto(img3, imgPath: result["images"][3].stringValue)
                self.scrollImages.addSubview(img3)
                cont++
            }
            if(!result["images"][4].stringValue.isEmpty) {
                let img4 = UIImageView(frame: CGRectMake(scrollViewWidth*4, 0,scrollViewWidth, scrollViewHeight))
                Utility().showPhoto(img4, imgPath: result["images"][4].stringValue)
                self.scrollImages.addSubview(img4)
                cont++
            }
            if(!result["images"][5].stringValue.isEmpty) {
                let img4 = UIImageView(frame: CGRectMake(scrollViewWidth*5, 0,scrollViewWidth, scrollViewHeight))
                Utility().showPhoto(img4, imgPath: result["images"][5].stringValue)
                self.scrollImages.addSubview(img4)
                cont++
            }
            
            self.scrollImages.contentSize = CGSizeMake(self.scrollImages.frame.width * CGFloat(cont), self.scrollImages.frame.height)
            self.scrollImages.delegate = self
            self.pageControl.numberOfPages = cont
            self.pageControl.currentPage = 0
            self.lblPrice.text      = Utility().formatCurrency(result["price"].stringValue)
            self.lblAddress.text    = result["address"].stringValue
            self.lblBedrooms.text   = result["bedrooms"].stringValue
            self.lblBathrooms.text  = result["bathrooms"].stringValue
            self.lblType.text       = result["type"].stringValue
            self.lblSquareFeed.text = ""
            if(!result["square_feed"].stringValue.isEmpty) {
                self.lblSquareFeed.text = Utility().formatNumber(result["square_feed"].stringValue)
            }
            self.lblLotSize.text    = result["lot_size"].stringValue
            self.lblYearBuilt.text  = result["year_built"].stringValue
            Property().saveOne(result)
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
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView){
        // Test the offset and calculate the current page after scrolling ends
        let pageWidth:CGFloat = CGRectGetWidth(scrollView.frame)
        let currentPage:CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1
        // Change the indicator
        self.pageControl.currentPage = Int(currentPage);
        
    }

}
