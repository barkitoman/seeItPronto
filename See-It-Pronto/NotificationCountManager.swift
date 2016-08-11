//
//  NotificationCountManager.swift
//  See-It-Pronto
//
//  Created by Deyson on 8/11/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import Foundation
import UIKit
import CoreData
@objc(NotificationCountEntity)

class NotificationCountEntity: NSManagedObject {
    @NSManaged var count_number:String
    
}

class NotificationCount {
    var existingItem : NSManagedObject!
    
    func find()->AnyObject{
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let contxt: NSManagedObjectContext = appDel.managedObjectContext
        let freq = NSFetchRequest(entityName:"NotificationCount")
        var out:Array<AnyObject> = []
        do {
            try out = contxt.executeFetchRequest(freq)
        } catch {
            print("An error has ocurred")
        }
        return out
    }
    
    func getField(fieldName:String)->String{
        let notificationCount       = NotificationCount().find()
        var out:String = ""
        if(notificationCount.count >= 1 && notificationCount[0] != nil) {
            let obj  = notificationCount[0] as! NSManagedObject
            if(obj.valueForKey(fieldName) != nil) {
                out = obj.valueForKey(fieldName) as! String
            }
        }
        return out
    }
    
    func increaseCount(value:String) {
        var currentCount = NotificationCount().getField("count_number")
        if(currentCount == "") { currentCount = "0" }
        if(value != "") {
            if let currentInt = Int(currentCount)  {
                if let newVal     = Int(value) {
                    let total      = currentInt + newVal
                    let totalStr   = "\(total)"
                    NotificationCount().saveOne(totalStr)
                } else {
                    NotificationCount().saveOne("0")
                }
            } else {
                NotificationCount().saveOne("0")
            }
        }
    }
    
    func decreaseCount(value:String) {
        var currentCount = NotificationCount().getField("count_number")
        if(currentCount == "") { currentCount = "0" }
        if(value != "") {
            if let currentInt = Int(currentCount) {
                if(currentInt > 0) {
                    if let newVal = Int(value) {
                        let total      = currentInt - newVal
                        let totalStr   = "\(total)"
                        NotificationCount().saveOne(totalStr)
                    }
                } else {
                    NotificationCount().saveOne("0")
                }
            } else {
                NotificationCount().saveOne("0")
            }
        }
    }
    
    func saveOne(notificationCountData:String) {
        //check if item exists
        if (self.find().count >= 1) {
            //Remove if exists
            self.deleteAllData()
        }
        self.save(notificationCountData)
    }
    
    func save(notificationCountData:String) {
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let contxt: NSManagedObjectContext = appDel.managedObjectContext
        contxt.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        let en = NSEntityDescription.entityForName("NotificationCount", inManagedObjectContext: contxt)
        //create instance of pur data model and inicilize
        let newItem = NotificationCountEntity(entity:en!, insertIntoManagedObjectContext:contxt)
        //map our properties
        newItem.count_number = notificationCountData

        do {
            try contxt.save()
        } catch let error as NSError {
            print("Error when save NotificationCountEntity. error : \(error.userInfo)")
        }
    }
    
    func updateField(field:String,value:String) {
        let notificationCount       = NotificationCount().find()
        if(notificationCount.count >= 1 && notificationCount[0] != nil) {
            let obj  = notificationCount[0] as! NSManagedObject
            obj.setValue(value as String, forKey: field)
        }
    }
    
    func deleteAllData() {
        let appDel        = UIApplication.sharedApplication().delegate as! AppDelegate
        let context       = appDel.managedObjectContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        let coord         = appDel.persistentStoreCoordinator
        let fetchRequest  = NSFetchRequest(entityName: "NotificationCount")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try coord.executeRequest(deleteRequest, withContext: context)
        } catch let error as NSError {
            print("Error deleting notificationCount. error : \(error.userInfo)")
        }
    }
}


