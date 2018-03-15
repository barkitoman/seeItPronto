//
//  ViewController.swift
//  See-It-Pronto
//
//  Created by Deyson on 12/18/15.
//  Copyright © 2015 user114136. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    fileprivate let internvalSeconds:TimeInterval = 3
    fileprivate var timer: Timer?
    var login = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startSetInterval()
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func goToLogin() {
        if self.timer != nil { self.stopInterval()}
        login = automaticLogin()
        if (login == false) {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "showMap", sender: self)
            }
        }
    }
    
    func automaticLogin()->Bool {
        let userId = User().getField("id")
        let role   = User().getField("role")
        let accessToken = User().getField("access_token")
        var out = false
        if(!userId.isEmpty && !role.isEmpty && !accessToken.isEmpty) {
            if(role == "realtor") {
                DispatchQueue.main.async {
                    let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    let viewController : ReadyToWorkViewController = mainStoryboard.instantiateViewController(withIdentifier: "ReadyToWorkViewController") as! ReadyToWorkViewController
                    self.navigationController?.show(viewController, sender: nil)
                }
                out = true
            } else if (role == "buyer") {
                DispatchQueue.main.async {
                    let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    let viewController : BuyerHomeViewController = mainStoryboard.instantiateViewController(withIdentifier: "BuyerHomeViewController") as! BuyerHomeViewController
                    self.navigationController?.show(viewController, sender: nil)
                }
                out = true
            }
        }
        if(!userId.isEmpty && !role.isEmpty && accessToken.isEmpty) {
            User().deleteAllData()
        }
        return out
    }
    
    func startSetInterval() {
        if self.timer != nil { self.stopInterval()}
        self.timer = Timer.scheduledTimer(timeInterval: self.internvalSeconds,
            target:self,
            selector:#selector(ViewController.goToLogin),
            userInfo:nil,
            repeats:true)
    }
    
    func stopInterval() {
        self.timer!.invalidate()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showMap") {
            let view: BuyerHomeViewController = segue.destination as! BuyerHomeViewController
            view.session  = login
        }
    }
    
}

