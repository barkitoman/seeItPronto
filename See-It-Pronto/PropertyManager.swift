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
    @NSManaged var rs:String
    @NSManaged var pricesqft:String
    @NSManaged var garage:String
    @NSManaged var internet:String
    @NSManaged var petsAllowed:String
    @NSManaged var pool:String
    @NSManaged var remarks:String
    @NSManaged var spa:String
    @NSManaged var zipcode:String
    @NSManaged var license:String
    

}

class Property {
    var existingItem : NSManagedObject!
    
    func find()->AnyObject{
        let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let contxt: NSManagedObjectContext = appDel.managedObjectContext
        let freq = NSFetchRequest<NSFetchRequestResult>(entityName:"Property")
        var out:Array<AnyObject> = []
        do {
            try out = contxt.fetch(freq)
        } catch {
            print("An error has ocurred")
        }
        return out as AnyObject
    }
    
    func getField(_ fieldName:String)->String{
        let property   = Property().find()
        var out:String = ""
        if(property.count >= 1) {
            if let dataObj:AnyObject = property.objectAtIndex(0)  {
                let obj  = dataObj as! NSManagedObject
                if(obj.value(forKey: fieldName) != nil) {
                    out = obj.value(forKey: fieldName) as! String
                }
            }
        }
        return out
    }
    
    func saveOne(_ propertyData:JSON) {
        //check if item exists
        if (Property().find().count >= 1) {
            //Remove if exists
            self.deleteAllData()
        }
        self.save(propertyData)
    }
    
    func save(_ propertyData:JSON) {
        let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let contxt: NSManagedObjectContext = appDel.managedObjectContext
        let en = NSEntityDescription.entity(forEntityName: "Property", in: contxt)
        //create instance of pur data model and inicilize
        let newItem = PropertyEntity(entity:en!, insertInto:contxt)
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
        newItem.property_type = propertyData["type"].stringValue
        newItem.size          = propertyData["size"].stringValue
        newItem.lot           = propertyData["lot"].stringValue
        newItem.lot_size      = propertyData["lot_size"].stringValue
        newItem.year_built    = propertyData["year_built"].stringValue
        newItem.neighborhood  = propertyData["neighborhood"].stringValue
        newItem.added_on      = propertyData["added_on"].stringValue
        newItem.square_feed   = propertyData["square_feed"].stringValue
        newItem.location      = propertyData["location"].stringValue
        newItem.rs            = propertyData["rs"].stringValue //for Sale or For Rent
        newItem.pricesqft     = propertyData["pricesqft"].stringValue //price by sqft
        newItem.garage        = propertyData["garage"].stringValue //garage yes o no
        newItem.internet      = propertyData["internet"].stringValue //yes or no
        newItem.petsAllowed   = propertyData["petsAllowed"].stringValue
        newItem.pool          = propertyData["pool"].stringValue
        newItem.remarks       = propertyData["remarks"].stringValue //description
        newItem.spa           = propertyData["spa"].stringValue //spa
        newItem.zipcode       = propertyData["zipcode"].stringValue
        newItem.license       = propertyData["license"].stringValue
        newItem.property_class = propertyClass
        
        do {
            try contxt.save()
        } catch let error as NSError {
            print("Error when save property. error : \(error) \(error.userInfo)")
        }
    }
    
    func deleteAllData() {
        let appDel        = UIApplication.shared.delegate as! AppDelegate
        let context       = appDel.managedObjectContext
        let coord         = appDel.persistentStoreCoordinator
        let fetchRequest  = NSFetchRequest<NSFetchRequestResult>(entityName: "Property")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try coord.execute(deleteRequest, with: context)
        } catch let error as NSError {
            debugPrint(error)
        }
    }
}


