//
//  BuyerForm4ViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/4/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class BuyerForm4ViewController: UIViewController {

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
    
    @IBAction func btnYes(_ sender: AnyObject) {
        User().updateField("is_login", value: "1")
        Utility().performSegue(self, performSegue: "FormBuyer4")
    }
    
    @IBAction func btnSkip(_ sender: AnyObject) {
        User().updateField("is_login", value: "1")
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "FormBuyer4", sender: self)
        }
    }

}
