//
//  Classes.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/14/22.
//

import Foundation
import UIKit

class Task: Codable, Equatable {
    
    var name: String
    var priority: TaskPriority
    var notes: String
    var isCompleted: Bool
    var isDateAssigned: Bool
    var isDueTimeAssigned: Bool
    var dateAssigned: Date
    var dateCreated: Date
    var dateCompleted: Date
    var notifications: [NotificationType : String]
    var taskListID: UUID
    
    init () {
        self.name = ""
        self.priority = .Normal
        self.notes = ""
        self.isCompleted = false
        self.isDateAssigned = false
        self.isDueTimeAssigned = false
        self.dateAssigned = Date(timeIntervalSince1970: 0)
        self.dateCreated = Date()
        self.dateCompleted = Date(timeIntervalSince1970: 0)
        self.notifications = [NotificationType : String]()
        self.taskListID = UUID()
    }
    
    init(name: String = "", priority: TaskPriority = .Normal, notes: String = "", isComleted: Bool = false, isDateAssigned: Bool = false, isDueTimeAssigned: Bool = false, dateAssigned: Date = Date(timeIntervalSince1970: 0), dateCreated: Date = Date.now, dateCompleted: Date = Date(timeIntervalSince1970: 0), notifications: [NotificationType : String] = [NotificationType : String](), taskListID: UUID = UUID()) {
        self.name = name
        self.priority = priority
        self.notes = notes
        self.isCompleted = isComleted
        self.isDateAssigned = isDateAssigned
        self.isDueTimeAssigned = isDueTimeAssigned
        self.dateAssigned = dateAssigned
        self.dateCreated = dateCreated
        self.dateCompleted = dateCompleted
        self.notifications = notifications
        self.taskListID = taskListID
    }
    
    var isOverdue: Bool {
        if !isDateAssigned { return false }
        if isCompleted { return false }
        return Date.now > dateAssigned
    }
    
    func containsNotification (notificationType: NotificationType) -> Bool {
        return self.notifications[notificationType] != nil
    }
    
    func AddNotification (notificationType: NotificationType) {
        if self.containsNotification(notificationType: notificationType) { return }
        
        self.notifications[notificationType] = UUID().uuidString
    }
    
    func RemoveNotification (notificationType: NotificationType) {
        if !containsNotification(notificationType: notificationType) { return }
        
        NotificationHelper.CancelNotification(id: self.notifications[notificationType]!)
        self.notifications.removeValue(forKey: notificationType)
    }
    
    func RemoveAllNotifications () {
        for (notificationType, _) in self.notifications {
            RemoveNotification(notificationType: notificationType)
        }
    }
    
    func CancelAllNotifications () {
        for (_, id) in self.notifications {
            NotificationHelper.CancelNotification(id: id)
        }
    }
    
    func ScheduleAllNotifications () {
        NotificationHelper.ScheduleNotificationsForTask(task: self)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TaskCodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        priority = try container.decode(TaskPriority.self, forKey: .priority)
        notes = try container.decode(String.self, forKey: .notes)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        isDateAssigned = try container.decode(Bool.self, forKey: .isDateAssigned)
        isDueTimeAssigned = try container.decode(Bool.self, forKey: .isDueTimeAssigned)
        dateAssigned = try container.decode(Date.self, forKey: .dateAssigned)
        dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        dateCompleted = try container.decode(Date.self, forKey: .dateCompleted)
        notifications = try container.decode([NotificationType : String].self, forKey: .notifications)
        taskListID = try container.decode(UUID.self, forKey: .taskListID)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: TaskCodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(priority, forKey: .priority)
        try container.encode(notes, forKey: .notes)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(isDateAssigned, forKey: .isDateAssigned)
        try container.encode(isDueTimeAssigned, forKey: .isDueTimeAssigned)
        try container.encode(dateAssigned, forKey: .dateAssigned)
        try container.encode(dateCreated, forKey: .dateCreated)
        try container.encode(dateCompleted, forKey: .dateCompleted)
        try container.encode(notifications, forKey: .notifications)
        try container.encode(taskListID, forKey: .taskListID)
    }
    
