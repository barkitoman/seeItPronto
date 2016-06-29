//
//  DeviceManager.swift
//  See-It-Pronto
//
//  Created by Deyson on 6/29/16.
//  Copyright © 2016 user114136. All rights reserved.


import Foundation
import UIKit
import CoreData
@objc(DeviceEntity)

class DeviceEntity: NSManagedObject {
    @NSManaged var device_token_id:String
    
}

class DeviceManager {
    var existingItem : NSManagedObject!
    
    func find()->AnyObject{
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let contxt: NSManagedObjectContext = appDel.managedObjectContext
        let freq = NSFetchRequest(entityName:"DeviceManager")
        var out:Array<AnyObject> = []
        do {
            try out = contxt.executeFetchRequest(freq)
        } catch {
            print("An error has ocurred")
        }
        return out
    }
    
    func getField(fieldName:String)->String{
        let deviceConfig = DeviceManager().find()
        var out:String   = ""
        if(deviceConfig.count >= 1 && deviceConfig[0] != nil) {
            let obj  = deviceConfig[0] as! NSManagedObject
            if(obj.valueForKey(fieldName) != nil) {
                out = obj.valueForKey(fieldName) as! String
            }
        }
        return out
    }
    
    func saveOne(configData:JSON) {
        //check if item exists
        if (DeviceManager().find().count >= 1) {
            //Remove if exists
            self.deleteAllData()
        }
        self.save(configData)
    }
    
    func save(deviceData:JSON) {
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let contxt: NSManagedObjectContext = appDel.managedObjectContext
        let en = NSEntityDescription.entityForName("DeviceManager", inManagedObjectContext: contxt)
        //create instance of pur data model and inicilize
        let newItem = DeviceEntity(entity:en!, insertIntoManagedObjectContext:contxt)
        //map our properties
        newItem.device_token_id = deviceData["device_token_id"].stringValue

        do {
            try contxt.save()
        } catch let error as NSError {
            print("Error when save search config. error : \(error) \(error.userInfo)")
        }
    }
    
    func deleteAllData() {
        let appDel        = UIApplication.sharedApplication().delegate as! AppDelegate
        let context       = appDel.managedObjectContext
        let coord         = appDel.persistentStoreCoordinator
        let fetchRequest  = NSFetchRequest(entityName: "DeviceManager")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try coord.executeRequest(deleteRequest, withContext: context)
        } catch let error as NSError {
            debugPrint(error)
        }
    }
}


