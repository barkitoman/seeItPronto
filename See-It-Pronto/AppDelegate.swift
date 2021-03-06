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
import Firebase
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, KTKDevicesManagerDelegate {

    var devicesManager: KTKDevicesManager!
    var connection: KTKDeviceConnection?
    
    var window: UIWindow?
    var LocationTimer: Timer?
    var userId:String = ""
    var manager: OneShotLocationManager?
    var latitude: String = ""
    var longintude: String = ""
    var foundDevices = ""
    var currentBadgeCount = 0;
    
    func intervalLocation() {
        self.LocationTimer = Timer.scheduledTimer(timeInterval: 600,
            target:self,
            selector:#selector(AppDelegate.findLocation),
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
        DispatchQueue.main.async {
            if (User().getField("id") != "" && User().getField("is_login") == "1") {
                self.manager = OneShotLocationManager()
                self.manager!.fetchWithCompletion {location, error in
                    // fetch location or an error
                    if let loc = location {
                        self.latitude   = (AppConfig.MODE == "PROD") ? "\(loc.coordinate.latitude)" : AppConfig().develop_lat()
                        self.longintude = (AppConfig.MODE == "PROD") ? "\(loc.coordinate.longitude)": AppConfig().develop_lon()
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
    
    func sendPosition(_ latitude: String, longitude: String) {
        let urlString = "\(AppConfig.APP_URL)/save_current_location/\(User().getField("id"))/\(latitude)/\(longitude)/"
        let url = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        Request().get(url!, successHandler: {(response) in self.sendPositionResponse(response)})
    }
    
    func sendPositionResponse(_ response: Data){
        //print("\(response)")
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FIRApp.configure()
        
        // Override point for customization after application launch.
        let notificationTypes : UIUserNotificationType = [.alert, .badge, .sound]
        let notificationSettings : UIUserNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)
        //send location
        self.intervalLocation()
        
        // Initiate Beacon Devices Manager
        self.devicesManager = KTKDevicesManager(delegate: self)
        // Start Discovery Beacons
        self.devicesManager.startDevicesDiscovery(withInterval: AppConfig.FIND_BEACONS_INTERVAL)
        return true
    }
    
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings){
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let saveData = JSON(["device_token_id":Utility().convertDeviceTokenToString(deviceToken)])
        DeviceManager().saveOne(saveData)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Error getting device token on emulator")
        print(error.localizedDescription)
    }
    
    func showTopNotification(_ userInfo: [AnyHashable: Any]) {
        let rootViewController = self.window?.rootViewController as! UINavigationController
        var notie = Notie(view: rootViewController.view, message: "New notification received", style: .confirm)
        notie.leftButtonAction = {
            notie.dismiss()
        }
        var fromUserId = ""
        if let aps = userInfo["aps"] as? NSDictionary {
            if let alertMsg = aps["alert"] as? NSDictionary {
                if let message = alertMsg["body"] as? String {
                    notie = Notie(view: rootViewController.view, message: message, style: .confirm)
                }
            }
            if let category = aps["category"] as? String {
                if category == "NEW_MESSAGE" {
                    if let alert = aps["alert"] as? NSDictionary {
                        if let userIds = alert["loc-args"] as? NSArray {
                            fromUserId = userIds[0] as! String
                            notie.leftButtonAction = {
                                notie.dismiss()
                                self.goToChat(fromUserId)
                            }
                        }
                    }
                }else {
                    notie.leftButtonAction = {
                        notie.dismiss()
                        self.goToNotifications()
                    }
                }
            } else if let _ = aps["alert"] as? NSString {
                notie.leftButtonAction = {
                    notie.dismiss()
                    self.goToNotifications()
                }
            }
        }
        notie.rightButtonAction = {
            notie.dismiss()
        }
        notie.leftButtonTitle  = "View"
        notie.rightButtonTitle = "Close"
        if(User().getField("current_chat") != "") {
            if(User().getField("current_chat") != fromUserId) {
                notie.show()
            }
        } else {
            notie.show()
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        self.openNotification(userInfo)
    }

    // Called when a notification is received and the app is in the
    // foreground (or if the app was in the background and the user clicks on the notification).
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // display the userInfo
        if (application.applicationState == UIApplicationState.inactive || application.applicationState == UIApplicationState.background ){
            self.openNotification(userInfo)
            completionHandler(UIBackgroundFetchResult.noData)
        }else{
            self.showTopNotification(userInfo);
            completionHandler(UIBackgroundFetchResult.noData)
        }
    }
    
    func openNotification(_ userInfo: [AnyHashable: Any]) {
        if let aps = userInfo["aps"] as? NSDictionary {
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
        }
    }
    
    func goToChat(_ fromUserId:String = "") {
        DispatchQueue.main.async {
            let rootViewController = self.window?.rootViewController as! UINavigationController
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
            let vc = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
            vc.to = fromUserId
            rootViewController.pushViewController(vc, animated: true)
        }
    }
    
    func goToNotifications() {
        DispatchQueue.main.async {
            let rootViewController = self.window?.rootViewController as! UINavigationController
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
            let vc = storyboard.instantiateViewController(withIdentifier: "NotificationsViewController") as! NotificationsViewController
            vc.showNewNotificationMsg = true
            rootViewController.pushViewController(vc, animated: true)
        }
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, withResponseInfo responseInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void) {
        var userInfo = [AnyHashable: Any]()
        userInfo["text"] = responseInfo[UIUserNotificationActionResponseTypedTextKey]
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "text"), object: nil, userInfo: userInfo)
        completionHandler()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        if(User().getField("id") != "" && User().getField("is_login") == "1" && User().getField("role") == "realtor") {
            if(User().getField("foreground_date") != "") {
                let lastDateStr     = User().getField("foreground_date")
                let lastDate        = lastDateStr.toDateTime()
                let currentDateStr  = "\(Utility().getCurrentDate()) \(Utility().getTime())"
                let currentDate     = currentDateStr.toDateTime()
                let diffHours       = currentDate.diffHours(lastDate)
                if(diffHours >= 4) {
                    self.gotoReadyToWork()
                }
            } else {
                self.gotoReadyToWork()
            }
        }
    }
    
    func gotoReadyToWork() {
        let currentDateStr = "\(Utility().getCurrentDate()) \(Utility().getTime())"
        User().updateField("foreground_date", value: currentDateStr)
        DispatchQueue.main.async {
            let rootViewController = self.window?.rootViewController as! UINavigationController
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mvc = storyboard.instantiateViewController(withIdentifier: "ReadyToWorkViewController") as! ReadyToWorkViewController
            rootViewController.pushViewController(mvc, animated: true)
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "NyxentCorp.See_It_Pronto" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "See_It_Pronto", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

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
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
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
    
    func devicesManagerDidFail(toStartDiscovery manager: KTKDevicesManager, withError error: NSError?) {
        
    }
    
    func devicesManager(_ manager: KTKDevicesManager, didDiscover devices: [KTKNearbyDevice]?) {
        if(devices?.count > 0) {
            for device in devices! {
                if let deviceId = device.uniqueID {
                    if (!foundDevices.contains(deviceId)) {
                        foundDevices = foundDevices+"\(deviceId),"
                        DispatchQueue.main.async {
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
    
    func showPropertyBeaconDetail(_ response: Data) {
        let result = JSON(data: response)
        if(result["result"].bool == true) {
            DispatchQueue.main.async {
                let saveData: JSON =  ["id":result["property"]["id"].stringValue,"property_class":result["property"]["class"].stringValue]
                Property().saveOne(saveData)
                let rootViewController = self.window?.rootViewController as! UINavigationController
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mvc = storyboard.instantiateViewController(withIdentifier: "FullPropertyDetailsViewController") as! FullPropertyDetailsViewController
                rootViewController.pushViewController(mvc, animated: true)
            }
        }
    }

}


