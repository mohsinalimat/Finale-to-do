//
//  ViewController.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/14/22.
//

import UIKit
import SwiftUI

class App: UIViewController {

    static var instance: App!
    
    static var settingsConfig: SettingsConfig = SettingsConfig()
    
    static var mainTaskList: TaskList = TaskList(name: "Main", primaryColor: .defaultColor, systemIcon: "folder.fill")
    static var userTaskLists: [TaskList] = [TaskList]()
    
    static var selectedTaskListIndex: Int = 0
    
    var overviewSortingPreference: SortingPreference!
    
    var lastCompletedTask: Task?
    var lastDeletedTask: Task?
    
    var allTaskLists: [TaskList] {
        var x = [TaskList]()
        x.append(App.mainTaskList)
        x.append(contentsOf: App.userTaskLists)
        return x
    }
    
    var isSideMenuOpen: Bool {
        get {
            return taskListView.frame.origin.x >= sideMenuWidth*0.8
        }
    }
    
    var taskListView: TaskListView!
    var sideMenuView: SideMenuView!
    
    var containerView: UIView!
    var notificationView: NotificationView?
    
    let sideMenuWidth = UIScreen.main.bounds.width*0.8
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        
        App.instance = self
        
        LoadData()
        App.instance.overrideUserInterfaceStyle = App.settingsConfig.interface == .System ? .unspecified : App.settingsConfig.interface == .Light ? .light : .dark

        let sideMenuFrame = CGRect(x: 0, y: 0, width: sideMenuWidth, height: UIScreen.main.bounds.height)
        sideMenuView = SideMenuView(frame: sideMenuFrame, app: self)
        
        let fullScreenFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        taskListView = TaskListView(frame: fullScreenFrame, taskLists: allTaskLists, app: self)
        
        containerView.addSubview(sideMenuView)
        containerView.addSubview(taskListView)
        
        self.view.addSubview(containerView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AppBecameActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        NotificationHelper.CheckNotificationPermissionStatus()
    }
    
//MARK: Task Actions
    
