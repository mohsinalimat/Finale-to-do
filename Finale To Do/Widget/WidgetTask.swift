//
//  WidgetTask.swift
//  Finale To Do
//
//  Created by Grant Oganan on 5/14/22.
//

import Foundation
import UIKit

struct WidgetTask: Identifiable, Codable {
    let id = UUID()
    
    let name: String
    let colorHex: String
    let isDateAssigned: Bool
    let isDueTimeAssigned: Bool
    let dateAssigned: Date
    let isHighPriority: Bool
    
    func assignedDateTimeString(currentDate: Date) -> String {
        if !isDateAssigned {
            return ""
        }
        
        var attString = ""
        if isSameDay(date1: dateAssigned, date2: currentDate) {
            attString = "Today"
        } else if isTomorrow(date1: dateAssigned, date2: currentDate) {
            attString = "Tomorrow"
        } else if isYesterday(date1: dateAssigned, date2: currentDate) {
            attString = "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.timeStyle = .none
            if dateAssigned.get(.year) == Date.now.get(.year) { //this year
                formatter.setLocalizedDateFormatFromTemplate("MMMd")
            } else { //other years
                formatter.dateStyle = .short
            }
            
            attString = formatter.string(from: dateAssigned)
        }
        
        if isDueTimeAssigned {
            let formatter2 = DateFormatter()
            formatter2.timeStyle = .short
            formatter2.dateFormat = .none
            attString.append(", \(formatter2.string(from: dateAssigned))")
        }
        
        return attString
    }
    
    func isOverdue(currentDate: Date) -> Bool {
        if !isDateAssigned { return false }
        return currentDate > dateAssigned
    }
    
    func isSameDay(date1: Date, date2: Date) -> Bool {
        let diff = date1.get(.day, calendar: Calendar.current) - date2.get(.day, calendar: Calendar.current)
        return diff == 0
    }
    func isYesterday(date1: Date, date2: Date) -> Bool {
        let diff = date1.get(.day, calendar: Calendar.current) - date2.get(.day, calendar: Calendar.current)
        return diff == -1
    }
    func isTomorrow(date1: Date, date2: Date) -> Bool {
        let diff = date1.get(.day, calendar: Calendar.current) - date2.get(.day, calendar: Calendar.current)
        return diff == 1
    }
}

class WidgetSync {
    static let maxNumberOfTasks = 15
    
    static let userDefaults = UserDefaults(suiteName: "group.finale-to-do-widget-cache")!
    
    static let widgetUpcomingTasksSyncKey = "FINALE_DEV_APP_widgetUpcomingTasks"
    static let widgetCompletedTasksSyncKey = "FINALE_DEV_APP_widgetCompletedTasks"
    static let widgetTitleSyncKey = "FINALE_DEV_APP_widgetTitle"
    static let widgetTasksNumberKey = "FINALE_DEV_APP_widgetTaskNumber"
}
