//
//  FeedBack1ViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/6/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class FeedBack1ViewController: UIViewController {

    var viewData:JSON = []
    var showStartMessage:Bool = false
    var showingRating:String  = ""
    var homeRating:String     = ""
    var userRating:String     = ""
    
    @IBOutlet weak var showingComments: UITextView!
    @IBOutlet weak var showingRate1: UIButton!
    @IBOutlet weak var showingRate2: UIButton!
    @IBOutlet weak var showingRate3: UIButton!
    @IBOutlet weak var showingRate4: UIButton!
    @IBOutlet weak var showingRate5: UIButton!
    
    @IBOutlet weak var homeRate1: UIButton!
    @IBOutlet weak var homeRate2: UIButton!
    @IBOutlet weak var homeRate3: UIButton!
    @IBOutlet weak var homeRate4: UIButton!
    @IBOutlet weak var homeRate5: UIButton!
    
    @IBOutlet weak var agentRate1: UIButton!
    @IBOutlet weak var agentRate2: UIButton!
    @IBOutlet weak var agentRate3: UIButton!
    @IBOutlet weak var agentRate4: UIButton!
    @IBOutlet weak var agentRate5: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        if(showStartMessage == true) {
         self.showIndications()
        }
        addRatingTarget()
    }
    
    func showIndications() {
        Utility().displayAlert(self, title: "Message", message: "The agent is on their way. When agent finishes show you the property, please complete the following feedback", performSegue: "")
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
    
    @IBAction func btnSkip(sender: AnyObject) {
        let params = "id="+self.viewData["showing"]["id"].stringValue+"&showing_status=3&notification_feedback=1"
        let url    = AppConfig.APP_URL+"/showings/"+self.viewData["showing"]["id"].stringValue
        Request().put(url, params:params,successHandler: {(response) in self.afterSkipRequest(response)});
    }
    
    func afterSkipRequest(let response: NSData) {
        let result = JSON(data: response)
        if(result["result"].bool == true) {
            dispatch_async(dispatch_get_main_queue()) {
                self.performSegueWithIdentifier("FeedBack1ViewController", sender: self)
            }
        } else {
            Utility().displayAlert(self,title: "Error", message:"Error skipping, please try later", performSegue:"")
        }
    }
    
    @IBAction func btnNext(sender: AnyObject) {
        var params = "id="+self.viewData["showing"]["id"].stringValue+"&showing_status=3&feedback_showing_comment="+self.showingComments.text!
        params     = params+"&showing_rating_value="+self.showingRating+"&user_rating_value="+self.userRating+"&home_rating_value="+self.homeRating
        params     = params+"&user_id="+User().getField("id")+"&realtor_id="+self.viewData["showing"]["realtor_id"].stringValue
        params     = params+"&notification_feedback=1&property_id=\(self.viewData["showing"]["property_id"].stringValue)"
        let url    = AppConfig.APP_URL+"/showings/"+self.viewData["showing"]["id"].stringValue
        Request().put(url, params:params,successHandler: {(response) in self.afterNextRequest(response)});
    }
    
    func afterNextRequest(let response: NSData) {
        let result = JSON(data: response)
        if(result["result"].bool == true) {
            dispatch_async(dispatch_get_main_queue()) {
                self.performSegueWithIdentifier("FeedBack1ViewController", sender: self)
            }
        } else {
            var msg = "Error saving, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "FeedBack1ViewController") {
            let view: FeedBack2ViewController = segue.destinationViewController as! FeedBack2ViewController
            view.viewData  = self.viewData
        }
    }
    
    func addRatingTarget() {
        showingRate1.addTarget(self, action: "setRating:", forControlEvents: .TouchUpInside)
        showingRate2.addTarget(self, action: "setRating:", forControlEvents: .TouchUpInside)
        showingRate3.addTarget(self, action: "setRating:", forControlEvents: .TouchUpInside)
        showingRate4.addTarget(self, action: "setRating:", forControlEvents: .TouchUpInside)
        showingRate5.addTarget(self, action: "setRating:", forControlEvents: .TouchUpInside)
        
        homeRate1.addTarget(self, action: "setRating:", forControlEvents: .TouchUpInside)
        homeRate2.addTarget(self, action: "setRating:", forControlEvents: .TouchUpInside)
        homeRate3.addTarget(self, action: "setRating:", forControlEvents: .TouchUpInside)
        homeRate4.addTarget(self, action: "setRating:", forControlEvents: .TouchUpInside)
        homeRate5.addTarget(self, action: "setRating:", forControlEvents: .TouchUpInside)
        
        agentRate1.addTarget(self, action: "setRating:", forControlEvents: .TouchUpInside)
        agentRate2.addTarget(self, action: "setRating:", forControlEvents: .TouchUpInside)
        agentRate3.addTarget(self, action: "setRating:", forControlEvents: .TouchUpInside)
        agentRate4.addTarget(self, action: "setRating:", forControlEvents: .TouchUpInside)
        agentRate5.addTarget(self, action: "setRating:", forControlEvents: .TouchUpInside)
    }
    
    @IBAction func setRating(button:UIButton) {
        let description = (button.titleLabel?.text)! as String
        let typeRating = description.characters.split{$0 == "="}.map(String.init)
        let type   = typeRating[0] as String
        let rating = typeRating[1] as String
        if(type == "showing") {
            self.showingRating = rating
            showingRatingButtons(rating)
        }else if(type == "home") {
            self.homeRating = rating
            homeRatingButtons(rating)
        }else if(type == "user") {
            self.userRating = rating
            agentRatingButtons(rating)
        }
    }
    
    func showingRatingButtons(rating:String) {
        showingRate1.setImage(UIImage(named: "0stars_alone"), forState: UIControlState.Normal)
        showingRate2.setImage(UIImage(named: "0stars_alone"), forState: UIControlState.Normal)
        showingRate3.setImage(UIImage(named: "0stars_alone"), forState: UIControlState.Normal)
        showingRate4.setImage(UIImage(named: "0stars_alone"), forState: UIControlState.Normal)
        showingRate5.setImage(UIImage(named: "0stars_alone"), forState: UIControlState.Normal)
        if(rating == "1"){
            showingRate1.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
        }else if(rating == "2") {
            showingRate1.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
            showingRate2.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
        }else if(rating == "3") {
            showingRate1.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
            showingRate2.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
            showingRate3.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
        } else if(rating == "4") {
            showingRate1.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
            showingRate2.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
            showingRate3.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
            showingRate4.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
        } else if(rating == "5") {
            showingRate1.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
            showingRate2.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
            showingRate3.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
            showingRate4.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
            showingRate5.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
        }
    }
    
    func homeRatingButtons(rating:String) {
        homeRate1.setImage(UIImage(named: "0stars_alone"), forState: UIControlState.Normal)
        homeRate2.setImage(UIImage(named: "0stars_alone"), forState: UIControlState.Normal)
        homeRate3.setImage(UIImage(named: "0stars_alone"), forState: UIControlState.Normal)
        homeRate4.setImage(UIImage(named: "0stars_alone"), forState: UIControlState.Normal)
        homeRate5.setImage(UIImage(named: "0stars_alone"), forState: UIControlState.Normal)
        if(rating == "1"){
            homeRate1.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
        }else if(rating == "2") {
            homeRate1.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
            homeRate2.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
        }else if(rating == "3") {
            homeRate1.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
            homeRate2.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
            homeRate3.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
        } else if(rating == "4") {
            homeRate1.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
            homeRate2.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
            homeRate3.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
            homeRate4.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
        } else if(rating == "5") {
            homeRate1.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
            homeRate2.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
            homeRate3.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
            homeRate4.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
            homeRate5.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
        }
    }
    
    func agentRatingButtons(rating:String) {
        agentRate1.setImage(UIImage(named: "0stars_alone"), forState: UIControlState.Normal)
        agentRate2.setImage(UIImage(named: "0stars_alone"), forState: UIControlState.Normal)
        agentRate3.setImage(UIImage(named: "0stars_alone"), forState: UIControlState.Normal)
        agentRate4.setImage(UIImage(named: "0stars_alone"), forState: UIControlState.Normal)
        agentRate5.setImage(UIImage(named: "0stars_alone"), forState: UIControlState.Normal)
        if(rating == "1"){
            agentRate1.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
        }else if(rating == "2") {
            agentRate1.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
            agentRate2.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
        }else if(rating == "3") {
            agentRate1.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
            agentRate2.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
            agentRate3.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
        } else if(rating == "4") {
            agentRate1.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
            agentRate2.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
            agentRate3.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
            agentRate4.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
        } else if(rating == "5") {
            agentRate1.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
            agentRate2.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
            agentRate3.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
            agentRate4.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
            agentRate5.setImage(UIImage(named: "1stars_alone"), forState: UIControlState.Normal)
        }
    }
}
