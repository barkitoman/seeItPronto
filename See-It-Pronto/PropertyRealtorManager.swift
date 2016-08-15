//
//  PropertyRealtorManager.swift
//  See-It-Pronto
//
//  Created by Deyson on 2/29/16.
//  Copyright © 2016 Deyson. All rights reserved.
//


import Foundation
import UIKit
import CoreData
@objc(PropertyRealtorEntity)

class PropertyRealtorEntity: NSManagedObject {
    @NSManaged var distance:String
    @NSManaged var first_name:String
    @NSManaged var id:String
    @NSManaged var last_name:String
    @NSManaged var url_image:String
    @NSManaged var rating:String
    @NSManaged var showing_rate:String
    @NSManaged var travel_range:String
    @NSManaged var brokeragent:String
    @NSManaged var company:String
    @NSManaged var phone:String
    
}

class PropertyRealtor {
    var existingItem : NSManagedObject!
    
    func find()->AnyObject{
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let contxt: NSManagedObjectContext = appDel.managedObjectContext
        let freq = NSFetchRequest(entityName:"PropertyRealtor")
        var out:Array<AnyObject> = []
        do {
            try out = contxt.executeFetchRequest(freq)
        } catch {
            print("An error has ocurred")
        }
        return out
    }
    
    func getField(fieldName:String)->String{
        let propertyRealtor   = PropertyRealtor().find()
        var out:String = ""
        if(propertyRealtor.count >= 1) {
            if let dataObj:AnyObject = propertyRealtor.objectAtIndex(0)  {
                let obj  = dataObj as! NSManagedObject
                if(obj.valueForKey(fieldName) != nil) {
                    out = obj.valueForKey(fieldName) as! String
                }
            }
        }
        return out
    }
    
    func saveOne(propertyRealtorData:JSON) {
        //check if item exists
        if (Property().find().count >= 1) {
            //Remove if exists
            self.deleteAllData()
        }
        self.save(propertyRealtorData)
    }
    
    func save(propertyData:JSON) {
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let contxt: NSManagedObjectContext = appDel.managedObjectContext
        let en = NSEntityDescription.entityForName("PropertyRealtor", inManagedObjectContext: contxt)
        //create instance of pur data model and inicilize
        let newItem = PropertyRealtorEntity(entity:en!, insertIntoManagedObjectContext:contxt)
        //map our properties realtor
        let image = (!propertyData["image"].stringValue.isEmpty) ? propertyData["image"].stringValue : propertyData["url_image"].stringValue
        newItem.distance     = propertyData["distance"].stringValue
        newItem.first_name   = propertyData["first_name"].stringValue
        newItem.id           = propertyData["id"].stringValue
        newItem.last_name    = propertyData["last_name"].stringValue
        newItem.url_image    = image
        newItem.rating       = propertyData["rating"].stringValue
        newItem.showing_rate = propertyData["showing_rate"].stringValue
        newItem.brokeragent  = propertyData["brokerage"].stringValue
        newItem.travel_range = propertyData["travel_range"].stringValue
        newItem.company      = propertyData["company"].stringValue
        newItem.phone        = propertyData["phone"].stringValue
        do {
            try contxt.save()
        } catch let error as NSError {
            print("Error when save property realtor. error : \(error) \(error.userInfo)")
        }
    }
    
    func deleteAllData() {
        let appDel        = UIApplication.sharedApplication().delegate as! AppDelegate
        let context       = appDel.managedObjectContext
        let coord         = appDel.persistentStoreCoordinator
        let fetchRequest  = NSFetchRequest(entityName: "PropertyRealtor")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try coord.executeRequest(deleteRequest, withContext: context)
        } catch let error as NSError {
            debugPrint(error)
        }
    }
}



