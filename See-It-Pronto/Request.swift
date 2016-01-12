//
//  Request.swift
//  See-It-Pronto
//
//  Created by user114136 on 1/8/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import Foundation
class Request {

    func post(url : String, params : String, successHandler: (response: NSData) -> Void) {
        let url = NSURL(string: url)
        let params = String(params);
        let request = NSMutableURLRequest(URL: url!);
        request.HTTPMethod = "POST"
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            //in case of error
            if error != nil {
                print("AN ERROR HAS OCURRED!")
                print(error); return
            }
            successHandler(response: data!)
        }
        task.resume();
    }
    
    func get(url : String, successHandler: (response: NSData) -> Void) {
        let url = NSURL(string: url)
        let request = NSMutableURLRequest(URL: url!);
        request.HTTPMethod = "GET"
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            //in case of error
            if error != nil {
                print("AN ERROR HAS OCURRED!")
                print(error); return
            }
            successHandler(response: data!)
        }
        task.resume();
    }

}
