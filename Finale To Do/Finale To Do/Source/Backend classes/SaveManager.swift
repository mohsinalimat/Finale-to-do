//
//  SaveManager.swift
//  Finale To Do
//
//  Created by Grant Oganan on 6/9/22.
//

import Foundation
import UIKit

class SaveManager {
    
    static var instance = SaveManager()
    
    let settingsKey = "FINALE_DEV_APP_settingsConfig"
    let overviewSortingPrefKey = "FINALE_DEV_APP_overviewSortingPreference"
    let mainTaskListKey = "FINALE_DEV_APP_mainTaskList"
    let userTaskListKey = "FINALE_DEV_APP_userTaskLists"
    let statsKey = "FINALE_DEV_APP_stats"
    let lastICloudSyncKey = "FINALE_DEV_APP_lastICloudSyncDate"
    let lastLocalSaveKey = "FINALE_DEV_APP_lastICloudSaveDate"
    let deviceNameKey = "FINALE_DEV_APP_deviceName"

    
//MARK: Load
    func LoadData () {
        if let data = UserDefaults.standard.data(forKey: settingsKey) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] { DecodeSettings(json: json) }
            } catch let error as NSError { print("Failed to load: \(error.localizedDescription)") }
        } else {
            if let data = NSUbiquitousKeyValueStore().data(forKey: settingsKey) {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] { DecodeSettings(json: json) }
                } catch let error as NSError { print("Failed to load: \(error.localizedDescription)") }
            }
        }
        
        let keyStore = App.settingsConfig.isICloudSyncOn ? NSUbiquitousKeyValueStore() : nil
        
        if App.settingsConfig.isICloudSyncOn {
            let lastICloudSync = keyStore?.object(forKey: lastICloudSyncKey) as? Date
            let lastLocalSync = UserDefaults.standard.value(forKey: lastLocalSaveKey) as? Date
            
            if lastLocalSync != nil && lastICloudSync != nil {
                if lastLocalSync! > lastICloudSync! {
                    LoadLocalData()
                } else {
                    LoadICloudData(iCloudKey: keyStore!)
                }
            } else if lastICloudSync != nil && lastLocalSync == nil {
                LoadICloudData(iCloudKey: keyStore!)
            } else {
                LoadLocalData()
            }
        } else {
            LoadLocalData()
        }
        
        var isDefaultListSet = false
        if App.settingsConfig.defaultListID == App.mainTaskList.id { isDefaultListSet = true }
        if !isDefaultListSet {
            for taskList in App.userTaskLists {
                if taskList.id == App.settingsConfig.defaultListID {
                    isDefaultListSet = true
                    break
                }
            }
        }
        if !isDefaultListSet { App.settingsConfig.defaultListID = App.mainTaskList.id }
        
        App.instance.RemoveExcessCompletedTasks()
        ThemeManager.currentTheme = App.settingsConfig.GetCurrentTheme()
        
        if !App.settingsConfig.completedInitialSetup {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                App.instance.present(WelcomeScreenNavController(), animated: true)
            }
        }
    }
    
    func LoadLocalData () {
        App.instance.overviewSortingPreference = SortingPreference(rawValue: UserDefaults.standard.integer(forKey: overviewSortingPrefKey))
        if App.instance.overviewSortingPreference == .Unsorted { App.instance.overviewSortingPreference = .ByList }

        if let data = UserDefaults.standard.data(forKey: mainTaskListKey) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] { App.mainTaskList = DecodeTaskList(json: json, defaultTaskList: App.mainTaskList) }
            } catch let error as NSError { print("Failed to load: \(error.localizedDescription)") }
            
//            if let decoded = try? JSONDecoder().decode(TaskList.self, from: data) {
//                App.mainTaskList = decoded
//            }
        }
        if let data = UserDefaults.standard.data(forKey: userTaskListKey) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] { App.userTaskLists = DecodeTaskListArray(json: json) }
            } catch let error as NSError { print("Failed to load: \(error.localizedDescription)") }
//            if let decoded = try? JSONDecoder().decode([TaskList].self, from: data) {
//                App.userTaskLists = decoded
//            }
        }
        if let data = UserDefaults.standard.data(forKey: statsKey) {
            if let decoded = try? JSONDecoder().decode(StatsConfig.self, from: data) {
                StatsManager.stats = decoded
            }
        }
    }
    
    func LoadICloudData (iCloudKey: NSUbiquitousKeyValueStore) {
        if let data = iCloudKey.data(forKey: settingsKey) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] { DecodeSettings(json: json) }
            } catch let error as NSError { print("Failed to load: \(error.localizedDescription)") }
        }
        
        if let osp = iCloudKey.object(forKey: overviewSortingPrefKey) as? Int {
            App.instance.overviewSortingPreference = SortingPreference(rawValue: osp)
            if App.instance.overviewSortingPreference == .Unsorted { App.instance.overviewSortingPreference = .ByList }
        } else {
            App.instance.overviewSortingPreference = .ByList
        }

        if let data = iCloudKey.data(forKey: mainTaskListKey) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] { App.mainTaskList = DecodeTaskList(json: json, defaultTaskList: App.mainTaskList) }
            } catch let error as NSError { print("Failed to load: \(error.localizedDescription)") }
            