    func CreateNewTask(tasklist: TaskList? = nil) {
        taskListView.tableView.setContentOffset(CGPoint(x: 0, y: taskListView.originalTableContentOffsetY), animated: true)
        
        StopEditingAllTasks()
        
        let newTask: Task
        if App.selectedTaskListIndex == 0 {
            if tasklist == nil {
                newTask = Task(taskListID: defaultList.id)
                defaultList.upcomingTasks.insert(newTask, at: 0)
            }
            else {
                newTask = Task(taskListID: tasklist!.id)
                tasklist!.upcomingTasks.insert(newTask, at: 0)
            }
        } else if App.selectedTaskListIndex == 1 {
            newTask = Task(taskListID: App.mainTaskList.id)
            App.mainTaskList.upcomingTasks.insert(newTask, at: 0)
        } else {
            newTask = Task(taskListID: App.userTaskLists[App.selectedTaskListIndex-2].id)
            App.userTaskLists[App.selectedTaskListIndex-2].upcomingTasks.insert(newTask, at: 0)
        }
        
        taskListView.allUpcomingTasks.insert(newTask, at: 0)

        taskListView.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: UITableView.RowAnimation.automatic)
        taskListView.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: false)
        
        DispatchQueue.main.async { self.sideMenuView.UpdateUpcomingTasksCounts() }
    }
    
    func CompleteTask(task: Task) {
        var index = -1
        
        task.isCompleted = true
        task.dateCompleted = Date.now
        
        if App.mainTaskList.upcomingTasks.contains(task) {
            index = App.mainTaskList.upcomingTasks.firstIndex(of: task) ?? index
            if index == -1 { return }
            
            App.mainTaskList.upcomingTasks.remove(at: index)
            App.mainTaskList.completedTasks.insert(task, at: 0)
        } else {
            for taskList in App.userTaskLists {
                if taskList.id == task.taskListID {
                    index = taskList.upcomingTasks.firstIndex(of: task) ?? index
                    if index == -1 { return }
                    
                    taskList.upcomingTasks.remove(at: index)
                    taskList.completedTasks.insert(task, at: 0)
                    break
                }
            }
        }
        if index == -1 { return }
        
        if index == 0 { taskListView.tableView.setContentOffset(CGPoint(x: 0, y: taskListView.originalTableContentOffsetY), animated: true) } //Jagged animatino glitch fix
        
        let tableIndex = taskListView.allUpcomingTasks.firstIndex(of: task)!
        taskListView.allUpcomingTasks.remove(at: tableIndex)
        taskListView.allCompletedTasks.insert(task, at: 0)
        
        taskListView.tableView.performBatchUpdates({
            taskListView.tableView.deleteRows(at: [IndexPath(row: tableIndex, section: 0)], with: UITableView.RowAnimation.right)
            taskListView.tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: UITableView.RowAnimation.automatic)
        })
        if index == 0 && taskListView.allUpcomingTasks.count > 0 { taskListView.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: false) }
        
        lastCompletedTask = task
        lastDeletedTask = nil
        taskListView.ShowUndoButton()
        
        DispatchQueue.main.async { self.sideMenuView.UpdateUpcomingTasksCounts() }
        
        StatsManager.OnTaskComplete(task: task)
    }
    
    func DeleteTask(task: Task) {
        var index = -1
        
        let isCompleted = task.isCompleted
        
        if !isCompleted {
            if App.mainTaskList.upcomingTasks.contains(task) {
                index = App.mainTaskList.upcomingTasks.firstIndex(of: task) ?? index
                if index == -1 { return }
                App.mainTaskList.upcomingTasks.remove(at: index)
            } else {
                for taskList in App.userTaskLists {
                    if taskList.id == task.taskListID {
                        index = taskList.upcomingTasks.firstIndex(of: task) ?? index
                        if index == -1 { return }
                        taskList.upcomingTasks.remove(at: index)
                        break
                    }
                }
            }
        } else {
            if App.mainTaskList.completedTasks.contains(task) {
                index = App.mainTaskList.completedTasks.firstIndex(of: task) ?? index
                if index == -1 { return }
                App.mainTaskList.completedTasks.remove(at: index)
            } else {
                for taskList in App.userTaskLists {
                    if taskList.id == task.taskListID {
                        index = taskList.completedTasks.firstIndex(of: task) ?? index
                        if index == -1 { return }
                        taskList.completedTasks.remove(at: index)
                        break
                    }
                }
            }
        }
        
        if index == -1 { return }
        
        let indexPath = IndexPath(row: isCompleted ? taskListView.allCompletedTasks.firstIndex(of: task)! : taskListView.allUpcomingTasks.firstIndex(of: task)!, section: isCompleted ? 1 : 0)
        if !isCompleted { taskListView.allUpcomingTasks.remove(at: indexPath.row) }
        else { taskListView.allCompletedTasks.remove(at: indexPath.row) }
        
        taskListView.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.right)
        if taskListView.allUpcomingTasks.count > 0 && indexPath.row == 0 {
            taskListView.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: false)
        }
        
        if task.name != "" {
            lastCompletedTask = nil
            lastDeletedTask = task
            taskListView.ShowUndoButton()
        }
        
        taskListView.currentContextMenuPreview = UIView()
        
        DispatchQueue.main.async { self.sideMenuView.UpdateUpcomingTasksCounts() }
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    func UndoCompletingTask(task: Task) {
        if !task.isCompleted { return }
        
        task.isCompleted = false
        
        let arrayIndex = taskListView.GetSortedArrayIndex(task: task)
        
        var index = -1
        
        if App.mainTaskList.completedTasks.contains(task) {
            index = App.mainTaskList.completedTasks.firstIndex(of: task)!
            
            App.mainTaskList.completedTasks.remove(at: index)
            App.mainTaskList.upcomingTasks.insert(task, at: arrayIndex)
        } else {
            for taskList in App.userTaskLists {
                if taskList.id == task.taskListID {
                    index = taskList.completedTasks.firstIndex(of: task)!
                    
                    taskList.completedTasks.remove(at: index)
                    taskList.upcomingTasks.insert(task, at: arrayIndex)
                    break
                }
            }
        }
        if index == -1 { return }
        
        let tableIndex = taskListView.allCompletedTasks.firstIndex(of: task)!
        taskListView.allCompletedTasks.remove(at: tableIndex)
        taskListView.allUpcomingTasks.insert(task, at: taskListView.GetSortedIndexPath(task: task).row)
        
        let undoIndexPath = taskListView.allUpcomingTasks.firstIndex(of: task)!
        
        if undoIndexPath == 0 { taskListView.tableView.setContentOffset(CGPoint(x: 0, y: taskListView.originalTableContentOffsetY), animated: true) } //Jagged animation fix
        
        taskListView.tableView.performBatchUpdates({
            taskListView.tableView.insertRows(at: [IndexPath(row: undoIndexPath, section: 0)], with: UITableView.RowAnimation.right)
            taskListView.tableView.deleteRows(at: [IndexPath(row: tableIndex, section: 1)], with: UITableView.RowAnimation.right)
        })
        if index == 0 { taskListView.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: false) }
        
        taskListView.HideUndoButton()
        
        DispatchQueue.main.async { self.sideMenuView.UpdateUpcomingTasksCounts() }
        
        
        StatsManager.stats.totalCompletedTasks -= 1
        StatsManager.stats.totalCompletedHighPriorityTasks -= task.priority == .High ? 1 : 0
        if StatsManager.stats.totalCompletedTasks < 0 { StatsManager.stats.totalCompletedTasks = 0}
        if StatsManager.stats.totalCompletedHighPriorityTasks < 0 { StatsManager.stats.totalCompletedHighPriorityTasks = 0}
    }
    
    func UndoDeletingTask(task: Task) {
        let arrayIndex = taskListView.GetSortedArrayIndex(task: task)
        
        if task.taskListID == App.mainTaskList.id {
            if !task.isCompleted {
                App.mainTaskList.upcomingTasks.insert(task, at: arrayIndex)
            } else {
                App.mainTaskList.completedTasks.insert(task, at: arrayIndex)
            }
        } else {
            for taskList in App.userTaskLists {
                if taskList.id == task.taskListID {
                    if !task.isCompleted {
                        taskList.upcomingTasks.insert(task, at: arrayIndex)
                    } else {
                        taskList.completedTasks.insert(task, at: arrayIndex)
                    }
                    break
                }
            }
        }
        
        
        taskListView.taskLists = App.selectedTaskListIndex == 0 ? allTaskLists : App.selectedTaskListIndex == 1 ? [App.mainTaskList] : [App.userTaskLists[App.selectedTaskListIndex-2]]
        taskListView.ReloadTaskData(sortOverviewList: App.selectedTaskListIndex == 0)
        
        let undoIndexPath = !task.isCompleted ? IndexPath(row: taskListView.allUpcomingTasks.firstIndex(of: task)!, section: 0)  : IndexPath(row: taskListView.allCompletedTasks.firstIndex(of: task)!, section: 1)
        if undoIndexPath.row == 0 {
            taskListView.tableView.setContentOffset(CGPoint(x: 0, y: taskListView.originalTableContentOffsetY), animated: true)
        } //Jagged animation fix
        
        taskListView.tableView.insertRows(at: [undoIndexPath], with: UITableView.RowAnimation.right)
        
        if undoIndexPath == IndexPath(row: 0, section: 0) { taskListView.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: false) }
        
        taskListView.HideUndoButton()
        
        DispatchQueue.main.async { self.sideMenuView.UpdateUpcomingTasksCounts() }
    }
    
    func UndoAction () {
        if lastCompletedTask != nil {
            StatsManager.DeductPointsForTask(task: lastCompletedTask!)
            UndoCompletingTask(task: lastCompletedTask!)
        } else if lastDeletedTask != nil {
            UndoDeletingTask(task: lastDeletedTask!)
        }
    }
    
    
