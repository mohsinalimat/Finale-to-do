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
    var isCompleted: Bool
    var isDateAssigned: Bool
    var isNotificationEnabled: Bool
    var dateAssigned: Date
    var dateCreated: Date
    var dateCompleted: Date
    let taskListID: UUID
    
    init () {
        self.name = ""
        self.isCompleted = false
        self.isDateAssigned = false
        self.isNotificationEnabled = false
        self.dateAssigned = Date(timeIntervalSince1970: 0)
        self.dateCreated = Date(timeIntervalSince1970: 0)
        self.dateCompleted = Date(timeIntervalSince1970: 0)
        self.taskListID = UUID()
    }
    
    init(name: String, isComleted: Bool = false, isDateAssigned: Bool = false, isNotificationEnabled: Bool = false, dateAssigned: Date = Date(timeIntervalSince1970: 0), dateCreated: Date = Date(timeIntervalSince1970: 0), dateCompleted: Date = Date(timeIntervalSince1970: 0), taskListID: UUID = UUID()) {
        self.name = name
        self.isCompleted = isComleted
        self.isDateAssigned = isDateAssigned
        self.isNotificationEnabled = isNotificationEnabled
        self.dateAssigned = dateAssigned
        self.dateCreated = dateCreated
        self.dateCompleted = dateCompleted
        self.taskListID = taskListID
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TaskCodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        isDateAssigned = try container.decode(Bool.self, forKey: .isDateAssigned)
        isNotificationEnabled = try container.decode(Bool.self, forKey: .isNotificationEnabled)
        dateAssigned = try container.decode(Date.self, forKey: .dateAssigned)
        dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        dateCompleted = try container.decode(Date.self, forKey: .dateCompleted)
        taskListID = try container.decode(UUID.self, forKey: .taskListID)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: TaskCodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(isDateAssigned, forKey: .isDateAssigned)
        try container.encode(isNotificationEnabled, forKey: .isNotificationEnabled)
        try container.encode(dateAssigned, forKey: .dateAssigned)
        try container.encode(dateCreated, forKey: .dateCreated)
        try container.encode(dateCompleted, forKey: .dateCompleted)
        try container.encode(taskListID, forKey: .taskListID)
    }
    
    static func == (lhs: Task, rhs: Task) -> Bool {
        return
        lhs.name == rhs.name &&
        lhs.isCompleted == rhs.isCompleted &&
        lhs.dateAssigned == rhs.dateAssigned &&
        lhs.dateCreated == rhs.dateCreated &&
        lhs.dateCompleted == rhs.dateCompleted &&
        lhs.taskListID == rhs.taskListID
    }
}

class TaskList: Codable {
    
    var id: UUID
    var name: String
    var primaryColor: UIColor
    var systemIcon: String
    var upcomingTasks: [Task]
    var completedTasks: [Task]
    
    init(name: String, primaryColor: UIColor = UIColor.defaultColor, systemIcon: String = "folder.fill", upcomingTasks: [Task] = [Task](), completedTasks: [Task] = [Task](), id: UUID = UUID()) {
        self.name = name
        self.upcomingTasks = upcomingTasks
        self.systemIcon = systemIcon
        self.completedTasks = completedTasks
        self.primaryColor = primaryColor
        self.id = id
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TaskListCodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        upcomingTasks = try container.decode([Task].self, forKey: .upcomingTasks)
        systemIcon = try container.decode(String.self, forKey: .systemIcon)
        completedTasks = try container.decode([Task].self, forKey: .completedTasks)
        primaryColor = try container.decode(Color.self, forKey: .primaryColor).uiColor
        id = try container.decode(UUID.self, forKey: .id)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: TaskListCodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(upcomingTasks, forKey: .upcomingTasks)
        try container.encode(systemIcon, forKey: .systemIcon)
        try container.encode(completedTasks, forKey: .completedTasks)
        try container.encode(Color(uiColor: primaryColor), forKey: .primaryColor)
        try container.encode(id, forKey: .id)
    }
}

enum TaskCodingKeys: CodingKey {
    case name
    case isCompleted
    case isDateAssigned
    case isNotificationEnabled
    case dateAssigned
    case dateCreated
    case dateCompleted
    case taskListID
}
enum TaskListCodingKeys: CodingKey {
    case name
    case upcomingTasks
    case systemIcon
    case completedTasks
    case primaryColor
    case id
}
