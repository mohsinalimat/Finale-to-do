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
    var notifications: [NotificationType : [String]]
    var repeating: [TaskRepeatType]
    var isCompleted: Bool
    var isDateAssigned: Bool
    var isDueTimeAssigned: Bool
    var dateAssigned: Date
    var dateCreated: Date
    var dateCompleted: Date
    var taskListID: UUID
    
    init () {
        self.name = ""
        self.priority = .Normal
        self.notes = ""
        self.notifications = [NotificationType : [String]]()
        self.repeating = [TaskRepeatType]()
        self.isCompleted = false
        self.isDateAssigned = false
        self.isDueTimeAssigned = false
        self.dateAssigned = Date(timeIntervalSince1970: 0)
        self.dateCreated = Date()
        self.dateCompleted = Date(timeIntervalSince1970: 0)
        self.taskListID = UUID()
    }
    
    init(name: String = "", priority: TaskPriority = .Normal, notes: String = "", repeating: [TaskRepeatType] = [], isComleted: Bool = false, isDateAssigned: Bool = false, isDueTimeAssigned: Bool = false, dateAssigned: Date = Date(timeIntervalSince1970: 0), dateCreated: Date = Date(), dateCompleted: Date = Date(timeIntervalSince1970: 0), notifications: [NotificationType : [String]] = [NotificationType : [String]](), taskListID: UUID = UUID()) {
        self.name = name
        self.priority = priority
        self.notes = notes
        self.notifications = notifications
        self.repeating = repeating
        self.isCompleted = isComleted
        self.isDateAssigned = isDateAssigned
        self.isDueTimeAssigned = isDueTimeAssigned
        self.dateAssigned = dateAssigned
        self.dateCreated = dateCreated
        self.dateCompleted = dateCompleted
        self.taskListID = taskListID
    }
    
    var isOverdue: Bool {
        if !isDateAssigned { return false }
        if isCompleted { return false }
        return Date() > dateAssigned
    }
    
    func containsNotification (notificationType: NotificationType) -> Bool {
        return self.notifications[notificationType] != nil
    }
    
    func AddNotification (notificationType: NotificationType) {
        if self.containsNotification(notificationType: notificationType) { return }
        
        self.notifications[notificationType] = [UUID().uuidString]
    }
    
    func RemoveNotification (notificationType: NotificationType) {
        if !containsNotification(notificationType: notificationType) { return }
        
        self.notifications.removeValue(forKey: notificationType)
    }
    
    func RemoveAllNotifications () {
        for (notificationType, _) in self.notifications {
            RemoveNotification(notificationType: notificationType)
        }
    }
    
    func CancelAllNotifications () {
        for (_, ids) in self.notifications {
            for id in ids {
                NotificationHelper.CancelNotification(id: id)
            }
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
        notifications = try container.decode([NotificationType : [String]].self, forKey: .notifications)
        repeating = try container.decode([TaskRepeatType].self, forKey: .repeating)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        isDateAssigned = try container.decode(Bool.self, forKey: .isDateAssigned)
        isDueTimeAssigned = try container.decode(Bool.self, forKey: .isDueTimeAssigned)
        dateAssigned = try container.decode(Date.self, forKey: .dateAssigned)
        dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        dateCompleted = try container.decode(Date.self, forKey: .dateCompleted)
        taskListID = try container.decode(UUID.self, forKey: .taskListID)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: TaskCodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(priority, forKey: .priority)
        try container.encode(notes, forKey: .notes)
        try container.encode(notifications, forKey: .notifications)
        try container.encode(repeating, forKey: .repeating)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(isDateAssigned, forKey: .isDateAssigned)
        try container.encode(isDueTimeAssigned, forKey: .isDueTimeAssigned)
        try container.encode(dateAssigned, forKey: .dateAssigned)
        try container.encode(dateCreated, forKey: .dateCreated)
        try container.encode(dateCompleted, forKey: .dateCompleted)
        try container.encode(taskListID, forKey: .taskListID)
    }
    
    static func == (lhs: Task, rhs: Task) -> Bool {
        return
        lhs.name == rhs.name &&
        lhs.priority == rhs.priority &&
        lhs.notes == rhs.notes &&
        lhs.notifications == rhs.notifications &&
        lhs.repeating == rhs.repeating &&
        lhs.isCompleted == rhs.isCompleted &&
        lhs.isDateAssigned == rhs.isDateAssigned &&
        lhs.isDueTimeAssigned == rhs.isDueTimeAssigned &&
        lhs.dateAssigned == rhs.dateAssigned &&
        lhs.dateCreated == rhs.dateCreated &&
        lhs.dateCompleted == rhs.dateCompleted &&
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
    
    init(name: String, primaryColor: UIColor = AddListView.colors.first!, systemIcon: String = AddListView.icons.first!, sortingPreference: SortingPreference = .Unsorted, upcomingTasks: [Task] = [Task](), completedTasks: [Task] = [Task](), id: UUID = UUID()) {
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
        primaryColor = try container.decode(CodableColor.self, forKey: .primaryColor).uiColor
        systemIcon = try container.decode(String.self, forKey: .systemIcon)
        sortingPreference = try container.decode(SortingPreference.self, forKey: .sortingPreference)
        upcomingTasks = try container.decode([Task].self, forKey: .upcomingTasks)
        completedTasks = try container.decode([Task].self, forKey: .completedTasks)
        id = try container.decode(UUID.self, forKey: .id)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: TaskListCodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(CodableColor(uiColor: primaryColor), forKey: .primaryColor)
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
    var userFirstName: String = ""
    var userLastName: String = ""
    
    var isICloudSyncOn: Bool = false
    
    var defaultListID: UUID = UUID()
    var smartLists: [SmartList] = [.Overview]
    var listsShownInSmartLists: [UUID] = []
    var hideCompletedTasks: Bool = false
    
    var isNotificationsAllowed: Bool = false
    var isNaggingModeOn: Bool = false
    var defaultNoTimeNotificationTypes: [NotificationType] = []
    var defaultDueTimeNotificationTypes: [NotificationType] = [.OnTime]
    var appBadgeNumberTypes: [AppBadgeNumberType] = [.OverdueTasks]
    
    var widgetLists: [UUID] = []
    
    var interface: InterfaceMode = .System
    var selectedLightThemeIndex: Int = 0
    var selectedDarkThemeIndex: Int = 0
    var selectedIcon: AppIcon = .classic
    
    var completedInitialSetup: Bool = false
    
    var maxNumberOfCompletedTasks: Int {
        StatsManager.getLevelPerk(type: .HigherTaskHistoryLimit).isUnlocked ? 100 : 50
    }
    
    let maxTasksIfCompletedTasksHidden = 5
    
    var userFullName: String {
        if userFirstName == "" { return userLastName }
        if userLastName == "" { return userFirstName }
        if userFirstName == "" && userLastName == "" { return "" }
        return "\(userFirstName) \(userLastName)"
    }
    
    func GetCurrentTheme() -> AppTheme {
        var mode = interface
        if mode == .System {
            mode = UITraitCollection.current.userInterfaceStyle == .light ? .Light : .Dark
        }
        return mode == .Light ? ThemeManager.lightThemes[selectedLightThemeIndex] : ThemeManager.darkThemes[selectedDarkThemeIndex]
    }
}


enum TaskPriority: Int, Codable, CaseIterable {
    case Normal = 0
    case High = 1
    
    var str: String {
        return self == .Normal ? "Normal" : "High"
    }
}

enum TaskRepeatType: Int, Codable, CaseIterable {
    case Daily = 0
    case Weekly = 1
    case Monthly = 2
    case Monday = 3
    case Tuesday = 4
    case Wednesday = 5
    case Thursday = 6
    case Friday = 7
    case Saturday = 8
    case Sunday = 9
    
    var longStr: String {
        switch self {
        case .Daily: return "Daily"
        case .Weekly: return "Weekly"
        case .Monthly: return "Monthly"
        case .Monday: return "Mon"
        case .Tuesday: return "Tue"
        case .Wednesday: return "Wed"
        case .Thursday: return "Thu"
        case .Friday: return "Fri"
        case .Saturday: return "Sat"
        case .Sunday: return "Sun"
        }
    }
    var shortStr: String {
        switch self {
        case .Daily: return "Daily"
        case .Weekly: return "Weekly"
        case .Monthly: return "Monthly"
        case .Monday: return "M"
        case .Tuesday: return "T"
        case .Wednesday: return "W"
        case .Thursday: return "T"
        case .Friday: return "F"
        case .Saturday: return "S"
        case .Sunday: return "S"
        }
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

enum AppBadgeNumberType: Int, Codable {
    case None = 0
    case TasksToday = 1
    case TasksTomorrow = 2
    case OverdueTasks = 3
    case AllUpcomingTasks = 4
    
    var str: String {
        switch self {
        case .None:
            return "None"
        case .TasksToday:
            return "Tasks today"
        case .TasksTomorrow:
            return "Tasks tomorrow"
        case .OverdueTasks:
            return "Overdue tasks"
        case .AllUpcomingTasks:
            return "All upcoming tasks"
        }
    }
}

enum InterfaceMode: Int, Codable {
    case System = 0
    case Light = 1
    case Dark = 2
    
    var str: String {
        switch self {
        case .System:
            return "System"
        case .Light:
            return "Light"
        case .Dark:
            return "Dark"
        }
    }
}

enum TaskCodingKeys: CodingKey {
    case name
    case priority
    case notes
    case notifications
    case repeating
    case isCompleted
    case isDateAssigned
    case isDueTimeAssigned
    case dateAssigned
    case dateCreated
    case dateCompleted
    case indexInOverview
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
    
    func ReloadThemeColors ()
    
}


enum SmartList: Int, Codable, CaseIterable {
    case Overview = 0
    case Upcoming = 1
    
    var title: String {
        switch self {
        case .Overview:
            return "Overview"
        case .Upcoming:
            return "Upcoming"
        }
    }
    
    var taskListHeaderTitle: String {
        switch self {
        case .Overview:
            return App.settingsConfig.userFirstName == "" ? "Overview" : "Hi, \(App.settingsConfig.userFirstName)"
        case .Upcoming:
            return "Upcoming"
        }
    }
    
    var icon: String {
        switch self {
        case .Overview:
            return "tray.full.fill"
        case .Upcoming:
            return "calendar.badge.clock"
        }
    }
    
    var viewClass: UIView.Type {
        switch self {
        case .Overview:
            return TaskListView.self
        case .Upcoming:
            return UpcomingTasksView.self
        }
    }
    
    var taskCountNumber: (()->Int)? {
        switch self {
        case .Overview:
            return nil
        case .Upcoming:
            return {
                var n = 0
                for list in App.instance.allTaskLists {
                    if App.settingsConfig.listsShownInSmartLists.count != 0 && !App.settingsConfig.listsShownInSmartLists.contains(list.id) { continue }
                    
                    for task in list.upcomingTasks {
                        if task.isOverdue {
                            n += 1
                        } else if task.isDateAssigned && Calendar.current.isDateInToday(task.dateAssigned) {
                            n += 1
                        }
                    }
                }
                return n
            }
        }
    }
}
