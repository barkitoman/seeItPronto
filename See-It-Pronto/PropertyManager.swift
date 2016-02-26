//
//  PropertyManager.swift
//  See-It-Pronto
//
//  Created by user114136 on 2/18/16.
//  Copyright © 2016 user114136. All rights reserved.
//


import Foundation
import UIKit
import CoreData
@objc(PropertyEntity)

class PropertyEntity: NSManagedObject {
    @NSManaged var address:String
    @NSManaged var id:String
    @NSManaged var image:String
    @NSManaged var price:String

}

class Property {
    var existingItem : NSManagedObject!
    
    func find()->AnyObject{
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let contxt: NSManagedObjectContext = appDel.managedObjectContext
        let freq = NSFetchRequest(entityName:"Property")
        var out:Array<AnyObject> = []
        do {
            try out = contxt.executeFetchRequest(freq)
        } catch {
            print("An error has ocurred")
        }
        return out
    }
    
    func getField(fieldName:String)->String{
        let property   = Property().find()
        var out:String = ""
        if(property.count >= 1 && property[0] != nil) {
            let obj  = property[0] as! NSManagedObject
            out = obj.valueForKey(fieldName) as! String
        }
        return out
    }
    
    func saveIfExists(propertyData:JSON) {
        //check if item exists
        if (Property().find().count >= 1) {
            //Remove if exists
            self.deleteAllData()
        }
        self.save(propertyData)
    }
    
    func save(propertyData:JSON) {
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let contxt: NSManagedObjectContext = appDel.managedObjectContext
        let en = NSEntityDescription.entityForName("Property", inManagedObjectContext: contxt)
        //create instance of pur data model and inicilize
        let newItem = PropertyEntity(entity:en!, insertIntoManagedObjectContext:contxt)
        //map our properties
        newItem.address = propertyData["address"].stringValue
        newItem.id      = propertyData["id"].stringValue
        newItem.image   = propertyData["image"][0].stringValue
        newItem.price   = propertyData["price"].stringValue
        do {
            try contxt.save()
        } catch let error as NSError {
            print("Error when save property. error : \(error) \(error.userInfo)")
        }
    }
    
    func deleteAllData() {
        let appDel        = UIApplication.sharedApplication().delegate as! AppDelegate
        let context       = appDel.managedObjectContext
        let coord         = appDel.persistentStoreCoordinator
        let fetchRequest  = NSFetchRequest(entityName: "Property")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try coord.executeRequest(deleteRequest, withContext: context)
        } catch let error as NSError {
            debugPrint(error)
        }
    }
}


