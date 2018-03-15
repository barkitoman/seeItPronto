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
    
    func getImage(_ imgPath: String, imageView: UIImageView) {
        if let img = imageCache[imgPath] {
            self.setImage(imageView,img: img)
        } else {
            var url = URL(string: AppConfig.APP_URL+"/"+imgPath)
            if (imgPath.range(of: "http://") != nil || imgPath.range(of: "https://") != nil ){
                url = URL(string: imgPath)
            }
            let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) -> Void in
                if error != nil {
                    print("ERROR SHOWING IMAGE "+imgPath)
                } else {
                    if let httpResponse = response as? HTTPURLResponse {
                        if(httpResponse.statusCode == 200) {
                            let img = UIImage(data: data!)
                            self.imageCache[imgPath] = img
                            if(img != nil) {
                                self.setImage(imageView,img: img!)
                            }
                        }
                    }
                }
            }) 
            task.resume()
        }
    }
    
    func setImage(_ imageView: UIImageView, img:UIImage){
        DispatchQueue.main.async {
            imageView.image = img
        }
    }
}
