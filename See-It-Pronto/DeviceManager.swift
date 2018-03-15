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
        let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let contxt: NSManagedObjectContext = appDel.managedObjectContext
        let freq = NSFetchRequest<NSFetchRequestResult>(entityName:"DeviceManager")
        var out:Array<AnyObject> = []
        do {
            try out = contxt.fetch(freq)
        } catch {
            print("An error has ocurred")
        }
        return out as AnyObject
    }
    
    func getField(_ fieldName:String)->String{
        let deviceConfig = DeviceManager().find()
        var out:String   = ""
        if(deviceConfig.count >= 1) {
            if let dataObj:AnyObject = deviceConfig.objectAtIndex(0)  {
                let obj  = dataObj as! NSManagedObject
                if(obj.value(forKey: fieldName) != nil) {
                    out = obj.value(forKey: fieldName) as! String
                }
            }
        }
        return out
    }
    
    func saveOne(_ configData:JSON) {
        //check if item exists
        if (DeviceManager().find().count >= 1) {
            //Remove if exists
            self.deleteAllData()
        }
        self.save(configData)
    }
    
    func save(_ deviceData:JSON) {
        print(deviceData)
        let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let contxt: NSManagedObjectContext = appDel.managedObjectContext
        let en = NSEntityDescription.entity(forEntityName: "DeviceManager", in: contxt)
        //create instance of pur data model and inicilize
        let newItem = DeviceEntity(entity:en!, insertInto:contxt)
        //map our properties
        newItem.device_token_id = deviceData["device_token_id"].stringValue

        do {
            try contxt.save()
        } catch let error as NSError {
            print("Error when save search config. error : \(error) \(error.userInfo)")
        }
    }
    
    func deleteAllData() {
        let appDel        = UIApplication.shared.delegate as! AppDelegate
        let context       = appDel.managedObjectContext
        let coord         = appDel.persistentStoreCoordinator
        let fetchRequest  = NSFetchRequest<NSFetchRequestResult>(entityName: "DeviceManager")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try coord.execute(deleteRequest, with: context)
        } catch let error as NSError {
            debugPrint(error)
        }
    }
}


