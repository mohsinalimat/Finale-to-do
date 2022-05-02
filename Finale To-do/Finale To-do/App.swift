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
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
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
        
        task.CancelAllNotifications()
        
        DispatchQueue.main.async { self.sideMenuView.UpdateUpcomingTasksCounts() }
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
        task.CancelAllNotifications()
        
        taskListView.currentContextMenuPreview = UIView()
        
        DispatchQueue.main.async { self.sideMenuView.UpdateUpcomingTasksCounts() }
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    func UndoCompletingTask(task: Task) {
        if !task.isCompleted { return }
        
        let arrayIndex = taskListView.GetSortedArrayIndex(task: task)
        
        var index = -1
        task.isCompleted = false
        
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
        
        task.ScheduleAllNotifications()
        
        DispatchQueue.main.async { self.sideMenuView.UpdateUpcomingTasksCounts() }
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
        
        task.ScheduleAllNotifications()
        
        DispatchQueue.main.async { self.sideMenuView.UpdateUpcomingTasksCounts() }
    }
    
    func UndoAction () {
        if lastCompletedTask != nil {
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
        
        if App.settingsConfig.defaultFolderID == taskList.id {
            App.settingsConfig.defaultFolderID = App.mainTaskList.id
            DispatchQueue.main.async {
                App.instance.SaveSettings()
            }
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
    
//MARK: Backend functions
    
    func LoadData () {
        overviewSortingPreference = SortingPreference(rawValue: UserDefaults.standard.integer(forKey: "FINALE_DEV_APP_overviewSortingPreference"))
        if overviewSortingPreference == .Unsorted { overviewSortingPreference = .ByList }

        if let data = UserDefaults.standard.data(forKey: "FINALE_DEV_APP_mainTaskList") {
            if let decoded = try? JSONDecoder().decode(TaskList.self, from: data) {
                App.mainTaskList = decoded
            }
        }
        if let data = UserDefaults.standard.data(forKey: "FINALE_DEV_APP_userTaskLists") {
            if let decoded = try? JSONDecoder().decode([TaskList].self, from: data) {
                App.userTaskLists = decoded
            }
        }

        if let data = UserDefaults.standard.data(forKey: "FINALE_DEV_APP_settingsConfig") {
            if let decoded = try? JSONDecoder().decode(SettingsConfig.self, from: data) {
                App.settingsConfig = decoded
                App.settingsConfig.isNotificationsAllowed = App.settingsConfig.isNotificationsAllowed
            }
        }
        RemoveExcessCompletedTasks()
        ThemeManager.currentTheme = App.settingsConfig.GetCurrentTheme()
    }
    
    func SaveData () {
        UserDefaults.standard.set(overviewSortingPreference.rawValue, forKey: "FINALE_DEV_APP_overviewSortingPreference")
        
        if let encoded = try? JSONEncoder().encode(App.mainTaskList) {
            UserDefaults.standard.set(encoded, forKey: "FINALE_DEV_APP_mainTaskList")
        }
        if let encoded = try? JSONEncoder().encode(App.userTaskLists) {
            UserDefaults.standard.set(encoded, forKey: "FINALE_DEV_APP_userTaskLists")
        }
    }
    
    func SaveSettings () {
        if let encoded = try? JSONEncoder().encode(App.settingsConfig) {
            UserDefaults.standard.set(encoded, forKey: "FINALE_DEV_APP_settingsConfig")
        }
    }
    
    @objc func AppMovedToBackground() {
        SaveData()
        NotificationHelper.UpdateAppBadge()
    }
    
    @objc func AppBecameActive() {
        taskListView.UpdateAllDateLabels()
        NotificationHelper.RemoveDeliveredNotifications()
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
            if App.settingsConfig.defaultFolderID == taskList.id { return taskList }
        }
        
        return App.mainTaskList
    }
    
}

