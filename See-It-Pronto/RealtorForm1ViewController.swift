//
//  RealtorForm1ViewController.swift
//  See-It-Pronto
//
//  Created by user114136 on 1/4/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class RealtorForm1ViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var txtBrokerage: UITextField!
    @IBOutlet weak var txtAgent: UITextField!
    @IBOutlet weak var txtLisence: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtBankAcct: UITextField!
    @IBOutlet weak var btnChoosePicture: UIButton!

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
        self.txtBrokerage.delegate = self
        self.txtAgent.delegate = self
        self.txtLisence.delegate = self
        self.txtEmail.delegate = self
        self.txtBankAcct.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }

}
