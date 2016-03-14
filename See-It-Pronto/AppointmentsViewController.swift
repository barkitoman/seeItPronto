//
//  AppointmentsViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 3/14/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class AppointmentsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func btnBack(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
}
