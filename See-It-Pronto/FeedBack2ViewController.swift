//
//  FeedBack2ViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/6/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class FeedBack2ViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate {

    var viewData:JSON = []
    @IBOutlet weak var txtAgentComments: UITextView!
    var animateDistance: CGFloat!
    var userRating:String = ""
    @IBOutlet weak var agentRate1: UIButton!
    @IBOutlet weak var agentRate2: UIButton!
    @IBOutlet weak var agentRate3: UIButton!
    @IBOutlet weak var agentRate4: UIButton!
    @IBOutlet weak var agentRate5: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtAgentComments.delegate = self
        addRatingTarget()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }
    
    func addRatingTarget() {
        agentRate1.addTarget(self, action: #selector(FeedBack2ViewController.setRating(_:)), for: .touchUpInside)
        agentRate2.addTarget(self, action: #selector(FeedBack2ViewController.setRating(_:)), for: .touchUpInside)
        agentRate3.addTarget(self, action: #selector(FeedBack2ViewController.setRating(_:)), for: .touchUpInside)
        agentRate4.addTarget(self, action: #selector(FeedBack2ViewController.setRating(_:)), for: .touchUpInside)
        agentRate5.addTarget(self, action: #selector(FeedBack2ViewController.setRating(_:)), for: .touchUpInside)
    }
    
    @IBAction func setRating(_ button:UIButton) {
        let description = (button.titleLabel?.text)! as String
        let typeRating = description.characters.split{$0 == "="}.map(String.init)
        let type   = typeRating[0] as String
        let rating = typeRating[1] as String
        if(type == "user") {
            self.userRating = rating
            agentRatingButtons(rating)
        }
    }
    
    func agentRatingButtons(_ rating:String) {
        agentRate1.setImage(UIImage(named: "0stars_alone"), for: UIControlState())
        agentRate2.setImage(UIImage(named: "0stars_alone"), for: UIControlState())
        agentRate3.setImage(UIImage(named: "0stars_alone"), for: UIControlState())
        agentRate4.setImage(UIImage(named: "0stars_alone"), for: UIControlState())
        agentRate5.setImage(UIImage(named: "0stars_alone"), for: UIControlState())
        if(rating == "1"){
            agentRate1.setImage(UIImage(named: "1stars_alone"), for: UIControlState())
        }else if(rating == "2") {
            agentRate1.setImage(UIImage(named: "1stars_alone"), for: UIControlState())
            agentRate2.setImage(UIImage(named: "1stars_alone"), for: UIControlState())
        }else if(rating == "3") {
            agentRate1.setImage(UIImage(named: "1stars_alone"), for: UIControlState())
            agentRate2.setImage(UIImage(named: "1stars_alone"), for: UIControlState())
            agentRate3.setImage(UIImage(named: "1stars_alone"), for: UIControlState())
        } else if(rating == "4") {
            agentRate1.setImage(UIImage(named: "1stars_alone"), for: UIControlState())
            agentRate2.setImage(UIImage(named: "1stars_alone"), for: UIControlState())
            agentRate3.setImage(UIImage(named: "1stars_alone"), for: UIControlState())
            agentRate4.setImage(UIImage(named: "1stars_alone"), for: UIControlState())
        } else if(rating == "5") {
            agentRate1.setImage(UIImage(named: "1stars_alone"), for: UIControlState())
            agentRate2.setImage(UIImage(named: "1stars_alone"), for: UIControlState())
            agentRate3.setImage(UIImage(named: "1stars_alone"), for: UIControlState())
            agentRate4.setImage(UIImage(named: "1stars_alone"), for: UIControlState())
            agentRate5.setImage(UIImage(named: "1stars_alone"), for: UIControlState())
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
    
    func afterBuyWithAgentButton(_ response: Data) {
        let result = JSON(data: response)
        if(result["result"].bool == true) {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "FeedBack2ViewController", sender: self)
            }
        } else {
            var msg = "Error loading the next step, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }
    
    @IBAction func btnPrev(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func btnNext(_ sender: AnyObject) {
        var params = "id=\(self.viewData["showing"]["id"].stringValue)&showing_status=3&realtor_id=\(self.viewData["showing"]["realtor_id"].stringValue)"
        params     = params+"&feedback_realtor_comment=\(self.txtAgentComments.text!)&user_rating_value=\(self.userRating)&user_id\(User().getField("id"))"
        params     = params+"&send_broker_email=1&send_broker_email=1&broker_email=\(User().getField("broker_email"))"
        let url    = AppConfig.APP_URL+"/showings/"+self.viewData["showing"]["id"].stringValue
        Request().put(url, params:params,controller:self,successHandler: {(response) in self.afterNextRequest(response)});
    }
    
    func afterNextRequest(_ response: Data) {
        let result = JSON(data: response)
        if(result["result"].bool == true) {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "FeedBack2ViewController", sender: self)
            }
        } else {
            var msg = "Error saving, please try later"
            if(result["msg"].stringValue != "") {
                msg = result["msg"].stringValue
            }
            Utility().displayAlert(self,title: "Error", message:msg, performSegue:"")
        }
    }
    
    @IBAction func bntSkip(_ sender: AnyObject) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "FeedBack2ViewController", sender: self)
        }
    }
    
    @IBAction func btnBack(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "FeedBack2ViewController") {
            let view: FeedBack3ViewController = segue.destination as! FeedBack3ViewController
            view.viewData  = self.viewData
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