//MARK: Sidemenu Actions

    func SelectTaskList(index: Int, closeMenu: Bool = true){
        App.selectedTaskListIndex = index
        sideMenuView.overviewMenuItem.ReloadVisuals()
        sideMenuView.tableView.reloadData()
        
        taskListView.tableView.setContentOffset(CGPoint(x: 0, y: taskListView.originalTableContentOffsetY), animated: false)
        taskListView.taskLists = index == 0 ? allTaskLists : index == 1 ? [App.mainTaskList] : [App.userTaskLists[index-2]]
        taskListView.ReloadView()
        
        if closeMenu { CloseSideMenu() }
    }
    
    func ToggleSideMenu () {
        if isSideMenuOpen { CloseSideMenu() }
        else { OpenSideMenu() }
    }
    
    func OpenSideMenu () {
        StopEditingAllTasks()
        UIView.animate(withDuration: 0.23, delay: 0, options: .curveEaseOut) { [self] in
            taskListView.frame.origin.x = sideMenuWidth
        }
    }
    
    func CloseSideMenu () {
        UIView.animate(withDuration: 0.23, delay: 0, options: .curveEaseOut, animations: { [self] in
            taskListView.frame.origin.x = 0
        })
    }
    
    var originX = 0.0
    var prevIsOpen = false
    func DragSideMenu (sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            StopEditingAllTasks()
            originX = taskListView.frame.origin.x
            prevIsOpen = isSideMenuOpen
        } else if sender.state == .changed {
            taskListView.frame.origin.x = max(0, min(originX + sender.translation(in: self.view).x, sideMenuWidth))
        } else if sender.state == .ended {
            if !prevIsOpen {
                if taskListView.frame.origin.x >= sideMenuWidth*0.2 { OpenSideMenu() }
                else { CloseSideMenu() }
            } else {
                if taskListView.frame.origin.x <= sideMenuWidth*0.8 { CloseSideMenu() }
                else { OpenSideMenu() }
            }
        }
    }
    
    func getTaskList (id: UUID) -> TaskList {
        if App.mainTaskList.id == id { return App.mainTaskList }
        
        for i in 0..<App.userTaskLists.count {
            if App.userTaskLists[i].id == id { return App.userTaskLists[i] }
        }
        return TaskList(name: "Error")
    }
    
    
