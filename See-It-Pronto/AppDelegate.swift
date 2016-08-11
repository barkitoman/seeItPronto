//
//  AppDelegate.swift
//  See-It-Pronto
//
//  Created by Deyson on 12/18/15.
//  Copyright © 2015 user114136. All rights reserved.
//

import UIKit
import CoreData
import KontaktSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, KTKDevicesManagerDelegate {

    var devicesManager: KTKDevicesManager!
    var connection: KTKDeviceConnection?
    
    var window: UIWindow?
    var LocationTimer: NSTimer?
    var userId:String = ""
    var manager: OneShotLocationManager?
    var latitude: String = ""
    var longintude: String = ""
    var foundDevices = ""
    var currentBadgeCount = 0;
    
    func intervalLocation() {
        self.LocationTimer = NSTimer.scheduledTimerWithTimeInterval(600,
            target:self,
            selector:Selector("findLocation"),
            userInfo:nil,
            repeats:true
        )
    }
    
    func stopIntervalNotifications() {
        if(self.LocationTimer != nil) {
            self.LocationTimer!.invalidate()
        }
    }
    
    func findLocation() {
        dispatch_async(dispatch_get_main_queue()) {
            if (User().getField("id") != "" && User().getField("is_login") == "1") {
                self.manager = OneShotLocationManager()
                self.manager!.fetchWithCompletion {location, error in
                    // fetch location or an error
                    if let loc = location {
                        self.latitude   = (AppConfig.MODE == "PROD") ? "\(loc.coordinate.latitude)" : "26.189244"
                        self.longintude = (AppConfig.MODE == "PROD") ? "\(loc.coordinate.longitude)": "-80.1824587"
                        self.sendPosition(self.latitude, longitude: self.longintude)
                    } else if let _ = error {
                        print("ERROR GETTING LOCATION")
                    }
                    // destroy the object immediately to save memory
                    self.manager = nil
                }
            }
        }
    }
    
    func sendPosition(latitude: String, longitude: String) {
        let urlString = "\(AppConfig.APP_URL)/save_current_location/\(User().getField("id"))/\(latitude)/\(longitude)/"
        let url = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        Request().get(url!, successHandler: {(response) in self.sendPositionResponse(response)})
    }
    
    func sendPositionResponse(let response: NSData){
        //print("\(response)")
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let notificationTypes : UIUserNotificationType = [.Alert, .Badge, .Sound]
        let notificationSettings : UIUserNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        self.setIconBadgeNumber()
        //send location
        self.intervalLocation()
        
        // Initiate Beacon Devices Manager
        self.devicesManager = KTKDevicesManager(delegate: self)
        // Start Discovery Beacons
        self.devicesManager.startDevicesDiscoveryWithInterval(AppConfig.FIND_BEACONS_INTERVAL)
        return true
    }
    
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings){
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let saveData = JSON(["device_token_id":Utility().convertDeviceTokenToString(deviceToken)])
        DeviceManager().saveOne(saveData)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Error getting device token on emulator")
        print(error.localizedDescription)
    }
    
    // Called when a notification is received and the app is in the
    // foreground (or if the app was in the background and the user clicks on the notification).
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        // display the userInfo
        if let aps = userInfo["aps"] as? NSDictionary {
            NotificationCount().increaseCount("1")
            self.setIconBadgeNumber()
            if let category = aps["category"] as? String {
                if category == "NEW_MESSAGE" {
                    if let alert = aps["alert"] as? NSDictionary {
                        if let userIds = alert["loc-args"] as? NSArray {
                            let fromUserId = userIds[0] as! String
                            self.goToChat(fromUserId)
                        }
                    }
                }else {
                    self.goToNotifications()
                }
            } else if let _ = aps["alert"] as? NSString {
                self.goToNotifications()
            }
            completionHandler(UIBackgroundFetchResult.NoData)
        }
  
    }
    
    func goToChat(fromUserId:String = "") {
        NotificationCount().decreaseCount("1")
        let rootViewController = self.window?.rootViewController as! UINavigationController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = storyboard.instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
        vc.to = fromUserId
        vc.oponentImageName = ""
        rootViewController.pushViewController(vc, animated: true)
    }
    
    func goToNotifications() {
        NotificationCount().decreaseCount("1")
        let rootViewController = self.window?.rootViewController as! UINavigationController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = storyboard.instantiateViewControllerWithIdentifier("NotificationsViewController") as! NotificationsViewController
        vc.showNewNotificationMsg = true
        rootViewController.pushViewController(vc, animated: true)
    }
    
    func setIconBadgeNumber(){
        let currentBadgeCount = NotificationCount().getField("count_number")
        if let currentInt = Int(currentBadgeCount) {
            UIApplication.sharedApplication().applicationIconBadgeNumber = currentInt
        }else {
            UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        }
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, withResponseInfo responseInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        var userInfo = [NSObject: AnyObject]()
        userInfo["text"] = responseInfo[UIUserNotificationActionResponseTypedTextKey]
        NSNotificationCenter.defaultCenter().postNotificationName("text", object: nil, userInfo: userInfo)
        completionHandler()
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        if (User().getField("id") != "" && User().getField("is_login") == "1" && User().getField("role") == "realtor") {
            let rootViewController = self.window?.rootViewController as! UINavigationController
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mvc = storyboard.instantiateViewControllerWithIdentifier("ReadyToWorkViewController") as! ReadyToWorkViewController
            rootViewController.pushViewController(mvc, animated: true)
        }
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "NyxentCorp.See_It_Pronto" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("See_It_Pronto", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    func devicesManagerDidFailToStartDiscovery(manager: KTKDevicesManager, withError error: NSError?) {
        
    }
    
    func devicesManager(manager: KTKDevicesManager, didDiscoverDevices devices: [KTKNearbyDevice]?) {
        if(devices?.count > 0) {
            for device in devices! {
                if let deviceId = device.uniqueID {
                    if (!foundDevices.containsString(deviceId)) {
                        foundDevices = foundDevices+"\(deviceId),"
                        dispatch_async(dispatch_get_main_queue()) {
                            let url = AppConfig.APP_URL+"/get_beacon_property/\(deviceId)"
                            Request().get(url, successHandler: { (response) -> Void in
                                self.showPropertyBeaconDetail(response)
                            })
                        }
                    }
                }
            }
        } else {
            foundDevices = ""
        }
    }
    
    func showPropertyBeaconDetail(let response: NSData) {
        let result = JSON(data: response)
        if(result["result"].bool == true) {
            dispatch_async(dispatch_get_main_queue()) {
                let saveData: JSON =  ["id":result["property"]["id"].stringValue,"property_class":result["property"]["class"].stringValue]
                Property().saveOne(saveData)
                let rootViewController = self.window?.rootViewController as! UINavigationController
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mvc = storyboard.instantiateViewControllerWithIdentifier("FullPropertyDetailsViewController") as! FullPropertyDetailsViewController
                rootViewController.pushViewController(mvc, animated: true)
            }
        }
    }

}