//            if let decoded = try? JSONDecoder().decode(TaskList.self, from: data) {
//                App.mainTaskList = decoded
//            }
        }
        if let data = iCloudKey.data(forKey: userTaskListKey) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] { App.userTaskLists = DecodeTaskListArray(json: json) }
            } catch let error as NSError { print("Failed to load: \(error.localizedDescription)") }
            
//            if let decoded = try? JSONDecoder().decode([TaskList].self, from: data) {
//                App.userTaskLists = decoded
//            }
        }
        if let data = iCloudKey.data(forKey: statsKey) {
            if let decoded = try? JSONDecoder().decode(StatsConfig.self, from: data) {
                StatsManager.stats = decoded
            }
        }
    }
    
    func DecodeSettings (json: [String: Any]) {
        for (key, value) in json {
            if key == "userFirstName" { App.settingsConfig.userFirstName = value as? String ?? App.settingsConfig.userFirstName}
            else if key == "userLastName" { App.settingsConfig.userLastName = value as? String ?? App.settingsConfig.userLastName}
            else if key == "isICloudSyncOn" { App.settingsConfig.isICloudSyncOn = value as? Bool ?? App.settingsConfig.isICloudSyncOn}
            else if key == "defaultListID" {
                App.settingsConfig.defaultListID = (value as? String) != nil ? UUID(uuidString: (value as! String))! : App.settingsConfig.defaultListID
            }
            else if key == "isNotificationsAllowed" { App.settingsConfig.isNotificationsAllowed = value as? Bool ?? App.settingsConfig.isNotificationsAllowed}
            else if key == "appBadgeNumberTypes" {
                App.settingsConfig.appBadgeNumberTypes = (value as? [Int])?.compactMap{ AppBadgeNumberType(rawValue: $0) } ?? App.settingsConfig.appBadgeNumberTypes
            }
            else if key == "widgetLists" {
                App.settingsConfig.widgetLists = (value as? [String])?.compactMap{ UUID(uuidString: $0) } ?? App.settingsConfig.widgetLists
            }
            else if key == "interface" {
                App.settingsConfig.interface = (value as? Int) != nil ? InterfaceMode(rawValue: (value as! Int))! : App.settingsConfig.interface
            }
            else if key == "selectedLightThemeIndex" { App.settingsConfig.selectedLightThemeIndex = value as? Int ?? App.settingsConfig.selectedLightThemeIndex}
            else if key == "selectedDarkThemeIndex" { App.settingsConfig.selectedDarkThemeIndex = value as? Int ?? App.settingsConfig.selectedDarkThemeIndex}
            else if key == "selectedIcon" {
                App.settingsConfig.selectedIcon = (value as? Int) != nil ? AppIcon(rawValue: (value as! Int))! : App.settingsConfig.selectedIcon
            }
            else if key == "completedInitialSetup" { App.settingsConfig.completedInitialSetup = value as? Bool ?? App.settingsConfig.completedInitialSetup}
            else if key == "smartLists" {
                App.settingsConfig.smartLists = (value as? [Int])?.compactMap{ SmartList(rawValue: $0) } ?? App.settingsConfig.smartLists
            }
        }
    }
    
    func DecodeTaskListArray (json: [ [String:Any] ]) -> [TaskList] {
        var taskListArray = [TaskList]()
        for taskList in json {
            taskListArray.append(DecodeTaskList(json: taskList, defaultTaskList: TaskList(name: "")))
        }
        return taskListArray
    }
    
    func DecodeTaskList (json: [String: Any], defaultTaskList: TaskList) -> TaskList {
        let taskList = TaskList(name: "")
        for (key, value) in json {
            if key == "id" { taskList.id = (value as? String) != nil ? UUID(uuidString: (value as! String))! : defaultTaskList.id }
            else if key == "name" { taskList.name = value as? String ?? defaultTaskList.name }
            else if key == "primaryColor" { taskList.primaryColor = (value as? [String: Double]) != nil ? DecodeColor(data: value as! [String: Double]) : defaultTaskList.primaryColor }
            else if key == "systemIcon" { taskList.systemIcon = value as? String ?? defaultTaskList.systemIcon }
            else if key == "sortingPreference" { taskList.sortingPreference = (value as? Int) != nil ? SortingPreference(rawValue: (value as! Int))! : defaultTaskList.sortingPreference }
            else if key == "upcomingTasks" { taskList.upcomingTasks = (value as? [ [String: Any] ]) != nil ? DecodeTaskArray(data: (value as! [ [String: Any] ])) : defaultTaskList.upcomingTasks }
            else if key == "completedTasks" { taskList.completedTasks = (value as? [ [String: Any] ]) != nil ? DecodeTaskArray(data: (value as! [ [String: Any] ])) : defaultTaskList.completedTasks }
        }
        return taskList
    }
    
    func DecodeColor (data: [String: Double]) -> UIColor {
        var r = 0.0, g = 0.0, b = 0.0, a = 0.0
        for (key, value) in data {
            if key == "red" { r = value }
            else if key == "green" { g = value }
            else if key == "blue" { b = value }
            else if key == "alpha" { a = value }
        }
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    func DecodeTaskArray (data: [ [String: Any] ] ) -> [Task] {
        var array = [Task]()
        
        for item in data {
            array.append(DecodeTask(data: item))
        }
        
        return array
    }
    
    func DecodeTask (data: [String: Any]) -> Task {
        let task = Task()
        
        for (key, value) in data {
            if key == "name" { task.name = value as? String ?? task.name }
            else if key == "priority" { task.priority = (value as? Int) != nil ? TaskPriority(rawValue: value as! Int)! : task.priority }
            else if key == "notes" { task.notes = value as? String ?? task.notes }
            else if key == "isCompleted" { task.isCompleted = value as? Bool ?? task.isCompleted }
            else if key == "isDateAssigned" { task.isDateAssigned = value as? Bool ?? task.isDateAssigned }
            else if key == "isDueTimeAssigned" { task.isDueTimeAssigned = value as? Bool ?? task.isDueTimeAssigned }
            else if key == "dateAssigned" { task.dateAssigned = (value as? Double) != nil ? Date(timeIntervalSinceReferenceDate: value as! Double) : task.dateAssigned }
            else if key == "dateCreated" { task.dateCreated = (value as? Double) != nil ? Date(timeIntervalSinceReferenceDate: value as! Double) : task.dateCreated }
            else if key == "dateCompleted" { task.dateCompleted = (value as? Double) != nil ? Date(timeIntervalSinceReferenceDate: value as! Double) : task.dateCompleted }
            else if key == "notifications" {
                if (value as? NSArray) == nil { continue }
                
                var k = 0
                for i in value as! NSArray {
                    if (i as? Int) != nil { k = i as! Int }
                    else if (i as? String) != nil {
                        task.notifications[NotificationType(rawValue: k)!] = (i as! String)
                    }
                }
            }
            else if key == "repeating" {
                for i in value as! [Int] {
                    task.repeating.append(TaskRepeatType(rawValue: i)!)
                }
            }
            else if key == "taskListID" { task.taskListID = (value as? String) != nil ? UUID(uuidString: (value as! String))! : task.taskListID}
        }
        
        return task
    }
    
//MARK: Save
    
    func SaveData () {
        let keyStore = App.settingsConfig.isICloudSyncOn ? NSUbiquitousKeyValueStore() : nil
        
        SaveValue(value: App.instance.overviewSortingPreference.rawValue, forKey: overviewSortingPrefKey, iCloudKey: keyStore)
        
        if let encoded = try? JSONEncoder().encode(App.mainTaskList) {
            SaveValue(value: encoded, forKey: mainTaskListKey, iCloudKey: keyStore)
        }
        if let encoded = try? JSONEncoder().encode(App.userTaskLists) {
            SaveValue(value: encoded, forKey: userTaskListKey, iCloudKey: keyStore)
        }
        if let encoded = try? JSONEncoder().encode(StatsManager.stats) {
            SaveValue(value: encoded, forKey: statsKey, iCloudKey: keyStore)
        }
        
        UserDefaults.standard.set(Date.now, forKey: lastLocalSaveKey)
        keyStore?.set(Calendar.current.date(byAdding: .minute, value: -1, to: Date.now), forKey: lastICloudSyncKey)
        keyStore?.set(UIDevice.current.name, forKey: deviceNameKey)
        keyStore?.synchronize()
    }
    
    func SaveSettings () {
        let keyStore = App.settingsConfig.isICloudSyncOn ? NSUbiquitousKeyValueStore() : nil

        if let encoded = try? JSONEncoder().encode(App.settingsConfig) {
            SaveValue(value: encoded, forKey: settingsKey, iCloudKey: keyStore)
        }

        keyStore?.synchronize()
    }
    
    func SaveValue(value: Any, forKey: String, iCloudKey: NSUbiquitousKeyValueStore? = nil) {
        UserDefaults.standard.set(value, forKey: forKey)
        iCloudKey?.set(value, forKey: forKey)
    }
    
    func RemoveICloudSaveFiles () {
        let keyStore = NSUbiquitousKeyValueStore()
        
        if ((keyStore.object(forKey: lastICloudSyncKey) as? Date) != nil) {
            keyStore.removeObject(forKey: settingsKey)
            keyStore.removeObject(forKey: overviewSortingPrefKey)
            keyStore.removeObject(forKey: mainTaskListKey)
            keyStore.removeObject(forKey: userTaskListKey)
            keyStore.removeObject(forKey: statsKey)
            keyStore.removeObject(forKey: lastICloudSyncKey)
            keyStore.removeObject(forKey: lastLocalSaveKey)
            keyStore.removeObject(forKey: deviceNameKey)
            keyStore.synchronize()
        }
    }
    
}
