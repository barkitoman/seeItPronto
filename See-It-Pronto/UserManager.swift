//
//  User.swift
//  See-It-Pronto
//
//  Created by Deyson on 1/8/16.
//  Copyright © 2016 Deyson. All rights reserved.
//


import Foundation
import UIKit
import CoreData
@objc(UserEntity)

class UserEntity: NSManagedObject {
    @NSManaged var id:String
    @NSManaged var role:String
    @NSManaged var first_name:String
    @NSManaged var last_name:String
    @NSManaged var access_token:String
    @NSManaged var expires_in:String
    @NSManaged var token_type:String
    @NSManaged var scope:String
    @NSManaged var email:String
    @NSManaged var password:String
    @NSManaged var realtor_id:String
    @NSManaged var mls_id:String
    @NSManaged var is_login:String
    @NSManaged var device_token_id:String
    @NSManaged var broker_email:String
    @NSManaged var active_for_showing:String
    @NSManaged var stripe_subscription_active:String
    @NSManaged var license:String
 
}

class User {
    var existingItem : NSManagedObject!
    
    func find()->AnyObject{
        let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let contxt: NSManagedObjectContext = appDel.managedObjectContext
        let freq = NSFetchRequest<NSFetchRequestResult>(entityName:"User")
        var out:Array<AnyObject> = []
        do {
            try out = contxt.fetch(freq)
        } catch {
            print("An error has ocurred")
        }
        return out as AnyObject
    }
    
    func getField(_ fieldName:String)->String{
        let user       = User().find()
        var out:String = ""
        if(user.count >= 1) {
            if let dataObj:AnyObject = user.objectAtIndex(0)  {
                let obj  = dataObj as! NSManagedObject
                if(obj.value(forKey: fieldName) != nil) {
                    out = obj.value(forKey: fieldName) as! String
                }
            }
        }
        return out
    }
    
    func saveOne(_ userData:JSON) {
        //check if item exists
        if (self.find().count >= 1) {
            //Remove if exists
            self.deleteAllData()
        }
        self.save(userData)

    }
    
    func save(_ userData:JSON) {
        let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let contxt: NSManagedObjectContext = appDel.managedObjectContext
        contxt.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        let en = NSEntityDescription.entity(forEntityName: "User", in: contxt)
        //create instance of pur data model and inicilize
        let newItem = UserEntity(entity:en!, insertInto:contxt)
        //map our properties
        newItem.id              = userData["user"]["id"].stringValue
        newItem.role            = userData["user"]["role"].stringValue
        newItem.first_name      = userData["user"]["first_name"].stringValue
        newItem.last_name       = userData["user"]["last_name"].stringValue
        newItem.email           = userData["user"]["email"].stringValue
        newItem.password        = userData["user"]["password"].stringValue
        newItem.expires_in      = userData["expires_in"].stringValue
        newItem.access_token    = userData["access_token"].stringValue
        newItem.scope           = userData["scope"].stringValue
        newItem.token_type      = userData["token_type"].stringValue
        newItem.realtor_id      = userData["realtor_id"].stringValue
        newItem.mls_id          = userData["user"]["mls_id"].stringValue
        newItem.is_login        = userData["user"]["is_login"].stringValue
        newItem.device_token_id = userData["user"]["device_token_id"].stringValue
        newItem.broker_email    = userData["user"]["broker_email"].stringValue
        newItem.active_for_showing = userData["user"]["active_for_showing"].stringValue
        newItem.stripe_subscription_active  = userData["user"]["stripe_subscription_active"].stringValue
        newItem.license  = userData["user"]["license"].stringValue
        
        do {
            try contxt.save()
        } catch let error as NSError {
            print("Error when save user. error : \(error.userInfo)")
        }
    }
    
    func updateField(_ field:String,value:String) {
        let user = User().find()
        if(user.count >= 1) {
            if let dataObj:AnyObject = user.objectAtIndex(0)  {
                let obj  = dataObj as! NSManagedObject
                obj.setValue(value as String, forKey: field)
            }
        }
    }
    
    func deleteAllData() {
        let appDel        = UIApplication.shared.delegate as! AppDelegate
        let context       = appDel.managedObjectContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        let coord         = appDel.persistentStoreCoordinator
        let fetchRequest  = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try coord.execute(deleteRequest, with: context)
        } catch let error as NSError {
            print("Error deleting user. error : \(error.userInfo)")
        }
    }
}


