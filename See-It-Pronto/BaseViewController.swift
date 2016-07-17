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
        self.createMenu()
        //Create containerView that contain child view
        createContainerView()
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
    
    func menuRealtor() {
        addChildView("RealtorHomeViewController",       titleOfChildren: "Home",                   iconName: "home")
        //addChildView("PropertyListViewController",    titleOfChildren: "List Properties",        iconName: "list_properties")
        addChildView("CurrentShowingViewController",    titleOfChildren: "Current Showing",        iconName: "current_showing")
        addChildView("AppointmentsViewController",      titleOfChildren: "Appointments",           iconName: "appoiments")
        addChildView("FeedBacksViewController",         titleOfChildren: "Feedback",               iconName: "feedbacks")
        addChildView("MyListingsRealtorViewController", titleOfChildren: "My Listings",            iconName: "my_listings")
        //addChildView("RealtorProfileViewController",  titleOfChildren: "My Profile",             iconName: "my_profile")
        addChildView("ListBuyersViewController",        titleOfChildren: "Buyers",                 iconName: "buyer")
        addChildView("RealtorForm1ViewController",      titleOfChildren: "My Profile",             iconName: "edit_profile")
        addChildView("NotificationsViewController",     titleOfChildren: "Notifications",          iconName: "notification")
        addChildView("ReadyToWorkViewController",       titleOfChildren: "Making Money Status",    iconName: "making_money")
        addChildView("ConfigViewController",            titleOfChildren: "Settings",               iconName: "settings")
        addChildView("CreateBeaconViewController",      titleOfChildren: "Add Beacon",             iconName: "add_beacon")
        addChildView("LoginViewController",             titleOfChildren: "Log Out",                iconName: "logout")
        addChildView("BugReportViewController",         titleOfChildren: "Send Us Your Feedback",  iconName: "send_us_your_feedback")
        //
    }
    
    func menuBuyer(){
        addChildView("RealtorHomeViewController",      titleOfChildren: "Home",                  iconName: "home")
        //addChildView("PropertyListViewController",   titleOfChildren: "List Properties",       iconName: "list_properties")
        addChildView("ListRealtorsViewController",     titleOfChildren: "Agents",                iconName: "realtor")
        addChildView("SeeItLaterBuyerViewController",  titleOfChildren: "See It Later",          iconName: "my_listings")
        addChildView("PastListingsBuyerViewController",titleOfChildren: "Properties Viewed",     iconName: "properties_viewed")
        addChildView("BuyerForm1ViewController",       titleOfChildren: "My Profile",            iconName: "edit_profile")
        addChildView("NotificationsViewController",    titleOfChildren: "Notifications",         iconName: "notification")
        addChildView("LoginViewController",            titleOfChildren: "Log Out",               iconName: "logout")
        addChildView("ConfigViewController",           titleOfChildren: "Settings",              iconName: "settings")
        addChildView("BugReportViewController",        titleOfChildren: "Send Us Your Feedback", iconName: "send_us_your_feedback")
        addChildView("ChatViewController",        titleOfChildren: "Chat", iconName: "send_us_your_feedback")
    }
    
    //MARK: Functions for Container
    func transitionBetweenTwoViews(subViewNew: UIViewController){
        let viewIdentifier = subViewNew.restorationIdentifier
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        var viewController : UIViewController = UIViewController()
        if(viewIdentifier == "BuyerForm1ViewController") {
            viewController = mainStoryboard.instantiateViewControllerWithIdentifier("BuyerForm1ViewController") as! BuyerForm1ViewController
            
        } else if (viewIdentifier == "RealtorForm1ViewController") {
            viewController = mainStoryboard.instantiateViewControllerWithIdentifier("RealtorForm1ViewController") as! RealtorForm1ViewController
            
        } else if (viewIdentifier == "RealtorHomeViewController") {
            viewController = mainStoryboard.instantiateViewControllerWithIdentifier("RealtorHomeViewController") as! RealtorHomeViewController
            
        } else if (viewIdentifier == "BuyerHomeViewController") {
            viewController = mainStoryboard.instantiateViewControllerWithIdentifier("BuyerHomeViewController") as! BuyerHomeViewController
            
        } else if (viewIdentifier == "LoginViewController") {
            //LOGOUT ========================================
            dispatch_async(dispatch_get_main_queue()) {
                var url   = AppConfig.APP_URL+"/destroy_token"
                let token = User().getField("access_token")
                url = url+"/"+token
                Request().get(url, successHandler: {(response) in })
            }
            viewController = mainStoryboard.instantiateViewControllerWithIdentifier("BuyerHomeViewController") as! BuyerHomeViewController
            User().deleteAllData()
            SearchConfig().deleteAllData()
            
        } else if (viewIdentifier == "ListRealtorsViewController") {
            viewController = mainStoryboard.instantiateViewControllerWithIdentifier("ListRealtorsViewController") as! ListRealtorsViewController
            
        } else if (viewIdentifier == "ListBuyersViewController") {
            viewController = mainStoryboard.instantiateViewControllerWithIdentifier("ListBuyersViewController") as! ListBuyersViewController
            
        } else if (viewIdentifier == "RealtorProfileViewController") {
            viewController = mainStoryboard.instantiateViewControllerWithIdentifier("RealtorProfileViewController") as! RealtorProfileViewController
        
        } else if (viewIdentifier == "NotificationsViewController") {
            viewController = mainStoryboard.instantiateViewControllerWithIdentifier("NotificationsViewController") as! NotificationsViewController
            
        } else if (viewIdentifier == "AppointmentsViewController") {
            viewController = mainStoryboard.instantiateViewControllerWithIdentifier("AppointmentsViewController") as! AppointmentsViewController
            
        }else if (viewIdentifier == "RealtorDashboardViewController") {
            viewController = mainStoryboard.instantiateViewControllerWithIdentifier("RealtorDashboardViewController") as! RealtorDashboardViewController
            
        }else if (viewIdentifier == "MyListingsRealtorViewController") {
            viewController = mainStoryboard.instantiateViewControllerWithIdentifier("MyListingsRealtorViewController") as! MyListingsRealtorViewController
        
        }else if (viewIdentifier == "SeeItLaterBuyerViewController") {
            viewController = mainStoryboard.instantiateViewControllerWithIdentifier("SeeItLaterBuyerViewController") as! SeeItLaterBuyerViewController
        
        }else if (viewIdentifier == "PastListingsBuyerViewController") {
            viewController = mainStoryboard.instantiateViewControllerWithIdentifier("PastListingsBuyerViewController") as! PastListingsBuyerViewController
        
        }else if (viewIdentifier == "FeedBacksViewController") {
            viewController = mainStoryboard.instantiateViewControllerWithIdentifier("FeedBacksViewController") as! FeedBacksViewController
        
        }else if (viewIdentifier == "CurrentShowingViewController") {
            viewController = mainStoryboard.instantiateViewControllerWithIdentifier("CurrentShowingViewController") as! CurrentShowingViewController
        
        }else if (viewIdentifier == "PropertyListViewController") {
            viewController = mainStoryboard.instantiateViewControllerWithIdentifier("PropertyListViewController") as! PropertyListViewController
        
        }else if (viewIdentifier == "ReadyToWorkViewController") {
            let vc:ReadyToWorkViewController = mainStoryboard.instantiateViewControllerWithIdentifier("ReadyToWorkViewController") as! ReadyToWorkViewController
            vc.pageTitle = "Making Money Status"
            viewController = vc
        }else if (viewIdentifier == "ConfigViewController") {
            let vc:ConfigViewController = mainStoryboard.instantiateViewControllerWithIdentifier("ConfigViewController") as! ConfigViewController
            viewController = vc
        }
        else if (viewIdentifier == "CreateBeaconViewController") {
            let vc:CreateBeaconViewController = mainStoryboard.instantiateViewControllerWithIdentifier("CreateBeaconViewController") as! CreateBeaconViewController
            viewController = vc
        }else if (viewIdentifier == "AddRealtorPropertyViewController") {
            let vc:AddRealtorPropertyViewController = mainStoryboard.instantiateViewControllerWithIdentifier("AddRealtorPropertyViewController") as! AddRealtorPropertyViewController
            viewController = vc
        }else if (viewIdentifier == "BugReportViewController") {
            let vc:BugReportViewController = mainStoryboard.instantiateViewControllerWithIdentifier("BugReportViewController") as! BugReportViewController
            viewController = vc
        }else if (viewIdentifier == "ChatViewController") {
            let vc:ChatViewController = mainStoryboard.instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
            viewController = vc
        }
        
        //
        
        if(viewIdentifier != nil && viewIdentifier!.isEmpty) {
            self.navigationController?.pushViewController(viewController, animated: true)
        } else {
            self.navigationController?.showViewController(viewController, sender: nil)
        }
    }
    
    func slideMenuItemSelectedAtIndex(index: Int32) {
        if (index >= 0) {
            self.title=tabOfChildViewControllerName[Int(index)]
            transitionBetweenTwoViews(tabOfChildViewController[Int(index)])
        }
    }
    
    func addSlideMenuButton(){
        let navigationBarHeight: CGFloat = self.navigationController!.navigationBar.frame.height
        let btnShowMenu = ZFRippleButton()
        btnShowMenu.alpha = 0
        btnShowMenu.setImage(self.defaultMenuImage(), forState: UIControlState.Normal)
        btnShowMenu.setImage(self.defaultMenuImage(), forState: UIControlState.Highlighted)
        btnShowMenu.frame = CGRectMake(0, 0, navigationBarHeight, navigationBarHeight)
        btnShowMenu.addTarget(self, action: "onSlideMenuButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        let customBarItem = UIBarButtonItem(customView: btnShowMenu)
        self.navigationItem.leftBarButtonItem = customBarItem;
    }
    
    func defaultMenuImage() -> UIImage {
        var defaultMenuImage = UIImage()
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(27, 22), false, 0.0)
        UIColor.whiteColor().setFill()
        UIBezierPath(rect: CGRectMake(0, 3, 27, 2)).fill()
        UIBezierPath(rect: CGRectMake(0, 10, 27, 2)).fill()
        UIBezierPath(rect: CGRectMake(0, 17, 27, 2)).fill()
        defaultMenuImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return defaultMenuImage;
    }
    
    func onSlideMenuButtonPressed(sender : UIButton){
        if (sender.tag == 10){
            // Menu is already displayed, no need to display it twice, otherwise we hide the menu
            sender.tag = 0;
            //Remove Menu View Controller
            objMenu.animateWhenViewDisappear()
            return
        }
        
        sender.enabled = false
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
        
        sender.enabled = true
        
        objMenu.createOrResizeMenuView()
        objMenu.animateWhenViewAppear()
    }
    
    func onSlideSearchButtonPressed(sender : UIButton){
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController: SearchViewController = storyboard.instantiateViewControllerWithIdentifier("SearchViewController") as! SearchViewController
        self.navigationController?.showViewController(viewController, sender: nil)
    }
    
    func createContainerView(){
        //Create View
        let containerViews = UIView()
        containerViews.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(containerViews)
        self.view.sendSubviewToBack(containerViews)
        
        //Height and Width Constraints
        let widthConstraint = NSLayoutConstraint(item: containerViews, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: containerViews, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)
        
        self.view.addConstraint(widthConstraint)
        self.view.addConstraint(heightConstraint)
    }
    
    //MARK: Methods helping users to customise Menu Slider
    //Add New Screen to Menu Slider
    func addChildView(storyBoardID: String, titleOfChildren: String, iconName: String) {
        let childViewToAdd: UIViewController = storyboard!.instantiateViewControllerWithIdentifier(storyBoardID)
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
    func setImageBackground(imageName:String){
        imageNameHeaderMenu=imageName
    }
    
    
}
