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
    
    var assignedDateTimeString: String {
        if !isDateAssigned {
            return ""
        }
        
        var attString = ""
        if Calendar.current.isDateInToday(dateAssigned) {
            attString = "Today"
        } else if Calendar.current.isDateInTomorrow(dateAssigned) {
            attString = "Tomorrow"
        } else if Calendar.current.isDateInYesterday(dateAssigned) {
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
    
    var isOverdue: Bool {
        if !isDateAssigned { return false }
        return Date.now > dateAssigned
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
