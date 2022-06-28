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
    let isCompleted: Bool
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
        if isToday(currentDate: currentDate) {
            attString = "Today"
        } else if isTomorrow(currentDate: currentDate) {
            attString = "Tomorrow"
        } else if isYesterday(currentDate: currentDate) {
            attString = "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.timeStyle = .none
            if dateAssigned.get(.year) == Date().get(.year) { //this year
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
    
    func isToday(currentDate: Date) -> Bool {
        if !isThisYearAndMonth(currentDate: currentDate) { return false }
        
        let diff = dateAssigned.get(.day, calendar: Calendar.current) - currentDate.get(.day, calendar: Calendar.current)
        return diff == 0
    }
    func isYesterday(currentDate: Date) -> Bool {
        if !isThisYearAndMonth(currentDate: currentDate) { return false }
        
        let diff = dateAssigned.get(.day, calendar: Calendar.current) - currentDate.get(.day, calendar: Calendar.current)
        return diff == -1
    }
    func isTomorrow(currentDate: Date) -> Bool {
        if !isThisYearAndMonth(currentDate: currentDate) { return false }
        
        let diff = dateAssigned.get(.day, calendar: Calendar.current) - currentDate.get(.day, calendar: Calendar.current)
        return diff == 1
    }
    
    func isThisWeek(currentDate: Date) -> Bool {
        if !isThisYearAndMonth(currentDate: currentDate) { return false }
        
        let diff = dateAssigned.get(.weekOfYear, calendar: Calendar.current) - currentDate.get(.weekOfYear, calendar: Calendar.current)
        return diff == 0
    }
    
    func isNextWeek(currentDate: Date) -> Bool {
        if !isThisYearAndMonth(currentDate: currentDate) { return false }
        
        let diff = dateAssigned.get(.weekOfYear, calendar: Calendar.current) - currentDate.get(.weekOfYear, calendar: Calendar.current)
        return diff == 1
    }
    
    func isThisMonth(currentDate: Date) -> Bool {
        if !isThisYearAndMonth(currentDate: currentDate) { return false }
        
        let diff = dateAssigned.get(.month, calendar: Calendar.current) - currentDate.get(.month, calendar: Calendar.current)
        return diff == 0
    }
    
    func isThisYearAndMonth (currentDate: Date) -> Bool {
        if dateAssigned.get(.month, calendar: Calendar.current) - currentDate.get(.month, calendar: Calendar.current) != 0 { return false }
        if dateAssigned.get(.year, calendar: Calendar.current) - currentDate.get(.year, calendar: Calendar.current) != 0 { return false }
        return true
    }
}

class WidgetSync {
    static let maxNumberOfTasks = 130
    
    static let userDefaults = UserDefaults(suiteName: "group.finale-to-do-widget-cache")!
    
    static let widgetUpcomingTasksSyncKey = "FINALE_DEV_APP_widgetUpcomingTasks"
    static let widgetCompletedTasksSyncKey = "FINALE_DEV_APP_widgetCompletedTasks"
    static let widgetTitleSyncKey = "FINALE_DEV_APP_widgetTitle"
    static let widgetTasksNumberKey = "FINALE_DEV_APP_widgetTaskNumber"
}
