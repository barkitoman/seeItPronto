//
//  RealtorForm4ViewController.swift
//  See-It-Pronto
//
//  Created by Usuario Mac on 1/08/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit
import CoreData

class RealtorForm4ViewController: UIViewController {
    
   
    @IBOutlet weak var lbCardNumber: UITextField!
    @IBOutlet weak var lbExpirationDate: UITextField!
    @IBOutlet weak var lbCVC: UITextField!
    @IBOutlet weak var lbPromoCode: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func btnBack(sender: AnyObject) {
    }
    
    @IBAction func btnPrevius(sender: AnyObject) {
    }
    
    @IBAction func btnNext(sender: AnyObject) {
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
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if (segue.identifier == "showMap") {
//            let view: BuyerHomeViewController = segue.destinationViewController as! BuyerHomeViewController
//            view.session  = login
//        }
    }
    
}

