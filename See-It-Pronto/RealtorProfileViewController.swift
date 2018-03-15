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
        DispatchQueue.main.async {
            BProgressHUD.showLoadingViewWithMessage("Loading...")
        }
        self.findUserInfo()
        let role = User().getField("id")
        if(role != "realtor") {
            self.btnPrevious.isHidden = true
            self.btnNext.isHidden = true
        }
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
    
    func findUserInfo() {
        self.userId = self.viewData["id"].stringValue
        if(self.userId.isEmpty) {
            self.userId = User().getField("id")
        }
        self.viewData["id"] = JSON(self.userId)
        let url = AppConfig.APP_URL+"/user_info/"+self.userId
        Request().get(url, successHandler: {(response) in self.loadDataToEdit(response)})
    }
    
    func loadDataToEdit(_ response: Data) {
        DispatchQueue.main.async {
            BProgressHUD.dismissHUD(0)
            let result = JSON(data: response)
            self.lblFirstName.text = result["first_name"].stringValue
            self.lblLastName.text  = result["last_name"].stringValue
            self.lblBrokerage.text = result["brokerage"].stringValue
            self.lblBiography.text = result["biography"].stringValue
            Utility().showPhoto(self.previewPhoto, imgPath: result["url_image"].stringValue, defaultImg: "default_user_photo")
            
            if(!result["rating"].stringValue.isEmpty) {
                self.rating.image = UIImage(named: result["rating"].stringValue+"stars")
            }
        }
    }

}
