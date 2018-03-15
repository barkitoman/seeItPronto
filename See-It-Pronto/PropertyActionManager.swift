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
        let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let contxt: NSManagedObjectContext = appDel.managedObjectContext
        let freq = NSFetchRequest<NSFetchRequestResult>(entityName:"PropertyAction")
        var out:Array<AnyObject> = []
        do {
            try out = contxt.fetch(freq)
        } catch {
            print("An error has ocurred")
        }
        return out as AnyObject
    }
    
    func getField(_ fieldName:String)->String{
        let propertyAction = PropertyAction().find()
        var out:String = ""
        if(propertyAction.count >= 1) {
            if let dataObj:AnyObject = propertyAction.objectAtIndex(0)  {
                let obj  = dataObj as! NSManagedObject
                if(obj.value(forKey: fieldName) != nil) {
                    out = obj.value(forKey: fieldName) as! String
                }
            }
        }
        return out
    }
    
    func saveOne(_ actionData:JSON) {
        //check if item exists
        if (self.find().count >= 1) {
            //Remove if exists
            self.deleteAllData()
        }
        self.save(actionData)
    }
    
    func save(_ actionData:JSON) {
        let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let contxt: NSManagedObjectContext = appDel.managedObjectContext
        let en = NSEntityDescription.entity(forEntityName: "PropertyAction", in: contxt)
        //create instance of pur data model and inicilize
        let newItem = PropertyActionEntity(entity:en!, insertInto:contxt)
        //map our properties
        newItem.type = actionData["type"].stringValue
        do {
            try contxt.save()
        } catch let error as NSError {
            print("Error when save property action. error : \(error) \(error.userInfo)")
        }
    }
    
    func deleteAllData() {
        let appDel        = UIApplication.shared.delegate as! AppDelegate
        let context       = appDel.managedObjectContext
        let coord         = appDel.persistentStoreCoordinator
        let fetchRequest  = NSFetchRequest<NSFetchRequestResult>(entityName: "PropertyAction")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try coord.execute(deleteRequest, with: context)
        } catch let error as NSError {
            debugPrint(error)
        }
    }
}


