//
//  MoreImageViewController.swift
//  See-It-Pronto
//
//  Created by Usuario Mac on 4/08/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class MoreImageViewController: UIViewController,  UICollectionViewDelegate {
    
    var imagesArray = [String]()
    @IBOutlet weak var collectionView: UICollectionView!
    
    var viewData:JSON = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let button = cell.viewWithTag(2) as! UIButton
        button.isHidden = true
        let imageView = cell.viewWithTag(1) as! UIImageView
        let img = self.viewData["images"].arrayObject
        let property = JSON(img![indexPath.row])
        
        Utility().showPhoto(imageView, imgPath: property.stringValue, defaultImg: "default_user_photo")
        //imageView.image = UIImage(named: property.stringValue)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,  numberOfItemsInSection section: Int) -> Int {
        return self.viewData["images"].count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.superview?.bringSubview(toFront: cell!)
        
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: ({
            cell?.frame = collectionView.bounds
            collectionView.isScrollEnabled = false
            let button = cell?.viewWithTag(2) as! UIButton
            button.isHidden = false
            button.addTarget( self, action: #selector(MoreImageViewController.backClose), for: UIControlEvents.touchUpInside)
        }), completion: { (finished: Bool) -> Void in})
        
    }
    
    func backClose(){
        let indexPath = collectionView.indexPathsForSelectedItems! as [IndexPath]
        self.collectionView.isScrollEnabled = true
        self.collectionView.reloadItems(at: indexPath)
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
