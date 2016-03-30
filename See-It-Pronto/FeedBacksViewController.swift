//
//  FeedBacksViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 3/28/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class FeedBacksViewController: UIViewController {

    var countPage = 0    //number of current page
    var stepPage  = 20   //number of records by page
    var maxRow    = 0    //maximum limit records of your parse table class
    var maxPage   = 0    //maximum page
    var myListings:NSMutableArray! = NSMutableArray()
    var viewData:JSON = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
