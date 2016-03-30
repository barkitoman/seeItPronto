//
//  RealtorDashboardViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/4/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class RealtorDashboardViewController: UIViewController {

    var viewData:JSON = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

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

    @IBAction func btnPrevious(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btnNext(sender: AnyObject) {
        self.performSegueWithIdentifier("AgentDashBoardMyListings", sender: self)  
    }
    
    @IBAction func btnBuyers(sender: AnyObject) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let viewController = mainStoryboard.instantiateViewControllerWithIdentifier("ListBuyersViewController") as! ListBuyersViewController
        self.navigationController?.showViewController(viewController, sender: nil)
    }
    
    @IBAction func btnLog(sender: AnyObject) {
    }
    
    @IBAction func btnForms(sender: AnyObject) {
    }
    
    @IBAction func btnListing(sender: AnyObject) {
        self.performSegueWithIdentifier("AgentDashBoardMyListings", sender: self)
    }
    
    @IBAction func btnFeedBack(sender: AnyObject) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let viewController = mainStoryboard.instantiateViewControllerWithIdentifier("FeedBacksViewController") as! FeedBacksViewController
        self.navigationController?.showViewController(viewController, sender: nil)
    }
    
    

}
