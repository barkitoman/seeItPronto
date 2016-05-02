//
//  ImageLoadingWithCache.swift
//  See-It-Pronto
//
//  Created by Deyson on 5/2/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import Foundation
import UIKit

class ImageLoadingWithCache {
    
    var imageCache = [String:UIImage]()
    
    func getImage(imgPath: String, imageView: UIImageView) {
        if let img = imageCache[imgPath] {
            self.setImage(imageView,img: img)
        } else {
            var url = NSURL(string: AppConfig.APP_URL+"/"+imgPath)
            if (imgPath.rangeOfString("http://") != nil || imgPath.rangeOfString("https://") != nil ){
                url = NSURL(string: imgPath)
            }
            let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) -> Void in
                if error != nil {
                    print("ERROR SHOWING IMAGE "+imgPath)
                } else {
                    if let httpResponse = response as? NSHTTPURLResponse {
                        if(httpResponse.statusCode == 200) {
                            let img = UIImage(data: data!)
                            self.imageCache[imgPath] = img
                            if(img != nil) {
                                self.setImage(imageView,img: img!)
                            }
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    func setImage(imageView: UIImageView, img:UIImage){
        dispatch_async(dispatch_get_main_queue()) {
            imageView.image = img
        }
    }
}