    static func == (lhs: Task, rhs: Task) -> Bool {
        return
        lhs.name == rhs.name &&
        lhs.priority == rhs.priority &&
        lhs.notes == rhs.notes &&
        lhs.isCompleted == rhs.isCompleted &&
        lhs.isDateAssigned == rhs.isDateAssigned &&
        lhs.isDueTimeAssigned == rhs.isDueTimeAssigned &&
        lhs.dateAssigned == rhs.dateAssigned &&
        lhs.dateCreated == rhs.dateCreated &&
        lhs.dateCompleted == rhs.dateCompleted &&
        lhs.notifications == rhs.notifications
        lhs.taskListID == rhs.taskListID
    }
}

class TaskList: Codable, Equatable {
    
    var id: UUID
    var name: String
    var primaryColor: UIColor
    var systemIcon: String
    var sortingPreference: SortingPreference
    var upcomingTasks: [Task]
    var completedTasks: [Task]
    
    init(name: String, primaryColor: UIColor = UIColor.defaultColor, systemIcon: String = "folder.fill", sortingPreference: SortingPreference = .Unsorted, upcomingTasks: [Task] = [Task](), completedTasks: [Task] = [Task](), id: UUID = UUID()) {
        self.name = name
        self.upcomingTasks = upcomingTasks
        self.systemIcon = systemIcon
        self.sortingPreference = sortingPreference
        self.completedTasks = completedTasks
        self.primaryColor = primaryColor
        self.id = id
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TaskListCodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        primaryColor = try container.decode(Color.self, forKey: .primaryColor).uiColor
        systemIcon = try container.decode(String.self, forKey: .systemIcon)
        sortingPreference = try container.decode(SortingPreference.self, forKey: .sortingPreference)
        upcomingTasks = try container.decode([Task].self, forKey: .upcomingTasks)
        completedTasks = try container.decode([Task].self, forKey: .completedTasks)
        id = try container.decode(UUID.self, forKey: .id)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: TaskListCodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(Color(uiColor: primaryColor), forKey: .primaryColor)
        try container.encode(sortingPreference, forKey: .sortingPreference)
        try container.encode(systemIcon, forKey: .systemIcon)
        try container.encode(upcomingTasks, forKey: .upcomingTasks)
        try container.encode(completedTasks, forKey: .completedTasks)
        try container.encode(id, forKey: .id)
    }
    
    static func == (lhs: TaskList, rhs: TaskList) -> Bool {
        return
        lhs.name == rhs.name &&
        lhs.primaryColor == rhs.primaryColor &&
        lhs.systemIcon == rhs.systemIcon &&
        lhs.sortingPreference == rhs.sortingPreference &&
        lhs.upcomingTasks == rhs.upcomingTasks &&
        lhs.completedTasks == rhs.completedTasks &&
        lhs.id == rhs.id
    }
}

struct SettingsConfig: Codable {
    
    var userFirstName: String = "Friend"
    var userLastName: String = ""
    
    var maxNumberOfCompletedTasks: Int = 50
    
}


enum TaskPriority: Int, Codable, CaseIterable {
    case Normal = 0
    case High = 1
    
    var str: String {
        return self == .Normal ? "Normal" : "High"
    }
}

enum SortingPreference: Int, Codable {
    case Unsorted = 0
    case ByList = 1
    case ByTimeCreated = 2
    case ByTimeDue = 3
    case ByPriority = 4
    case ByName = 5
}

enum TaskCodingKeys: CodingKey {
    case name
    case priority
    case notes
    case isCompleted
    case isDateAssigned
    case isDueTimeAssigned
    case dateAssigned
    case dateCreated
    case dateCompleted
    case indexInOverview
    case notifications
    case taskListID
}
enum TaskListCodingKeys: CodingKey {
    case name
    case primaryColor
    case systemIcon
    case sortingPreference
    case upcomingTasks
    case completedTasks
    case id
}

protocol UIDynamicTheme {
    
    func SetThemeColors ()
    
}
