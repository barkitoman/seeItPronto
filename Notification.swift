//
//  NotificationHelper.swift
//  Push
//
//  Created by Deyson on 12/2/15.
//  Copyright © 2015 Deyson. All rights reserved.
//

import UIKit

struct Notification {
    
    static func askPermission() {
        let textAction = UIMutableUserNotificationAction()
        textAction.identifier = "TEXT_ACTION"
        textAction.title = "Reply"
        textAction.activationMode = .background
        textAction.isAuthenticationRequired = false
        textAction.isDestructive = false
        textAction.behavior = .textInput

        let category = UIMutableUserNotificationCategory()
        category.identifier = "CATEGORY_ID"
        category.setActions([textAction], for: .default)
        category.setActions([textAction], for: .minimal)

        let categories = NSSet(object: category) as! Set<UIUserNotificationCategory>
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: categories)
        UIApplication.shared.registerUserNotificationSettings(settings)
    }

    static func scheduleNotification(_ alertBodyText:String) {
        let now: DateComponents = (Calendar.current as NSCalendar).components([.hour, .minute], from: Date())

        let cal  = Calendar(identifier: Calendar.Identifier.gregorian)
        let date = (cal as NSCalendar).date(bySettingHour: now.hour!, minute: now.minute! + 1, second: 0, of: Date(), options: NSCalendar.Options())
        let reminder = UILocalNotification()
        reminder.fireDate  = date
        reminder.alertBody = alertBodyText
        reminder.alertAction = "Cool"
        reminder.soundName = "sound.aif"
        reminder.category  = "CATEGORY_ID"

        UIApplication.shared.scheduleLocalNotification(reminder)
    }
}
