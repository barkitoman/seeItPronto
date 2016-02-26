//
//  User.swift
//  See-It-Pronto
//
//  Created by user114136 on 1/8/16.
//  Copyright © 2016 user114136. All rights reserved.
//


import Foundation
import UIKit
import CoreData
@objc(UserEntity)

class UserEntity: NSManagedObject {
    @NSManaged var id:String
    @NSManaged var role:String
    @NSManaged var name:String
    @NSManaged var access_token:String
    @NSManaged var expires_in:String
    @NSManaged var token_type:String
    @NSManaged var scope:String
    @NSManaged var email:String
    @NSManaged var password:String
    @NSManaged var realtor_id:String
 
}

class User {
    var existingItem : NSManagedObject!
    
    func find()->AnyObject{
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let contxt: NSManagedObjectContext = appDel.managedObjectContext
        let freq = NSFetchRequest(entityName:"User")
        var out:Array<AnyObject> = []
        do {
            try out = contxt.executeFetchRequest(freq)
        } catch {
            print("An error has ocurred")
        }
        return out
    }
    
    func getField(fieldName:String)->String{
        let user       = User().find()
        var out:String = ""
        if(user.count >= 1 && user[0] != nil) {
            let obj  = user[0] as! NSManagedObject
             out     = obj.valueForKey(fieldName) as! String
        }
        return out
    }
    
    func saveIfExists(userData:JSON) {
        //check if item exists
        if (self.find().count >= 1) {
            //Remove if exists
            self.deleteAllData()
        }
        self.save(userData)

    }
    
    func update(existingItem:NSManagedObject,userData:JSON) {
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let contxt: NSManagedObjectContext = appDel.managedObjectContext

        existingItem.setValue(userData["user"]["id"].stringValue,       forKey: "id")
        existingItem.setValue(userData["user"]["role"].stringValue,     forKey: "role")
        existingItem.setValue(userData["user"]["name"].stringValue,     forKey: "name")
        existingItem.setValue(userData["user"]["email"].stringValue,    forKey: "email")
        existingItem.setValue(userData["user"]["password"].stringValue, forKey: "password")
        existingItem.setValue(userData["expires_in"].stringValue,       forKey: "expires_in")
        existingItem.setValue(userData["access_token"].stringValue,     forKey: "access_token")
        existingItem.setValue(userData["scope"].stringValue,            forKey: "scope")
        existingItem.setValue(userData["token_type"].stringValue,       forKey: "token_type")
        existingItem.setValue(userData["realtor_id"].stringValue,       forKey: "realtor_id")
        do {
            try contxt.save()
        } catch let error as NSError {
            print("Error when sve. error : \(error) \(error.userInfo)")
        }
    }
    
    func save(userData:JSON) {
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let contxt: NSManagedObjectContext = appDel.managedObjectContext
        let en = NSEntityDescription.entityForName("User", inManagedObjectContext: contxt)
        //create instance of pur data model and inicilize
        let newItem = UserEntity(entity:en!, insertIntoManagedObjectContext:contxt)
        //map our properties
        newItem.id            = userData["user"]["id"].stringValue
        newItem.role          = userData["user"]["role"].stringValue
        newItem.name          = userData["user"]["name"].stringValue
        newItem.email         = userData["user"]["email"].stringValue
        newItem.password      = userData["user"]["password"].stringValue
        newItem.expires_in    = userData["expires_in"].stringValue
        newItem.access_token  = userData["access_token"].stringValue
        newItem.scope         = userData["scope"].stringValue
        newItem.token_type    = userData["token_type"].stringValue
        newItem.realtor_id    = userData["realtor_id"].stringValue
        do {
            try contxt.save()
        } catch let error as NSError {
            print("Error when save user. error : \(error) \(error.userInfo)")
        }
    }

    func delete(obj:NSManagedObject) {
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let contxt: NSManagedObjectContext = appDel.managedObjectContext
        contxt.deleteObject(obj)
        do {
            try contxt.save()
        } catch let error as NSError {
            print("Error deleting user. error : \(error) \(error.userInfo)")
        }
    }
    
    func deleteAllData() {
        let appDel        = UIApplication.sharedApplication().delegate as! AppDelegate
        let context       = appDel.managedObjectContext
        let coord         = appDel.persistentStoreCoordinator
        let fetchRequest  = NSFetchRequest(entityName: "User")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try coord.executeRequest(deleteRequest, withContext: context)
        } catch let error as NSError {
            debugPrint(error)
        }
    }
}


