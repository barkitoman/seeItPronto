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

    func post(_ url : String, params : String,controller:UIViewController, successHandler: @escaping (_ response: Data) -> Void) {
        if(self.internet()){
            let url = URL(string: url)
            let params = String(params);
            let request = NSMutableURLRequest(url: url!);
            request.httpMethod = "POST"
            request.httpBody = params?.data(using: String.Encoding.utf8)
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: {
                data, response, error in
                //in case of error
                if error != nil {
                    print("AN ERROR HAS OCURRED SENDING POST REQUEST!")
                    print(error); return
                }
                
                successHandler(response: data!)
            }) 
            task.resume();
        } else {
            Utility().displayAlert(controller, title: "Alert", message: "You are no longer connected to the internet. See It Pronto! requires access to the internet to provide you with accurate information", performSegue: "")
        }
    }
    
    func internet()->Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else {
            return false
        }
            
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
 
    func put(_ url : String, params : String,controller:UIViewController, successHandler: @escaping (_ response: Data) -> Void) {
        var params = params
        if(self.internet()){
            let url = URL(string: url)
            params+="&_method=PUT"
            let params = String(params);
            let request = NSMutableURLRequest(url: url!);
            request.httpMethod = "POST"
            request.httpBody = params?.data(using: String.Encoding.utf8)
        
            let task = URLSession.shared.dataTask(with: request, completionHandler: {
                data, response, error in
                //in case of error
                if error != nil {
                    print("AN ERROR HAS OCURRED SENDING PUT REQUEST!")
                    print(error); return
                }
                successHandler(response: data!)
            }) 
            task.resume();
        } else {
            Utility().displayAlert(controller, title: "Alert", message: "You are no longer connected to the internet. See It Pronto! requires access to the internet to provide you with accurate information", performSegue: "")
        }
    }
    
    func get(_ url : String, successHandler: @escaping (_ response: Data) -> Void) {
        let url = URL(string: url)
        let request = NSMutableURLRequest(url: url!);
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            //in case of error
            if error != nil {
                print("AN ERROR HAS OCURRED SENDING GET REQUEST!")
                print(error); return
            }
            successHandler(response: data!)
        }) 
        task.resume();
    }
    
    func delete(_ url : String, params : String, successHandler: @escaping (_ response: Data) -> Void) {
        var params = params
        let url = URL(string: url)
        params+="&_method=DELETE"
        let params = String(params);
        let request = NSMutableURLRequest(url: url!);
        request.httpMethod = "POST"
        request.httpBody = params.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            //in case of error
            if error != nil {
                print("AN ERROR HAS OCURRED SENDING DELETE REQUEST!")
                print(error); return
            }
            successHandler(response: data!)
        }) 
        task.resume();
    }
    
    func homePost(_ url : String, params : String,controller:UIViewController, successHandler: @escaping (_ response: Data) -> Void) {
        if(self.internet()){
            let url = URL(string: url)
            if(url != nil) {
                let params = String(params);
                let request = NSMutableURLRequest(url: url!);
                request.httpMethod = "POST"
                request.httpBody = params?.data(using: String.Encoding.utf8)
            
                let task = URLSession.shared.dataTask(with: request, completionHandler: {
                    data, response, error in
                    //in case of error
                    if error != nil {
                        print("AN ERROR HAS OCURRED SENDING REQUEST FOR FIND PROPERTIES!")
                        print(error);
                    }
                
                    if let _ = data {
                        successHandler(response: data!)
                    }
                }) 
                task.resume();
            } else {
                Utility().displayAlert(controller, title: "Alert", message: "You are no longer connected to the internet. See It Pronto! requires access to the internet to provide you with accurate information", performSegue: "")
            }
        }
    }
}
