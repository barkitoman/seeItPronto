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
        self.scrollImages.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.scrollImages.frame.height)
        DispatchQueue.main.async {
            BProgressHUD.showLoadingViewWithMessage("Loading...")
        }
        self.findPropertyDetails()
        self.showHideButtons()
    }
    
    func showHideButtons() {
        let role = User().getField("role")
        if(role == "realtor" || User().getField("id") == "") {
            btnSeeItPronto.isHidden = true
            btnSeeItLater.isHidden  = true
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
    
    @IBAction func btnBack(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSeeItPronto(_ sender: AnyObject) {
        if(self.viewData["user"]["current_zip_code"].stringValue == self.viewData["zipcode"].stringValue) {
            let propertyActionData: JSON =  ["type":"see_it_pronto" as AnyObject]
            PropertyAction().saveOne(propertyActionData)
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "selectAgentForProperty", sender: self)
            }
        } else {
            Utility().displayAlert(self, title: "Message", message: " \"See It Pronto!” is only available for nearby properties.", performSegue: "")
        }
    }
    
    @IBAction func btnSeeItLater(_ sender: AnyObject) {
        let propertyActionData: JSON =  ["type":"see_it_later" as AnyObject]
        PropertyAction().saveOne(propertyActionData)
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "selectAgentForProperty", sender: self)
        }
    }
    
    func findPropertyDetails(){
        let url = AppConfig.APP_URL+"/real_state_property_basics/get_property_details/\(Property().getField("id"))/\(Property().getField("property_class"))/\(User().getField("id"))?user_info=1"
        Request().get(url, successHandler: {(response) in self.showPropertydetails(response)})
    }
    
    func showPropertydetails(_ response: Data) {
        let result = JSON(data: response)
        DispatchQueue.main.async {
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
                let img = UIImageView(frame: CGRect(x: 0, y: 0,width: scrollViewWidth, height: scrollViewHeight))
                Utility().showPhoto(img, imgPath: result["images"][0].stringValue)
                self.scrollImages.addSubview(img)
                cont += 1
            }
            if(!result["images"][1].stringValue.isEmpty) {
                let img1 = UIImageView(frame: CGRect(x: scrollViewWidth, y: 0,width: scrollViewWidth, height: scrollViewHeight))
                Utility().showPhoto(img1, imgPath: result["images"][1].stringValue)
                self.scrollImages.addSubview(img1)
                cont += 1
            }
            if(!result["images"][2].stringValue.isEmpty) {
                let img2 = UIImageView(frame: CGRect(x: scrollViewWidth*2, y: 0,width: scrollViewWidth, height: scrollViewHeight))
                Utility().showPhoto(img2, imgPath: result["images"][2].stringValue)
                self.scrollImages.addSubview(img2)
                cont += 1
            }
            if(!result["images"][3].stringValue.isEmpty) {
                let img3 = UIImageView(frame: CGRect(x: scrollViewWidth*3, y: 0,width: scrollViewWidth, height: scrollViewHeight))
                Utility().showPhoto(img3, imgPath: result["images"][3].stringValue)
                self.scrollImages.addSubview(img3)
                cont += 1
            }
            if(!result["images"][4].stringValue.isEmpty) {
                let img4 = UIImageView(frame: CGRect(x: scrollViewWidth*4, y: 0,width: scrollViewWidth, height: scrollViewHeight))
                Utility().showPhoto(img4, imgPath: result["images"][4].stringValue)
                self.scrollImages.addSubview(img4)
                cont += 1
            }
            if(!result["images"][5].stringValue.isEmpty) {
                let img4 = UIImageView(frame: CGRect(x: scrollViewWidth*5, y: 0,width: scrollViewWidth, height: scrollViewHeight))
                Utility().showPhoto(img4, imgPath: result["images"][5].stringValue)
                self.scrollImages.addSubview(img4)
                cont += 1
            }
            
            self.scrollImages.contentSize = CGSize(width: self.scrollImages.frame.width * CGFloat(cont), height: self.scrollImages.frame.height)
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
        DispatchQueue.main.async {
            let alertController = UIAlertController(title:"Message", message: "The property is not available at this time", preferredStyle: .alert)
            let homeAction = UIAlertAction(title: "Home", style: UIAlertActionStyle.default) {
                UIAlertAction in
                Utility().goHome(self)
            }
            alertController.addAction(homeAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        // Test the offset and calculate the current page after scrolling ends
        let pageWidth:CGFloat = scrollView.frame.width
        let currentPage:CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1
        // Change the indicator
        self.pageControl.currentPage = Int(currentPage);
        
    }

}
