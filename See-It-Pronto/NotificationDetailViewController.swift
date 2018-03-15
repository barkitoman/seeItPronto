//
//  NotificationDetailViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 4/5/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class NotificationDetailViewController: UIViewController {

    var viewData:JSON = []
    var showingId:String = ""

    @IBOutlet weak var propertyImage: UIImageView!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var propertyDescription: UILabel!
    @IBOutlet weak var showingDate: UILabel!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.findShowing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    @IBAction func btnBack(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }

    func findShowing() {
        let url = AppConfig.APP_URL+"/get_showing_details/"+self.showingId+"/"+User().getField("id")
        Request().get(url, successHandler: {(response) in self.loadShowingData(response)})
    }
    
    func loadShowingData(_ response: Data) {
        let result = JSON(data: response)
        DispatchQueue.main.async {
            self.viewData = result
            if(result["property"]["id"].stringValue.isEmpty) {
                self.propertyNoExistMessage()
            }
            self.address.text  = result["property"]["address"].stringValue
            self.lblPrice.text = Utility().formatCurrency(result["property"]["price"].stringValue)
            var description = ""
            description += "Bed "+result["property"]["bedrooms"].stringValue+"/"
            description += "Bath "+result["property"]["bathrooms"].stringValue
            if(!result["property"]["type"].stringValue.isEmpty) {
                description = description+"/ "+result["property"]["type"].stringValue
            }
            if(!result["property"]["square_feed"].stringValue.isEmpty) {
                description = description+"/ "+result["property"]["square_feed"].stringValue+" SqrFt"
            }
            self.propertyDescription.text = description
            self.showingDate.text = result["showing"]["nice_date"].stringValue
            if(!result["property"]["image"].stringValue.isEmpty) {
                Utility().showPhoto(self.propertyImage, imgPath: result["property"]["image"].stringValue)
            }
        }
    }
    
    func propertyNoExistMessage() {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title:"Message", message: "The details of this property are not available at this time", preferredStyle: .alert)
            let homeAction = UIAlertAction(title: "Home", style: UIAlertActionStyle.default) {
                UIAlertAction in
                Utility().goHome(self)
            }
            alertController.addAction(homeAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
