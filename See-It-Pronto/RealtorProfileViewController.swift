//
//  RealtorProfileViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/4/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class RealtorProfileViewController: UIViewController {

    var viewData:JSON = []
    
    @IBOutlet weak var lblBiography: UILabel!
    @IBOutlet weak var lblFirstName: UILabel!
    @IBOutlet weak var rating: UIImageView!
    @IBOutlet weak var lblLastName: UILabel!
    @IBOutlet weak var lblBrokerage: UILabel!
    @IBOutlet weak var previewPhoto: UIImageView!
    @IBOutlet weak var btnPrevious: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    var userId:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.findUserInfo()
        let role = User().getField("id")
        if(role != "realtor") {
            self.btnPrevious.hidden = true
            self.btnNext.hidden = true
        }
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
    
    func findUserInfo() {
        self.userId = self.viewData["id"].stringValue
        if(self.userId.isEmpty) {
            self.userId = User().getField("id")
        }
        self.viewData["id"] = JSON(self.userId)
        let url = AppConfig.APP_URL+"/user_info/"+self.userId
        Request().get(url, successHandler: {(response) in self.loadDataToEdit(response)})
    }
    
    func loadDataToEdit(let response: NSData) {
        dispatch_async(dispatch_get_main_queue()) {
            let result = JSON(data: response)
            self.lblFirstName.text = result["first_name"].stringValue
            self.lblLastName.text  = result["last_name"].stringValue
            self.lblBrokerage.text = result["brokerage"].stringValue
            self.lblBiography.text = result["biography"].stringValue
            if(!result["url_image"].stringValue.isEmpty) {
                Utility().showPhoto(self.previewPhoto, imgPath: result["url_image"].stringValue)
            }
            if(!result["rating"].stringValue.isEmpty) {
                self.rating.image = UIImage(named: result["rating"].stringValue+"stars")
            }
        }
    }

}
