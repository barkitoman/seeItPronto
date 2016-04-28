//
//  PropertyManager.swift
//  See-It-Pronto
//
//  Created by Deyson on 2/18/16.
//  Copyright © 2016 Deyson. All rights reserved.
//


import Foundation
import UIKit
import CoreData
@objc(PropertyEntity)

class PropertyEntity: NSManagedObject {
    @NSManaged var address:String
    @NSManaged var id:String
    @NSManaged var image:String
    @NSManaged var image2:String
    @NSManaged var image3:String
    @NSManaged var image4:String
    @NSManaged var image5:String
    @NSManaged var image6:String
    @NSManaged var price:String
    @NSManaged var est_payments:String
    @NSManaged var your_credits:String
    @NSManaged var bedrooms:String
    @NSManaged var bathrooms:String
    @NSManaged var property_type:String
    @NSManaged var size:String
    @NSManaged var lot:String
    @NSManaged var year_built:String
    @NSManaged var neighborhood:String
    @NSManaged var added_on:String
    @NSManaged var square_feed:String
    @NSManaged var lot_size:String
    @NSManaged var location:String
    @NSManaged var property_class:String

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
            if(obj.valueForKey(fieldName) != nil) {
                out = obj.valueForKey(fieldName) as! String
            }
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
        var propertyClass = propertyData["property_class"].stringValue
        if(propertyData["property_class"].stringValue.isEmpty && !propertyData["class"].stringValue.isEmpty) {
            propertyClass = propertyData["class"].stringValue
        }
        //map our properties
        newItem.address       = propertyData["address"].stringValue
        newItem.id            = propertyData["id"].stringValue
        newItem.image         = propertyData["images"][0].stringValue
        newItem.image2        = propertyData["images"][1].stringValue
        newItem.image3        = propertyData["images"][2].stringValue
        newItem.image4        = propertyData["images"][3].stringValue
        newItem.image5        = propertyData["images"][4].stringValue
        newItem.image6        = propertyData["images"][5].stringValue
        newItem.price         = propertyData["price"].stringValue
        newItem.est_payments  = propertyData["est_payments"].stringValue
        newItem.your_credits  = propertyData["your_credits"].stringValue
        newItem.bedrooms      = propertyData["bedrooms"].stringValue
        newItem.bathrooms     = propertyData["bathrooms"].stringValue
        newItem.property_type = propertyData["property_type"].stringValue
        newItem.size          = propertyData["size"].stringValue
        newItem.lot           = propertyData["lot"].stringValue
        newItem.lot_size      = propertyData["lot_size"].stringValue
        newItem.year_built    = propertyData["year_built"].stringValue
        newItem.neighborhood  = propertyData["neighborhood"].stringValue
        newItem.added_on      = propertyData["added_on"].stringValue
        newItem.square_feed   = propertyData["square_feed"].stringValue
        newItem.location      = propertyData["location"].stringValue
        newItem.property_class = propertyClass
        
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


