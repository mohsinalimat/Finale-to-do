//
//  NotificationHelper.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/22/22.
//

import Foundation
import UserNotifications
import UIKit

class NotificationHelper {
    
    static func ScheduleNotificationsForTask(task: Task) {
        
        for (notificationType, id) in task.notifications {
            let content = UNMutableNotificationContent()
            content.body = "\(GetNotificationPrefix(notificationType: notificationType))\(task.name)"
            content.sound = UNNotificationSound.default
            
            if task.priority == .High { content.title = "Important"}
            
            let notificationDate = GetNotificationDate(taskAssignedDate: task.dateAssigned, notificationType: notificationType)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: GetDateComponents(date: notificationDate), repeats: false)

            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                if error == nil {
                    print("Scheduled notification with ID: \(id).")
                } else {
                    print("Failed to schedule notification with ID: \(id).\nError: \(error?.localizedDescription ?? "unknown error")" )
                }
            })
        }
        
    }
    
    static func GetNotificationPrefix (notificationType: NotificationType) -> String {
        switch notificationType {
        case .OnTime:
            return ""
        case .FiveMinBefore:
            return "In 5 minutes: "
        case .ThirtyMinBefore:
            return "In 30 minutes: "
        case .OneHourBefore:
            return "In an hour: "
        case .OneDayBefore:
            return "Tomorrow: "
        case .MorningOnTheDay:
            return "Today: "
        case .MorningOneDayPrior:
            return "Tomorrow: "
        case .MorningTwoDaysPrior:
            return "In 2 days: "
        case .MorningThreeDaysPrior:
            return "In 3 days: "
        case .MorningOneWeekPrior:
            return "In a week: "
        }
    }
    
    static func GetDateComponents(date: Date) -> DateComponents {
        var dateComponents = DateComponents()
        
        dateComponents.day = date.get(.day)
        dateComponents.month = date.get(.month)
        dateComponents.year = date.get(.year)
        
        dateComponents.hour = date.get(.hour)
        dateComponents.minute = date.get(.minute)
        
        return dateComponents
    }
    
    static func GetNotificationDate (taskAssignedDate: Date, notificationType: NotificationType) -> Date {
        
        let notificationDate: Date
        switch notificationType {
        case .OnTime:
            notificationDate = taskAssignedDate
        case .FiveMinBefore:
            notificationDate = Calendar.current.date(byAdding: .minute, value: -5, to: taskAssignedDate)!
        case .ThirtyMinBefore:
            notificationDate = Calendar.current.date(byAdding: .minute, value: -30, to: taskAssignedDate)!
        case .OneHourBefore:
            notificationDate = Calendar.current.date(byAdding: .hour, value: -1, to: taskAssignedDate)!
        case .OneDayBefore:
            notificationDate = Calendar.current.date(byAdding: .day, value: -1, to: taskAssignedDate)!
        case .MorningOnTheDay:
            notificationDate = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: taskAssignedDate)!
        case .MorningOneDayPrior:
            let prevDay = Calendar.current.date(byAdding: .day, value: -1, to: taskAssignedDate)!
            notificationDate = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: prevDay)!
        case .MorningTwoDaysPrior:
            let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: taskAssignedDate)!
            notificationDate = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: twoDaysAgo)!
        case .MorningThreeDaysPrior:
            let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: taskAssignedDate)!
            notificationDate = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: threeDaysAgo)!
        case .MorningOneWeekPrior:
            let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: taskAssignedDate)!
            notificationDate = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: weekAgo)!
        }
        
        return notificationDate
    }
    
    static func CancelNotification(id: String) {
        print("Canceled notification with ID: \(id)")
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    static func RequestNotificationAccess (uiSwitch: UISwitch? = nil, settingsNotificationsPage: SettingsNotificationsPage? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            App.settingsConfig.isNotificationsAllowed = success
            
            if settingsNotificationsPage != nil && success {
                DispatchQueue.main.async {
                    settingsNotificationsPage?.ShowAllNotificationSettings()
                    settingsNotificationsPage?.AllowNotificationSuccess()
                }
            }
            
            if uiSwitch != nil && !success {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                        UIApplication.shared.open(appSettings)
                    }
                    uiSwitch?.isOn = false
                }
            }
            
        }
    }
    
    static func CheckNotificationPermissionStatus () {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { permission in
                    switch permission.authorizationStatus  {
                    case .authorized:
                        print("User granted permission for notification")
                    case .denied:
                        if App.settingsConfig.isNotificationsAllowed { App.settingsConfig.isNotificationsAllowed = false }
                        print("User denied notification permission")
                    case .notDetermined:
                        if App.settingsConfig.isNotificationsAllowed { App.settingsConfig.isNotificationsAllowed = false }
                        print("Notification permission haven't been asked yet")
                    case .provisional:
                        // @available(iOS 12.0, *)
                        print("The application is authorized to post non-interruptive user notifications.")
                    case .ephemeral:
                        // @available(iOS 14.0, *)
                        print("The application is temporarily authorized to post notifications. Only available to app clips.")
                    @unknown default:
                        print("Unknow Status")
                    }
                })
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { result in
            print("Current pending notifications: \(result.count).")
        })
    }
    
    static func CancelAllScheduledNotifications () {
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { result in
            for r in result {
                CancelNotification(id: r.identifier)
            }
        })
    }
    
    static func ScheduleAllTaskNotifications () {
        DispatchQueue.main.async {
            for task in App.mainTaskList.upcomingTasks {
                task.ScheduleAllNotifications()
            }
            for taskList in App.userTaskLists {
                for task in taskList.upcomingTasks {
                    task.ScheduleAllNotifications()
                }
            }
        }
    }
    
    static func UpdateAppBadge() {
        var includedTasks = [Task]()
        if App.settingsConfig.isNotificationsAllowed {
            for type in App.settingsConfig.appBadgeNumberTypes {
                switch type {
                case .None:
                    includedTasks.removeAll()
                    break
                case .TasksToday:
                    let tasksToday = App.mainTaskList.upcomingTasks.filter { task in
                        return task.isDateAssigned && Calendar.current.isDateInToday(task.dateAssigned)
                    }
                    for task in tasksToday {
                        if !includedTasks.contains(task) { includedTasks.append(task) }
                    }
                    for taskList in App.userTaskLists {
                        let today = taskList.upcomingTasks.filter { task in
                            return task.isDateAssigned && Calendar.current.isDateInToday(task.dateAssigned)
                        }
                        for task in today { if !includedTasks.contains(task) {includedTasks.append(task)} }
                    }
                case .OverdueTasks:
                    let overdueTasks = App.mainTaskList.upcomingTasks.filter { task in
                        return task.isOverdue
                    }
                    for task in overdueTasks { if !includedTasks.contains(task) { includedTasks.append(task) } }
                    for taskList in App.userTaskLists {
                        let overdue = taskList.upcomingTasks.filter { task in
                            return task.isOverdue
                        }
                        for task in overdue {  if !includedTasks.contains(task) {includedTasks.append(task)} }
                    }
                case .UpcomingTasks:
                    for task in App.mainTaskList.upcomingTasks { if !includedTasks.contains(task) {includedTasks.append(task)} }
                    for taskList in App.userTaskLists {
                        for task in taskList.upcomingTasks { if !includedTasks.contains(task) {includedTasks.append(task)} }
                    }
                }
            }
        }
        UIApplication.shared.applicationIconBadgeNumber = includedTasks.count
    }
    
    static func RemoveDeliveredNotifications () {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
}


