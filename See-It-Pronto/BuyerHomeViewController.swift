//
//  BuyerHomeViewController.swift
//  See-It-Pronto
//
//  Created by user114136 on 1/5/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class BuyerHomeViewController: UIViewController {

    var viewData:JSON = []
    @IBOutlet weak var Map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMap()
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
    
    func loadMap() {
        let location = CLLocationCoordinate2DMake(41.878, -87.629)
        
        let span = MKCoordinateSpanMake(0.2, 0.2)
        let region = MKCoordinateRegion(center: location, span: span)
        Map.setRegion(region, animated: true)
        
        let anotation = MKPointAnnotation()
        anotation.coordinate = location
        anotation.title = "Pizza"
        anotation.subtitle = "good job"
        Map.addAnnotation(anotation)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    }

}
