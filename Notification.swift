//
//  NotificationHelper.swift
//  Push
//
//  Created by user114136 on 12/2/15.
//  Copyright © 2015 user114136. All rights reserved.
//

import UIKit

struct Notification {
    
    static func askPermission() {
        let textAction = UIMutableUserNotificationAction()
        textAction.identifier = "TEXT_ACTION"
        textAction.title = "Reply"
        textAction.activationMode = .Background
        textAction.authenticationRequired = false
        textAction.destructive = false
        textAction.behavior = .TextInput

        let category = UIMutableUserNotificationCategory()
        category.identifier = "CATEGORY_ID"
        category.setActions([textAction], forContext: .Default)
        category.setActions([textAction], forContext: .Minimal)

        let categories = NSSet(object: category) as! Set<UIUserNotificationCategory>
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: categories)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }

    static func scheduleNotification(alertBodyText:String) {
        let now: NSDateComponents = NSCalendar.currentCalendar().components([.Hour, .Minute], fromDate: NSDate())

        let cal  = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let date = cal.dateBySettingHour(now.hour, minute: now.minute + 1, second: 0, ofDate: NSDate(), options: NSCalendarOptions())
        let reminder = UILocalNotification()
        reminder.fireDate  = date
        reminder.alertBody = alertBodyText
        reminder.alertAction = "Cool"
        reminder.soundName = "sound.aif"
        reminder.category  = "CATEGORY_ID"

        UIApplication.sharedApplication().scheduleLocalNotification(reminder)
        print("Firing at \(now.hour):\(now.minute+1)")
    }
}
