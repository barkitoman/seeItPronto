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
    @NSManaged var username:String
    @NSManaged var password:String
 
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

        existingItem.setValue(userData["id"].stringValue,           forKey: "id")
        existingItem.setValue(userData["role"].stringValue,         forKey: "role")
        existingItem.setValue(userData["name"].stringValue,         forKey: "name")
        existingItem.setValue(userData["username"].stringValue,     forKey: "username")
        existingItem.setValue(userData["password"].stringValue,     forKey: "password")
        existingItem.setValue(userData["expires_in"].stringValue,   forKey: "expires_in")
        existingItem.setValue(userData["access_token"].stringValue, forKey: "access_token")
        existingItem.setValue(userData["scope"].stringValue,        forKey: "scope")
        existingItem.setValue(userData["token_type"].stringValue,   forKey: "token_type")
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
        newItem.id            = userData["id"].stringValue
        newItem.role          = userData["role"].stringValue
        newItem.name          = userData["name"].stringValue
        newItem.username      = userData["username"].stringValue
        newItem.password      = userData["password"].stringValue
        newItem.expires_in    = userData["expires_in"].stringValue
        newItem.access_token  = userData["access_token"].stringValue
        newItem.scope         = userData["scope"].stringValue
        newItem.token_type    = userData["token_type"].stringValue
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
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let contxt: NSManagedObjectContext = appDel.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "User")
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try contxt.executeFetchRequest(fetchRequest)
            for managedObject in results {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                contxt.deleteObject(managedObjectData)
            }
        } catch let error as NSError {
            print("Error deleting all data in User. error : \(error) \(error.userInfo)")
        }
    }
}