enum NotificationType: Int, Codable {
    case OnTime = 0
    case FiveMinBefore = 1
    case ThirtyMinBefore = 2
    case OneHourBefore = 3
    case OneDayBefore = 4
    case MorningOnTheDay = 5
    case MorningOneDayPrior = 6
    case MorningTwoDaysPrior = 7
    case MorningThreeDaysPrior = 8
    case MorningOneWeekPrior = 9
    
    var str: String {
        let AMPM = usesAMPM
        
        switch self {
        case .OnTime:
            return "On time"
        case .FiveMinBefore:
            return "5 minutes before"
        case .ThirtyMinBefore:
            return "30 minutes before"
        case .OneHourBefore:
            return "1 hour before"
        case .OneDayBefore:
            return "1 day before"
        case .MorningOnTheDay:
            return "On the day " + (AMPM ? "(9:00 AM)" : "(09:00)")
        case .MorningOneDayPrior:
            return "1 day prior " + (AMPM ? "(9:00 AM)" : "(09:00)")
        case .MorningTwoDaysPrior:
            return "2 days prior " + (AMPM ? "(9:00 AM)" : "(09:00)")
        case .MorningThreeDaysPrior:
            return "3 days prior " + (AMPM ? "(9:00 AM)" : "(09:00)")
        case .MorningOneWeekPrior:
            return "1 week prior " + (AMPM ? "(9:00 AM)" : "(09:00)")
        }
    }
    
    var usesAMPM: Bool {
        let locale = NSLocale.current
        let dateFormat = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: locale)!
        return dateFormat.contains("a")
    }
}
