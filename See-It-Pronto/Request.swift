//
//  Request.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/8/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration

class Request {
    var debug:Bool = false

    func post(url : String, params : String,controller:UIViewController, successHandler: (response: NSData) -> Void) {
        if(self.internet()){
            let url = NSURL(string: url)
            let params = String(params);
            let request = NSMutableURLRequest(URL: url!);
            request.HTTPMethod = "POST"
            request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
                data, response, error in
                //in case of error
                if error != nil {
                    print("AN ERROR HAS OCURRED SENDING POST REQUEST!")
                    print(error); return
                }
                let responseString : String = String(data: data!, encoding: NSUTF8StringEncoding)!
                print(responseString)
                
                successHandler(response: data!)
            }
            task.resume();
        } else {
            Utility().displayAlert(controller, title: "Alert", message: "You are no longer connected to the internet. See It Pronto requires access to the internet to provide you with accurate information", performSegue: "")
        }
    }
    
    func internet()->Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        guard let defaultRouteReachability = withUnsafePointer(&zeroAddress, {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else {
            return false
        }
            
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.Reachable)
        let needsConnection = flags.contains(.ConnectionRequired)
        return (isReachable && !needsConnection)
    }
 
    func put(url : String, var params : String,controller:UIViewController, successHandler: (response: NSData) -> Void) {
        if(self.internet()){
            let url = NSURL(string: url)
            params+="&_method=PUT"
            let params = String(params);
            let request = NSMutableURLRequest(URL: url!);
            request.HTTPMethod = "POST"
            request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
                data, response, error in
                //in case of error
                if error != nil {
                    print("AN ERROR HAS OCURRED SENDING PUT REQUEST!")
                    print(error); return
                }
                successHandler(response: data!)
            }
            task.resume();
        } else {
            Utility().displayAlert(controller, title: "Alert", message: "You are no longer connected to the internet. See It Pronto requires access to the internet to provide you with accurate information", performSegue: "")
        }
    }
    
    func get(url : String, successHandler: (response: NSData) -> Void) {
        let url = NSURL(string: url)
        let request = NSMutableURLRequest(URL: url!);
        request.HTTPMethod = "GET"
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            //in case of error
            if error != nil {
                print("AN ERROR HAS OCURRED SENDING GET REQUEST!")
                print(error); return
            }
            successHandler(response: data!)
        }
        task.resume();
    }
    
    func delete(url : String, var params : String, successHandler: (response: NSData) -> Void) {
        let url = NSURL(string: url)
        params+="&_method=DELETE"
        let params = String(params);
        let request = NSMutableURLRequest(URL: url!);
        request.HTTPMethod = "POST"
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            //in case of error
            if error != nil {
                print("AN ERROR HAS OCURRED SENDING DELETE REQUEST!")
                print(error); return
            }
            successHandler(response: data!)
        }
        task.resume();
    }
    
    func homePost(url : String, params : String,controller:UIViewController, successHandler: (response: NSData) -> Void) {
        if(self.internet()){
            let url = NSURL(string: url)
            let params = String(params);
            let request = NSMutableURLRequest(URL: url!);
            request.HTTPMethod = "POST"
            request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
                data, response, error in
                //in case of error
                if error != nil {
                    print("AN ERROR HAS OCURRED SENDING REQUEST FOR FIND PROPERTIES!")
                    print(error);
                }
                
                if let _ = data {
                    successHandler(response: data!)
                }
            }
            task.resume();
        } else {
            Utility().displayAlert(controller, title: "Alert", message: "You are no longer connected to the internet. See It Pronto requires access to the internet to provide you with accurate information", performSegue: "")
        }
    }
}
