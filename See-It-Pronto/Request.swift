//
//  Request.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/8/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import Foundation
class Request {
    var debug:Bool = false

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
                print("AN ERROR HAS OCURRED SENDING POST REQUEST!")
                print(error); return
            }
            if(self.debug == true) {
                let responseString : String = String(data: data!, encoding: NSUTF8StringEncoding)!
                print(responseString)
            }
            successHandler(response: data!)
        }
        task.resume();
    }
 
    func put(url : String, var params : String, successHandler: (response: NSData) -> Void) {
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
            if(self.debug == true) {
                let responseString : String = String(data: data!, encoding: NSUTF8StringEncoding)!
                print(responseString)
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
                print("AN ERROR HAS OCURRED SENDING GET REQUEST!")
                print(error); return
            }
            if(self.debug == true) {
                let responseString : String = String(data: data!, encoding: NSUTF8StringEncoding)!
                print(responseString)
            }
            successHandler(response: data!)
        }
        task.resume();
    }
}
