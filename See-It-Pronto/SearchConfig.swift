//
//  SearchConfig.swift
//  See-It-Pronto
//
//  Created by Deyson on 2/18/16.
//  Copyright © 2016 Deyson. All rights reserved.
//


import Foundation
import UIKit
import CoreData
@objc(SearchConfigEntity)

class SearchConfigEntity: NSManagedObject {
    @NSManaged var user_id:String
    @NSManaged var type_property:String
    @NSManaged var price_range_higher:String
    @NSManaged var price_range_less:String
    @NSManaged var pool:String
    @NSManaged var id:String
    @NSManaged var beds:String
    @NSManaged var baths:String
    @NSManaged var area:String
}

class SearchConfig {
    var existingItem : NSManagedObject!
    
    func find()->AnyObject{
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let contxt: NSManagedObjectContext = appDel.managedObjectContext
        let freq = NSFetchRequest(entityName:"SearchConfig")
        var out:Array<AnyObject> = []
        do {
            try out = contxt.executeFetchRequest(freq)
        } catch {
            print("An error has ocurred")
        }
        return out
    }
    
    func getField(fieldName:String)->String{
        let searchConfig = SearchConfig().find()
        var out:String   = ""
        if(searchConfig.count >= 1 && searchConfig[0] != nil) {
            let obj  = searchConfig[0] as! NSManagedObject
            if(obj.valueForKey(fieldName) != nil) {
                out = obj.valueForKey(fieldName) as! String
            }
        }
        return out
    }
    
    func saveIfExists(configData:JSON) {
        //check if item exists
        if (SearchConfig().find().count >= 1) {
            //Remove if exists
            self.deleteAllData()
        }
        self.save(configData)
        
    }
    
    func save(searchConfigData:JSON) {
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let contxt: NSManagedObjectContext = appDel.managedObjectContext
        let en = NSEntityDescription.entityForName("SearchConfig", inManagedObjectContext: contxt)
        //create instance of pur data model and inicilize
        let newItem = SearchConfigEntity(entity:en!, insertIntoManagedObjectContext:contxt)
        //map our properties
        newItem.type_property       = searchConfigData["type_property"].stringValue
        newItem.price_range_higher  = searchConfigData["price_range_higher"].stringValue
        newItem.price_range_less    = searchConfigData["price_range_less"].stringValue
        newItem.pool                = searchConfigData["pool"].stringValue
        newItem.user_id             = searchConfigData["user_id"].stringValue
        newItem.id                  = searchConfigData["id"].stringValue
        newItem.beds                = searchConfigData["beds"].stringValue
        newItem.baths               = searchConfigData["baths"].stringValue
        newItem.area                = searchConfigData["area"].stringValue
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
        let fetchRequest  = NSFetchRequest(entityName: "SearchConfig")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try coord.executeRequest(deleteRequest, withContext: context)
        } catch let error as NSError {
            debugPrint(error)
        }
    }
}


