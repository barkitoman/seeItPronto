//
//  ActionManager.swift
//  See-It-Pronto
//
//  Created by Deyson on 3/1/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import Foundation
import UIKit
import CoreData
@objc(PropertyActionEntity)

class PropertyActionEntity: NSManagedObject {
    @NSManaged var type:String
    
}

class PropertyAction {
    var existingItem : NSManagedObject!
    
    func find()->AnyObject{
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let contxt: NSManagedObjectContext = appDel.managedObjectContext
        let freq = NSFetchRequest(entityName:"PropertyAction")
        var out:Array<AnyObject> = []
        do {
            try out = contxt.executeFetchRequest(freq)
        } catch {
            print("An error has ocurred")
        }
        return out
    }
    
    func getField(fieldName:String)->String{
        let propertyAction = PropertyAction().find()
        var out:String = ""
        if(propertyAction.count >= 1 && propertyAction[0] != nil) {
            let obj  = propertyAction[0] as! NSManagedObject
            if(obj.valueForKey(fieldName) != nil) {
                out = obj.valueForKey(fieldName) as! String
            }
        }
        return out
    }
    
    func saveIfExists(actionData:JSON) {
        //check if item exists
        if (self.find().count >= 1) {
            //Remove if exists
            self.deleteAllData()
        }
        self.save(actionData)
    }
    
    func save(actionData:JSON) {
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let contxt: NSManagedObjectContext = appDel.managedObjectContext
        let en = NSEntityDescription.entityForName("PropertyAction", inManagedObjectContext: contxt)
        //create instance of pur data model and inicilize
        let newItem = PropertyActionEntity(entity:en!, insertIntoManagedObjectContext:contxt)
        //map our properties
        newItem.type = actionData["type"].stringValue
        do {
            try contxt.save()
        } catch let error as NSError {
            print("Error when save property action. error : \(error) \(error.userInfo)")
        }
    }
    
    func deleteAllData() {
        let appDel        = UIApplication.sharedApplication().delegate as! AppDelegate
        let context       = appDel.managedObjectContext
        let coord         = appDel.persistentStoreCoordinator
        let fetchRequest  = NSFetchRequest(entityName: "PropertyAction")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try coord.executeRequest(deleteRequest, withContext: context)
        } catch let error as NSError {
            debugPrint(error)
        }
    }
}


