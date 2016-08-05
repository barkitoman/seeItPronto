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
    
    @IBAction func btnBack(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath)
        let button = cell.viewWithTag(2) as! UIButton
        button.hidden = true
        let imageView = cell.viewWithTag(1) as! UIImageView
        let img = self.viewData["images"].arrayObject
        let property = JSON(img![indexPath.row])
        
        Utility().showPhoto(imageView, imgPath: property.stringValue, defaultImg: "default_user_photo")
        //imageView.image = UIImage(named: property.stringValue)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView,  numberOfItemsInSection section: Int) -> Int {
        return self.viewData["images"].count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        cell?.superview?.bringSubviewToFront(cell!)
        
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: ({
            cell?.frame = collectionView.bounds
            collectionView.scrollEnabled = false
            let button = cell?.viewWithTag(2) as! UIButton
            button.hidden = false
            button.addTarget( self, action: Selector("backClose"), forControlEvents: UIControlEvents.TouchUpInside)
        }), completion: { (finished: Bool) -> Void in})
        
    }
    
    func backClose(){
        let indexPath = collectionView.indexPathsForSelectedItems()! as [NSIndexPath]
        self.collectionView.scrollEnabled = true
        self.collectionView.reloadItemsAtIndexPaths(indexPath)
    }
   
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
