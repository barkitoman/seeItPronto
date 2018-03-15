//
//  FeedBack1ViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/6/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class FeedBack1ViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    var viewData:JSON         = []
    var showStartMessage:Bool = false
    var showingRating:String  = ""
    var homeRating:String     = ""
    
    @IBOutlet weak var propertyComments: UITextView!
    @IBOutlet weak var homeRate1: UIButton!
    @IBOutlet weak var homeRate2: UIButton!
    @IBOutlet weak var homeRate3: UIButton!
    @IBOutlet weak var homeRate4: UIButton!
    @IBOutlet weak var homeRate5: UIButton!
    
    var animateDistance: CGFloat!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.propertyComments.delegate = self
        if(showStartMessage == true) {
         self.showIndications()
        }
        addRatingTarget()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }
    
    func showIndications() {
        Utility().displayAlert(self, title: "Message", message: "The agent is on their way. When agent finishes show you the property, please complete the following feedback", performSegue: "")
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
    
    @IBAction func btnSkip(_ sender: AnyObject) {
        let params = "id="+self.viewData["showing"]["id"].stringValue+"&showing_status=3&notification_feedback=1"
        let url    = AppConfig.APP_URL+"/showings/"+self.viewData["showing"]["id"].stringValue
        Request().put(url, params:params,controller:self,successHandler: {(response) in self.afterSkipRequest(response)});
    }
    
    func afterSkipRequest(_ response: Data) {
        let result = JSON(data: response)
        if(result["result"].bool == true) {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "FeedBack1ViewController", sender: self)
            }
        } else {
            Utility().displayAlert(self,title: "Error", message:"Error skipping, please try later", performSegue:"")
        }
    }
    
    @IBAction func btnNext(_ sender: AnyObject) {
        var params = "id="+self.viewData["showing"]["id"].stringValue+"&showing_status=3&feedback_property_comment="+self.propertyComments.text!
        params     = params+"&showing_rating_value="+self.showingRating+"&home_rating_value="+self.homeRating
        params     = params+"&user_id="+User().getField("id")+"&realtor_id="+self.viewData["showing"]["realtor_id"].stringValue
        params     = params+"&notification_feedback=1&property_id=\(self.viewData["showing"]["property_id"].stringValue)"
        let url    = AppConfig.APP_URL+"/showings/"+self.viewData["showing"]["id"].stringValue
        Request().put(url, params:params,controller:self,successHandler: {(response) in self.afterNextRequest(response)});
    }
    
    func afterNextRequest(_ response: Data) {
        let result = JSON(data: response)
        if(result["result"].bool == true) {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "FeedBack1ViewController", sender: self)
            }
        } else {
            var msg = "Error saving, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "FeedBack1ViewController") {
            let view: FeedBack2ViewController = segue.destination as! FeedBack2ViewController
            view.viewData  = self.viewData
        }
    }
    
    func addRatingTarget() {
        homeRate1.addTarget(self, action: #selector(FeedBack1ViewController.setRating(_:)), for: .touchUpInside)
        homeRate2.addTarget(self, action: #selector(FeedBack1ViewController.setRating(_:)), for: .touchUpInside)
        homeRate3.addTarget(self, action: #selector(FeedBack1ViewController.setRating(_:)), for: .touchUpInside)
        homeRate4.addTarget(self, action: #selector(FeedBack1ViewController.setRating(_:)), for: .touchUpInside)
        homeRate5.addTarget(self, action: #selector(FeedBack1ViewController.setRating(_:)), for: .touchUpInside)
    }
    
    @IBAction func setRating(_ button:UIButton) {
        let description = (button.titleLabel?.text)! as String
        let typeRating  = description.characters.split{$0 == "="}.map(String.init)
        let type        = typeRating[0] as String
        let rating      = typeRating[1] as String
        if(type == "home") {
            self.homeRating = rating
            homeRatingButtons(rating)
        }
    }
    
    func homeRatingButtons(_ rating:String) {
        homeRate1.setImage(UIImage(named: "0stars_alone"), for: UIControlState())
        homeRate2.setImage(UIImage(named: "0stars_alone"), for: UIControlState())
        homeRate3.setImage(UIImage(named: "0stars_alone"), for: UIControlState())
        homeRate4.setImage(UIImage(named: "0stars_alone"), for: UIControlState())
        homeRate5.setImage(UIImage(named: "0stars_alone"), for: UIControlState())
        if(rating == "1"){
            homeRate1.setImage(UIImage(named: "1stars_alone"), for: UIControlState())
        }else if(rating == "2") {
            homeRate1.setImage(UIImage(named: "1stars_alone"), for: UIControlState())
            homeRate2.setImage(UIImage(named: "1stars_alone"), for: UIControlState())
        }else if(rating == "3") {
            homeRate1.setImage(UIImage(named: "1stars_alone"), for: UIControlState())
            homeRate2.setImage(UIImage(named: "1stars_alone"), for: UIControlState())
            homeRate3.setImage(UIImage(named: "1stars_alone"), for: UIControlState())
        } else if(rating == "4") {
            homeRate1.setImage(UIImage(named: "1stars_alone"), for: UIControlState())
            homeRate2.setImage(UIImage(named: "1stars_alone"), for: UIControlState())
            homeRate3.setImage(UIImage(named: "1stars_alone"), for: UIControlState())
            homeRate4.setImage(UIImage(named: "1stars_alone"), for: UIControlState())
        } else if(rating == "5") {
            homeRate1.setImage(UIImage(named: "1stars_alone"), for: UIControlState())
            homeRate2.setImage(UIImage(named: "1stars_alone"), for: UIControlState())
            homeRate3.setImage(UIImage(named: "1stars_alone"), for: UIControlState())
            homeRate4.setImage(UIImage(named: "1stars_alone"), for: UIControlState())
            homeRate5.setImage(UIImage(named: "1stars_alone"), for: UIControlState())
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        let textFieldRect : CGRect = self.view.window!.convert(textView.bounds, from: textView)
        let viewRect : CGRect = self.view.window!.convert(self.view.bounds, from: self.view)
        let midline : CGFloat = textFieldRect.origin.y + 0.5 * textFieldRect.size.height
        let numerator : CGFloat = midline - viewRect.origin.y - MoveKeyboard.MINIMUM_SCROLL_FRACTION * viewRect.size.height
        let denominator : CGFloat = (MoveKeyboard.MAXIMUM_SCROLL_FRACTION - MoveKeyboard.MINIMUM_SCROLL_FRACTION) * viewRect.size.height
        var heightFraction : CGFloat = numerator / denominator
        if heightFraction < 0.0 {
            heightFraction = 0.0
        } else if heightFraction > 1.0 {
            heightFraction = 1.0
        }
        let orientation : UIInterfaceOrientation = UIApplication.shared.statusBarOrientation
        if (orientation == UIInterfaceOrientation.portrait || orientation == UIInterfaceOrientation.portraitUpsideDown) {
            animateDistance = floor(MoveKeyboard.PORTRAIT_KEYBOARD_HEIGHT * heightFraction)
        } else {
            animateDistance = floor(MoveKeyboard.LANDSCAPE_KEYBOARD_HEIGHT * heightFraction)
        }
        var viewFrame : CGRect = self.view.frame
        viewFrame.origin.y -= animateDistance
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(TimeInterval(MoveKeyboard.KEYBOARD_ANIMATION_DURATION))
        self.view.frame = viewFrame
        UIView.commitAnimations()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        var viewFrame : CGRect = self.view.frame
        viewFrame.origin.y += animateDistance
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(TimeInterval(MoveKeyboard.KEYBOARD_ANIMATION_DURATION))
        self.view.frame = viewFrame
        UIView.commitAnimations()
    }
}
