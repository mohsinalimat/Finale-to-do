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
    let date: Date
}

class WidgetSync {
    static let userDefaults = UserDefaults(suiteName: "group.finale-to-do-widget-cache")!
    
    static let widgetTasksSyncKey = "FINALE_DEV_APP_widgetTasks"
    static let widgetTitleSyncKey = "FINALE_DEV_APP_widgetTitle"
}
