//
//  BuyerForm3ViewController.swift
//  See-It-Pronto
//
//  Created by user114136 on 1/4/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class BuyerForm3ViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var txtCardNumber: UITextField!
    @IBOutlet weak var txtExpDate: UITextField!
    @IBOutlet weak var txtCVC: UITextField!
    @IBOutlet weak var txtPromoCode: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selfDelegate()
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
    
    func selfDelegate() {
        self.txtCardNumber.delegate = self
        self.txtExpDate.delegate = self
        self.txtCVC.delegate = self
        self.txtPromoCode.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    }

}
