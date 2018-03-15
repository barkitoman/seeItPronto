//
//  BaseViewController.swift
//  Swift Slide Menu
//
//  Created by Philippe BOISNEY 10/01/15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit
import CoreData

class BaseViewController: UIViewController, SlideMenuDelegate {
    
    var tabOfChildViewController: [UIViewController] = []
    var tabOfChildViewControllerName: [String] = []
    var tabOfChildViewControllerIconName: [String] = []
    var menuToReturn = [Dictionary<String,String>]()
    var imageNameHeaderMenu: String = "logoFondoBlanco"
    
    var objMenu : TableViewMenuController!
    var objSearch : UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.createMenu()
        //createContainerView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        super.viewWillAppear(animated)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func createMenu(){
        let userId = User().getField("id")
        let role   = User().getField("role")
        if(!userId.isEmpty && !role.isEmpty) {
            if(role == "realtor") {
                self.menuRealtor()
            }else if (role == "buyer") {
                self.menuBuyer()
            }
        }
    }
    
    fileprivate func countNotifications()->String {
        let val = UIApplication.shared.applicationIconBadgeNumber.description
        var out = ""
        if(User().getField("id") != "") {
            if let currentCount = Int(val) {
                if(currentCount > 0) {
                    out = " (\(currentCount))"
                }
            }
        }
        return out
    }
    
    func menuRealtor() {
        let subscriptionActive = User().getField("stripe_subscription_active")
        if(subscriptionActive == "1") {
            addChildView("RealtorHomeViewController",       titleOfChildren: "Home",                   iconName: "home")
            addChildView("CurrentShowingViewController",    titleOfChildren: "Current Showing",        iconName: "current_showing")
            addChildView("AppointmentsViewController",      titleOfChildren: "Appointments",           iconName: "appoiments")
            addChildView("FeedBacksViewController",         titleOfChildren: "Feedback",               iconName: "feedbacks")
            addChildView("MyListingsRealtorViewController", titleOfChildren: "My Listings",            iconName: "my_listings")
            addChildView("ListBuyersViewController",        titleOfChildren: "Consumers",              iconName: "buyer")
            addChildView("RealtorForm1ViewController",      titleOfChildren: "My Profile",             iconName: "edit_profile")
            addChildView("NotificationsViewController",     titleOfChildren: "Notifications \(self.countNotifications())",          iconName: "notification")
            addChildView("ReadyToWorkViewController",       titleOfChildren: "Make Myself Active",     iconName: "making_money")
            addChildView("ConfigViewController",            titleOfChildren: "Settings",               iconName: "settings")
            addChildView("CreateBeaconViewController",      titleOfChildren: "Add Beacon",             iconName: "add_beacon")
            addChildView("LoginViewController",             titleOfChildren: "Log Out",                iconName: "logout")
            addChildView("BugReportViewController",         titleOfChildren: "Send Us Your Feedback",  iconName: "send_us_your_feedback")
        } else {
            addChildView("RealtorForm1ViewController",      titleOfChildren: "My Profile",             iconName: "edit_profile")
            addChildView("BugReportViewController",         titleOfChildren: "Send Us Your Feedback",  iconName: "send_us_your_feedback")
            addChildView("LoginViewController",             titleOfChildren: "Log Out",                iconName: "logout")
        }
        addChildView("AboutUsViewController",          titleOfChildren: "About", iconName: "about_us")
    }
    
    func menuBuyer(){
        addChildView("RealtorHomeViewController",      titleOfChildren: "Home",                  iconName: "home")
        addChildView("SeeItLaterBuyerViewController",  titleOfChildren: "See It Later",          iconName: "my_listings")
        addChildView("PropertyViewedViewController",   titleOfChildren: "Properties Viewed",     iconName: "properties_viewed")
        addChildView("BuyerForm1ViewController",       titleOfChildren: "My Profile",            iconName: "edit_profile")
        addChildView("NotificationsViewController",    titleOfChildren: "Notifications \(self.countNotifications())",         iconName: "notification")
        addChildView("LoginViewController",            titleOfChildren: "Log Out",               iconName: "logout")
        addChildView("ConfigViewController",           titleOfChildren: "Settings",              iconName: "settings")
        addChildView("BugReportViewController",        titleOfChildren: "Send Us Your Feedback", iconName: "send_us_your_feedback")
        addChildView("AboutUsViewController",          titleOfChildren: "About", iconName: "about_us")
    }
    
    //MARK: Functions for Container
    func transitionBetweenTwoViews(_ subViewNew: UIViewController){
        let viewIdentifier = subViewNew.restorationIdentifier
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController : UIViewController = UIViewController()
        var showView = true
        if(viewIdentifier == "BuyerForm1ViewController") {
            viewController = mainStoryboard.instantiateViewController(withIdentifier: "BuyerForm1ViewController") as! BuyerForm1ViewController
            
        } else if (viewIdentifier == "RealtorForm1ViewController") {
            viewController = mainStoryboard.instantiateViewController(withIdentifier: "RealtorForm1ViewController") as! RealtorForm1ViewController
            
        } else if (viewIdentifier == "RealtorHomeViewController") {
            viewController = mainStoryboard.instantiateViewController(withIdentifier: "RealtorHomeViewController") as! RealtorHomeViewController
            
        } else if (viewIdentifier == "BuyerHomeViewController") {
            viewController = mainStoryboard.instantiateViewController(withIdentifier: "BuyerHomeViewController") as! BuyerHomeViewController
            
        } else if (viewIdentifier == "LoginViewController") {
            //LOGOUT ========================================
            let userId = User().getField("id")
            DispatchQueue.main.async {
                var url   = AppConfig.APP_URL+"/logout_phone"
                url = url+"/"+userId
                Request().get(url, successHandler: {(response) in })
            }
            
            showView = false
            let vc : BuyerHomeViewController = mainStoryboard.instantiateViewController(withIdentifier: "BuyerHomeViewController") as! BuyerHomeViewController
            vc.logOutMenu = true
            let saveData: JSON =  ["id":"" as AnyObject]
            User().saveOne(saveData)
            SearchConfig().saveOne(saveData)
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        } else if (viewIdentifier == "ListRealtorsViewController") {
            viewController = mainStoryboard.instantiateViewController(withIdentifier: "ListRealtorsViewController") as! ListRealtorsViewController
            
        } else if (viewIdentifier == "ListBuyersViewController") {
            viewController = mainStoryboard.instantiateViewController(withIdentifier: "ListBuyersViewController") as! ListBuyersViewController
            
        } else if (viewIdentifier == "RealtorProfileViewController") {
            viewController = mainStoryboard.instantiateViewController(withIdentifier: "RealtorProfileViewController") as! RealtorProfileViewController
        
        } else if (viewIdentifier == "NotificationsViewController") {
            viewController = mainStoryboard.instantiateViewController(withIdentifier: "NotificationsViewController") as! NotificationsViewController
            
        } else if (viewIdentifier == "AppointmentsViewController") {
            viewController = mainStoryboard.instantiateViewController(withIdentifier: "AppointmentsViewController") as! AppointmentsViewController
            
        }else if (viewIdentifier == "RealtorDashboardViewController") {
            viewController = mainStoryboard.instantiateViewController(withIdentifier: "RealtorDashboardViewController") as! RealtorDashboardViewController
            
        }else if (viewIdentifier == "MyListingsRealtorViewController") {
            viewController = mainStoryboard.instantiateViewController(withIdentifier: "MyListingsRealtorViewController") as! MyListingsRealtorViewController
        
        }else if (viewIdentifier == "SeeItLaterBuyerViewController") {
            viewController = mainStoryboard.instantiateViewController(withIdentifier: "SeeItLaterBuyerViewController") as! SeeItLaterBuyerViewController
        
        }else if (viewIdentifier == "PropertyViewedViewController") {
            viewController = mainStoryboard.instantiateViewController(withIdentifier: "PropertyViewedViewController") as! PropertyViewedViewController
        
        }else if (viewIdentifier == "PastListingsBuyerViewController") {
            viewController = mainStoryboard.instantiateViewController(withIdentifier: "PastListingsBuyerViewController") as! PastListingsBuyerViewController
            
        }else if (viewIdentifier == "FeedBacksViewController") {
            viewController = mainStoryboard.instantiateViewController(withIdentifier: "FeedBacksViewController") as! FeedBacksViewController
        
        }else if (viewIdentifier == "CurrentShowingViewController") {
            viewController = mainStoryboard.instantiateViewController(withIdentifier: "CurrentShowingViewController") as! CurrentShowingViewController
        
        }else if (viewIdentifier == "PropertyListViewController") {
            viewController = mainStoryboard.instantiateViewController(withIdentifier: "PropertyListViewController") as! PropertyListViewController
        
        }else if (viewIdentifier == "ReadyToWorkViewController") {
            let vc:ReadyToWorkViewController = mainStoryboard.instantiateViewController(withIdentifier: "ReadyToWorkViewController") as! ReadyToWorkViewController
            vc.pageTitle = "Make Myself Active"
            viewController = vc
        }else if (viewIdentifier == "ConfigViewController") {
            let vc:ConfigViewController = mainStoryboard.instantiateViewController(withIdentifier: "ConfigViewController") as! ConfigViewController
            viewController = vc
        }
        else if (viewIdentifier == "CreateBeaconViewController") {
            let vc:CreateBeaconViewController = mainStoryboard.instantiateViewController(withIdentifier: "CreateBeaconViewController") as! CreateBeaconViewController
            viewController = vc
        }else if (viewIdentifier == "AddRealtorPropertyViewController") {
            let vc:AddRealtorPropertyViewController = mainStoryboard.instantiateViewController(withIdentifier: "AddRealtorPropertyViewController") as! AddRealtorPropertyViewController
            viewController = vc
        }else if (viewIdentifier == "BugReportViewController") {
            let vc:BugReportViewController = mainStoryboard.instantiateViewController(withIdentifier: "BugReportViewController") as! BugReportViewController
            viewController = vc
        }else if (viewIdentifier == "ChatViewController") {
            let vc:ChatViewController = mainStoryboard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
            viewController = vc
        }else if (viewIdentifier == "AboutUsViewController") {
            let vc:AboutUsViewController = mainStoryboard.instantiateViewController(withIdentifier: "AboutUsViewController") as! AboutUsViewController
            viewController = vc
        }
        
        DispatchQueue.main.async {
            if(showView == true) {
                if(viewIdentifier != nil && viewIdentifier!.isEmpty) {
                    self.navigationController?.pushViewController(viewController, animated: true)
                } else {
                    self.navigationController?.show(viewController, sender: nil)
                }
            }
        }
    }
    
    func slideMenuItemSelectedAtIndex(_ index: Int32) {
        if (index >= 0) {
            self.title=tabOfChildViewControllerName[Int(index)]
            transitionBetweenTwoViews(tabOfChildViewController[Int(index)])
        }
    }
    
    func addSlideMenuButton(){
        let navigationBarHeight: CGFloat = self.navigationController!.navigationBar.frame.height
        let btnShowMenu = ZFRippleButton()
        btnShowMenu.alpha = 0
        btnShowMenu.setImage(self.defaultMenuImage(), for: UIControlState())
        btnShowMenu.setImage(self.defaultMenuImage(), for: UIControlState.highlighted)
        btnShowMenu.frame = CGRect(x: 0, y: 0, width: navigationBarHeight, height: navigationBarHeight)
        btnShowMenu.addTarget(self, action: #selector(BaseViewController.onSlideMenuButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        let customBarItem = UIBarButtonItem(customView: btnShowMenu)
        self.navigationItem.leftBarButtonItem = customBarItem;
    }
    
    func defaultMenuImage() -> UIImage {
        var defaultMenuImage = UIImage()
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 27, height: 22), false, 0.0)
        UIColor.white.setFill()
        UIBezierPath(rect: CGRect(x: 0, y: 3, width: 27, height: 2)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 10, width: 27, height: 2)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 17, width: 27, height: 2)).fill()
        defaultMenuImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return defaultMenuImage;
    }
    
    func onSlideMenuButtonPressed(_ sender : UIButton){
        if (sender.tag == 10){
            // Menu is already displayed, no need to display it twice, otherwise we hide the menu
            sender.tag = 0;
            //Remove Menu View Controller
            objMenu.animateWhenViewDisappear()
            return
        }
        
        sender.isEnabled = false
        sender.tag = 10
        
        //Create Menu View Controller
        objMenu = TableViewMenuController()
        objMenu.setMenu(menuToReturn)
        objMenu.setImageName(imageNameHeaderMenu)
        objMenu.btnMenu = sender
        objMenu.delegate = self
        
        //objMenu.view.frame = newFrame
        //objMenu.view.bounds = newFrame
        self.view.addSubview(objMenu.view)
        self.addChildViewController(objMenu)
        
        sender.isEnabled = true
        
        objMenu.createOrResizeMenuView()
        objMenu.animateWhenViewAppear()
    }
    
    func onSlideSearchButtonPressed(_ sender : UIButton){
        DispatchQueue.main.async {
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController: SearchViewController = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
            self.navigationController?.show(viewController, sender: nil)
        }
    }
    
    func createContainerView(){
        //Create View
        let containerViews = UIView()
        containerViews.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(containerViews)
        self.view.sendSubview(toBack: containerViews)
        
        //Height and Width Constraints
        let widthConstraint = NSLayoutConstraint(item: containerViews, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.width, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: containerViews, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.height, multiplier: 1, constant: 0)
        
        self.view.addConstraint(widthConstraint)
        self.view.addConstraint(heightConstraint)
    }
    
    //MARK: Methods helping users to customise Menu Slider
    //Add New Screen to Menu Slider
    func addChildView(_ storyBoardID: String, titleOfChildren: String, iconName: String) {
        let childViewToAdd: UIViewController = storyboard!.instantiateViewController(withIdentifier: storyBoardID)
        tabOfChildViewController += [childViewToAdd]
        tabOfChildViewControllerName += [titleOfChildren]
        tabOfChildViewControllerIconName += [iconName]
        menuToReturn.append(["title":titleOfChildren, "icon":iconName])
    }
    
    //Show the first child at startup of application
    func showFirstChild(){
        //Load the first subView
        self.slideMenuItemSelectedAtIndex(0)
    }
    
    //Set the image background of Menu (TableView Header)
    func setImageBackground(_ imageName:String){
        imageNameHeaderMenu=imageName
    }
    
    
}
