//
//  NotificationHelper.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/22/22.
//

import Foundation
import UserNotifications

class NotificationHelper {
    
    static func ScheduleNotificationsForTask(task: Task) {
        
        for (notificationType, id) in task.notifications {
            let content = UNMutableNotificationContent()
            content.body = task.name
            content.sound = UNNotificationSound.default
            
            if task.priority == .High { content.title = "High priority!"}
            
            let notificationDate = GetNotificationDate(taskAssignedDate: task.dateAssigned, notificationType: notificationType)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: GetDateComponents(date: notificationDate), repeats: false)

            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                if error == nil {
                    print("Scheduled notification: \(content.body) on \(trigger)")
                } else {
                    print("Failed to schedule notification \"\(content.body)\": \(error?.localizedDescription ?? "unknown error")" )
                }
            })
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
        print("Canceled id: \(id)")
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
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
