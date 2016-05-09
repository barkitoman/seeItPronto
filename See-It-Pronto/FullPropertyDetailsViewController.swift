//
//  FullPropertyDetailsViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/5/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class FullPropertyDetailsViewController: UIViewController, UIScrollViewDelegate {

    var viewData:JSON = []
    
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var lbCity: UILabel!
    @IBOutlet weak var lbZipCode: UILabel!
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
    
    @IBOutlet weak var lblEstPayment: UILabel!
    @IBOutlet weak var lblYourCredits: UILabel!
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
    @IBOutlet weak var btnSearchAgain: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollImages.frame = CGRectMake(0, 0, self.view.frame.width, self.scrollImages.frame.height)
        self.showPropertydetails()
        self.showHideButtons()
    }
    
    func showHideButtons() {
        let role = User().getField("role")
        if(role == "realtor") {
            btnSearchAgain.hidden = true
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    }
    
    @IBAction func btnBack(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btnSearchAgain(sender: AnyObject) {
        Utility().goHome(self)
    }
    
    
    @IBAction func btnSeeitPronto(sender: AnyObject) {
        let propertyActionData: JSON =  ["type":"see_it_pronto"]
        PropertyAction().saveIfExists(propertyActionData)
        self.performSegueWithIdentifier("selectAgentForProperty", sender: self)
    }
    
    @IBAction func btnSeeItLater(sender: AnyObject) {
        let propertyActionData: JSON =  ["type":"see_it_later"]
        PropertyAction().saveIfExists(propertyActionData)
        self.performSegueWithIdentifier("selectAgentForProperty", sender: self)
    }
    
    func showPropertydetails() {
        dispatch_async(dispatch_get_main_queue()) {
            let scrollViewWidth:CGFloat = self.scrollImages.frame.width
            let scrollViewHeight:CGFloat = self.scrollImages.frame.height
            var cont = 0
            if(!Property().getField("image").isEmpty) {
                let img = UIImageView(frame: CGRectMake(0, 0,scrollViewWidth, scrollViewHeight))
                Utility().showPhoto(img, imgPath: Property().getField("image"))
                self.scrollImages.addSubview(img)
                cont++
            }
            if(!Property().getField("image2").isEmpty) {
                let img1 = UIImageView(frame: CGRectMake(scrollViewWidth, 0,scrollViewWidth, scrollViewHeight))
                Utility().showPhoto(img1, imgPath: Property().getField("image2"))
                self.scrollImages.addSubview(img1)
                cont++
            }
            if(!Property().getField("image3").isEmpty) {
                let img2 = UIImageView(frame: CGRectMake(scrollViewWidth*2, 0,scrollViewWidth, scrollViewHeight))
                Utility().showPhoto(img2, imgPath: Property().getField("image3"))
                self.scrollImages.addSubview(img2)
                cont++
            }
            if(!Property().getField("image4").isEmpty) {
                let img3 = UIImageView(frame: CGRectMake(scrollViewWidth*3, 0,scrollViewWidth, scrollViewHeight))
                Utility().showPhoto(img3, imgPath: Property().getField("image4"))
                self.scrollImages.addSubview(img3)
                cont++
            }
            if(!Property().getField("image5").isEmpty) {
                let img4 = UIImageView(frame: CGRectMake(scrollViewWidth*4, 0,scrollViewWidth, scrollViewHeight))
                Utility().showPhoto(img4, imgPath: Property().getField("image5"))
                self.scrollImages.addSubview(img4)
                cont++
            }
            if(!Property().getField("image6").isEmpty) {
                let img4 = UIImageView(frame: CGRectMake(scrollViewWidth*5, 0,scrollViewWidth, scrollViewHeight))
                Utility().showPhoto(img4, imgPath: Property().getField("image6"))
                self.scrollImages.addSubview(img4)
                cont++
            }
            
            self.scrollImages.contentSize = CGSizeMake(self.scrollImages.frame.width * CGFloat(cont), self.scrollImages.frame.height)
            self.scrollImages.delegate = self
            self.pageControl.numberOfPages = cont
            self.pageControl.currentPage = 0
            
            self.lblEstPayment.text   = Property().getField("est_payments")
            self.lblYourCredits.text  = Property().getField("your_credits")
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
            self.lbCity.text          = Property().getField("location")
            self.lbZipCode.text       = Property().getField("lot")
            self.lbTypeProperty.text  = Property().getField("rs")
            self.lbPrice.text         = Property().getField("price")
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
        
    }
    
}