//MARK: Task list actions
    
    func OpenAddTaskListView () {
        let listPerk = StatsManager.getLevelPerk(type: .UnlimitedLists)
        if App.userTaskLists.count >= 9 && !listPerk.isUnlocked {
            let coloredSubstring = "Level \(listPerk.unlockLevel)"
            let vc = LockedPerkPopupViewController(warningText: "Reach \(coloredSubstring) to create more than 10 lists", coloredSubstring: coloredSubstring, parentVC: self)
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true)
            return
        }
        
        let addListViewFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height*0.5)
        
        self.view.addSubview(AddListView(frame: addListViewFrame))
    }
    func OpenEditTaskListView (taskList: TaskList) {
        let addListViewFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height*0.5)
        
        self.view.addSubview(AddListView(frame: addListViewFrame, taskList: taskList))
    }
    
    func CreateNewTaskList (taskList: TaskList) {
        App.userTaskLists.append(taskList)
        
        sideMenuView.tableView.beginUpdates()
        sideMenuView.tableView.insertRows(at: [IndexPath(row: App.userTaskLists.count, section: 0)], with: .bottom)
        sideMenuView.tableView.endUpdates()
        
        SelectTaskList(index: App.userTaskLists.count+1)
    }
    
    func EditTaskList (oldTaskList: TaskList, updatedTaskList: TaskList) {
        oldTaskList.primaryColor = updatedTaskList.primaryColor
        oldTaskList.name = updatedTaskList.name
        oldTaskList.systemIcon = updatedTaskList.systemIcon
        
        let index = updatedTaskList.id == App.mainTaskList.id ? 0 : App.userTaskLists.firstIndex(of: oldTaskList)! + 1
        sideMenuView.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        
        if App.selectedTaskListIndex == 0 && index == 0 {
            SelectTaskList(index: index, closeMenu: false)
        }
        if App.selectedTaskListIndex == index + 1 {
            SelectTaskList(index: index+1, closeMenu: false)
        }
    }
    
    func DeleteTaskList (taskList: TaskList) {
        let index = App.userTaskLists.firstIndex(of: taskList)!
        App.userTaskLists.remove(at: index)
        
        sideMenuView.tableView.beginUpdates()
        sideMenuView.tableView.deleteRows(at: [IndexPath(row: index+1, section: 0)], with: .fade)
        sideMenuView.tableView.endUpdates()
        
        if index == App.selectedTaskListIndex-2 {
            SelectTaskList(index: index > 0 ? index+1 : 1, closeMenu: false)
        }
        
        if App.settingsConfig.defaultListID == taskList.id {
            App.settingsConfig.defaultListID = App.mainTaskList.id
            App.instance.SaveSettings()
        }
        
        if App.selectedTaskListIndex == 0 {
            SelectTaskList(index: 0, closeMenu: false)
        }
    }
    
    
