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

    @IBAction func btnPrevious(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnNext(_ sender: AnyObject) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "AgentDashBoardMyListings", sender: self)
        }
    }
    
    @IBAction func btnBuyers(_ sender: AnyObject) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "ListBuyersViewController") as! ListBuyersViewController
        self.navigationController?.show(viewController, sender: nil)
    }
    
    @IBAction func btnLog(_ sender: AnyObject) {
    }
    
    @IBAction func btnForms(_ sender: AnyObject) {
    }
    
    @IBAction func btnListing(_ sender: AnyObject) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "AgentDashBoardMyListings", sender: self)
        }
    }
    
    @IBAction func btnFeedBack(_ sender: AnyObject) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "FeedBacksViewController") as! FeedBacksViewController
        self.navigationController?.show(viewController, sender: nil)
    }
    
    

}
