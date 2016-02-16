//
//  SearchViewController.swift
//  See-It-Pronto
//
//  Created by user114136 on 2/16/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentSize.height = 1100
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

    func animateWhenViewAppear(){
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.frame = CGRectMake(self.view.bounds.size.width, 0, self.view.bounds.size.width,self.view.bounds.size.height)
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func animateWhenViewDisappear(){
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.frame = CGRectMake(-self.view.bounds.size.width, 0, self.view.bounds.size.width,self.view.bounds.size.height)
            self.view.layoutIfNeeded()
            self.view.backgroundColor = UIColor.clearColor()
            }, completion: { (finished) -> Void in
                self.willMoveToParentViewController(nil)
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
        })
    }
    
    @IBAction func btnBack(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    }

}