//MARK: UI Functions
    
    func ZoomOutContainterView () {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { [self] in
            containerView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            containerView.frame.origin.y = UIScreen.main.bounds.height * 0.05
            containerView.layer.cornerRadius = 15
            containerView.clipsToBounds = true
        })
    }
    func ZoomInContainterView () {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { [self] in
            containerView.transform = CGAffineTransform(scaleX: 1, y: 1)
            containerView.frame.origin.y = 0
            containerView.layer.cornerRadius = 0
        }, completion: { [self] _ in
            containerView.clipsToBounds = false
        })
    }
    
//MARK: Saving and Loading
    
    let settingsKey = "FINALE_DEV_APP_settingsConfig"
    let overviewSortingPrefKey = "FINALE_DEV_APP_overviewSortingPreference"
    let mainTaskListKey = "FINALE_DEV_APP_mainTaskList"
    let userTaskListKey = "FINALE_DEV_APP_userTaskLists"
    let statsKey = "FINALE_DEV_APP_stats"
    let lastICloudSyncKey = "FINALE_DEV_APP_lastICloudSyncDate"
    let lastLocalSaveKey = "FINALE_DEV_APP_lastICloudSaveDate"
    let deviceNameKey = "FINALE_DEV_APP_deviceName"
    
    func LoadData () {
        if let data = UserDefaults.standard.data(forKey: settingsKey) {
            if let decoded = try? JSONDecoder().decode(SettingsConfig.self, from: data) {
                App.settingsConfig = decoded
                App.settingsConfig.isNotificationsAllowed = App.settingsConfig.isNotificationsAllowed
            }
        } else {
            if let data = NSUbiquitousKeyValueStore().data(forKey: settingsKey) {
                if let decoded = try? JSONDecoder().decode(SettingsConfig.self, from: data) {
                    App.settingsConfig = decoded
                    App.settingsConfig.isNotificationsAllowed = App.settingsConfig.isNotificationsAllowed
                }
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
        
        RemoveExcessCompletedTasks()
        ThemeManager.currentTheme = App.settingsConfig.GetCurrentTheme()
        
        if !App.settingsConfig.completedInitialSetup {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.present(WelcomeScreenNavController(), animated: true)
            }
        }
    }
    
    func LoadLocalData () {
        overviewSortingPreference = SortingPreference(rawValue: UserDefaults.standard.integer(forKey: overviewSortingPrefKey))
        if overviewSortingPreference == .Unsorted { overviewSortingPreference = .ByList }

        if let data = UserDefaults.standard.data(forKey: mainTaskListKey) {
            if let decoded = try? JSONDecoder().decode(TaskList.self, from: data) {
                App.mainTaskList = decoded
            }
        }
        if let data = UserDefaults.standard.data(forKey: userTaskListKey) {
            if let decoded = try? JSONDecoder().decode([TaskList].self, from: data) {
                App.userTaskLists = decoded
            }
        }
        if let data = UserDefaults.standard.data(forKey: statsKey) {
            if let decoded = try? JSONDecoder().decode(StatsConfig.self, from: data) {
                StatsManager.stats = decoded
            }
        }
    }
    
    func LoadICloudData (iCloudKey: NSUbiquitousKeyValueStore) {
        if let data = iCloudKey.data(forKey: settingsKey) {
            if let decoded = try? JSONDecoder().decode(SettingsConfig.self, from: data) {
                App.settingsConfig = decoded
                App.settingsConfig.isNotificationsAllowed = App.settingsConfig.isNotificationsAllowed
            }
        }
        
        if let osp = iCloudKey.object(forKey: overviewSortingPrefKey) as? Int {
            overviewSortingPreference = SortingPreference(rawValue: osp)
            if overviewSortingPreference == .Unsorted { overviewSortingPreference = .ByList }
        } else {
            overviewSortingPreference = .ByList
        }

        if let data = iCloudKey.data(forKey: mainTaskListKey) {
            if let decoded = try? JSONDecoder().decode(TaskList.self, from: data) {
                App.mainTaskList = decoded
            }
        }
        if let data = iCloudKey.data(forKey: userTaskListKey) {
            if let decoded = try? JSONDecoder().decode([TaskList].self, from: data) {
                App.userTaskLists = decoded
            }
        }
        if let data = iCloudKey.data(forKey: statsKey) {
            if let decoded = try? JSONDecoder().decode(StatsConfig.self, from: data) {
                StatsManager.stats = decoded
            }
        }
    }
    
    func SaveData () {
        let keyStore = App.settingsConfig.isICloudSyncOn ? NSUbiquitousKeyValueStore() : nil
        
        SaveValue(value: overviewSortingPreference.rawValue, forKey: overviewSortingPrefKey, iCloudKey: keyStore)
        
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
    
//MARK: Level functions
    
    func ReachLevel(level: Int) {
        ShowLevelUpNotification(level: level)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            StatsManager.CheckUnlockedBadge(groupID: 6)
        }
    }
    
    func ShowLevelUpNotification (level: Int){
        if notificationView == nil {
            notificationView = NotificationView(level: level)
            self.view.addSubview(notificationView!)
        }
    }
    
    func ShowBadgeNotification (badgeGroup: AchievementBadgeGroup) {
        if notificationView == nil {
            notificationView = NotificationView(badgeGroup: badgeGroup)
            self.view.addSubview(notificationView!)
        }
    }
    
    
//MARK: Backend functions
    
    @objc func AppMovedToBackground() {
        SaveData()
        NotificationHelper.UpdateAppBadge()
        NotificationHelper.ScheduleAllTaskNotifications()
    }
    
    @objc func AppBecameActive() {
        taskListView.UpdateAllDateLabels()
        NotificationHelper.RemoveDeliveredNotifications()
        NotificationHelper.CancelAllScheduledNotifications()
        StatsManager.DetectNewDay()
        DetectIfAnyTaskIsOverdue()
    }
    
    func DetectIfAnyTaskIsOverdue () {
        for task in App.mainTaskList.upcomingTasks {
            if task.isOverdue {
                StatsManager.stats.consecutiveDaysWithoutOverdueTasks = 0
                return
            }
        }
        for taskList in App.userTaskLists {
            for task in taskList.upcomingTasks {
                if task.isOverdue {
                    StatsManager.stats.consecutiveDaysWithoutOverdueTasks = 0
                    return
                }
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        ThemeManager.currentTheme = App.settingsConfig.GetCurrentTheme()
        SetSubviewColors(of: self.view)
    }
    
    func SetSubviewColors(of view: UIView) {
        if let dynamicThemeView = view as? UIDynamicTheme  {
            dynamicThemeView.ReloadThemeColors()
        }
        
        for subview in view.subviews {
            SetSubviewColors(of: subview)
        }
    }
    
    func StopEditingAllTasks () {
        for cell in taskListView.tableView.visibleCells as! [TaskSliderTableCell] {
            cell.slider.StopEditing()
            if cell.slider.task.name == "" { DeleteTask(task: cell.slider.task) }
            taskListView.currentSliderEditing = nil
        }
    }
    
    func RemoveExcessCompletedTasks () {
        while App.mainTaskList.completedTasks.count > App.settingsConfig.maxNumberOfCompletedTasks {
            App.mainTaskList.completedTasks.removeLast()
        }
        for taskList in App.userTaskLists {
            while taskList.completedTasks.count > App.settingsConfig.maxNumberOfCompletedTasks {
                taskList.completedTasks.removeLast()
            }
        }
    }
    
    var defaultList: TaskList {
        for taskList in App.userTaskLists {
            if App.settingsConfig.defaultListID == taskList.id { return taskList }
        }
        
        return App.mainTaskList
    }
    
}



class NotificationView: UIView {
    
    let padding = 16.0
    let height = 60.0
    
    var timer: Timer?
    
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let iconView = UIImageView()
    
    let width: CGFloat
    
    init (badgeGroup: AchievementBadgeGroup? = nil, level: Int? = nil) {
        
        width = UIScreen.main.bounds.width - padding*2
        
        super.init(frame: CGRect(x: padding, y: -height-padding, width: width, height: height))
        
        self.layer.cornerRadius = 12
        
        let blurEffect = UIVisualEffectView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        blurEffect.effect = UIBlurEffect(style: .systemUltraThinMaterial)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        blurEffect.layer.mask = shapeLayer
        self.addSubview(blurEffect)
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 15
        self.layer.shadowOpacity = 0.3
        
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.isUserInteractionEnabled = false
        titleLabel.textAlignment = .center
        
        subtitleLabel.textAlignment = .center
        subtitleLabel.font = .systemFont(ofSize: 14)
        
        iconView.contentMode = .scaleAspectFit
        iconView.layer.shadowRadius = 4
        iconView.layer.shadowOffset = CGSize.zero
        iconView.layer.shadowColor = UIColor.black.cgColor
        iconView.layer.shadowOpacity = ThemeManager.currentTheme.interface == .Light ? 0.3 : 0.7
        
        if level != nil {
            var unlockString: String?
            for perk in StatsManager.allLevelPerks {
                if perk.unlockLevel == level { unlockString = "Unlocked: \(perk.title)"}
            }
            
            titleLabel.text = "Gained Level \(level!.description)!"
            
            if unlockString != nil {
                titleLabel.frame = CGRect(x: padding, y: padding*0.7, width: width-padding*2, height: 20)
                subtitleLabel.frame = CGRect(x: padding, y: height-padding*0.7-16, width: width-padding*2, height: 16)
                subtitleLabel.text = unlockString
                subtitleLabel.adjustsFontSizeToFitWidth = true
            } else {
                titleLabel.frame = CGRect(x: padding, y: 0, width: width-padding*2, height: height)
            }
        } else if badgeGroup != nil {
            let iconSize = height - padding*0.6
            iconView.frame = CGRect(x: 0, y: padding*0.3, width: iconSize, height: iconSize)
            iconView.image = badgeGroup?.getIcon(index: StatsManager.stats.lastUnlockedBadgeIndex(badgeGroupID: badgeGroup!.groupID))
            
            titleLabel.text = badgeGroup?.getName(index: StatsManager.stats.lastUnlockedBadgeIndex(badgeGroupID: badgeGroup!.groupID))
            let titleWidth = titleLabel.text!.size(withAttributes:[.font: titleLabel.font]).width
            titleLabel.frame = CGRect(x:0, y: iconView.frame.origin.y + 0.5*(iconView.frame.height - 20), width: titleWidth, height: 20)
            
            iconView.frame.origin.x = 0.5*(width - iconSize - padding*0.5 - titleWidth)
            titleLabel.frame.origin.x = iconView.frame.maxX + padding*0.5
        }
        
        self.addSubview(titleLabel)
        self.addSubview(subtitleLabel)
        self.addSubview(iconView)
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.frame.origin.y = UIApplication.shared.windows.first!.safeAreaInsets.top + self.padding
        })
        
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(DismissTimer), userInfo: nil, repeats: false)
        
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(PanGesture)))
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Tap)))
    }
    
    var originY: CGFloat = 0
    @objc func PanGesture (sender: UIPanGestureRecognizer) {
        
        if sender.state == .began {
            originY = self.frame.origin.y
        } else if sender.state == .changed {
            self.frame.origin.y = min(originY, originY + sender.translation(in: self).y)
        } else if sender.state == .ended {
            if self.frame.origin.y <= originY*0.7 {
                Dismiss()
            } else {
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                    self.frame.origin.y = UIApplication.shared.windows.first!.safeAreaInsets.top + self.padding
                })
            }
        }
        
    }
    
    func Dismiss () {
        timer?.invalidate()
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.frame.origin.y = -self.height-self.padding
        }, completion: { _ in
            self.removeFromSuperview()
            App.instance.notificationView = nil
        })
    }
    
    
    @objc func Tap () {
        Dismiss()
        App.instance.sideMenuView.OpenUserOverview()
    }
    
    @objc func DismissTimer() {
        Dismiss()
    }
    
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
