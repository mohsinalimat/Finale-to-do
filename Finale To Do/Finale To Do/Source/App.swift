//
//  ViewController.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/14/22.
//

import UIKit
import WidgetKit

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
        
        SaveManager.instance.LoadData()
        App.instance.overrideUserInterfaceStyle = App.settingsConfig.interface == .System ? .unspecified : App.settingsConfig.interface == .Light ? .light : .dark

        let sideMenuFrame = CGRect(x: 0, y: 0, width: sideMenuWidth, height: UIScreen.main.bounds.height)
        sideMenuView = SideMenuView(frame: sideMenuFrame, app: self)
        containerView.addSubview(sideMenuView)
        
        InitTaskListView()
        
        self.view.addSubview(containerView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AppBecameActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        NotificationHelper.CheckNotificationPermissionStatus()
    }
    
    func InitTaskListView () {
        let fullScreenFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        if App.settingsConfig.smartLists.count > 0 {
            if App.settingsConfig.smartLists.first!.viewClass == TaskListView.self {
                taskListView = TaskListView(frame: fullScreenFrame, taskLists: allTaskLists, app: self)
            } else if App.settingsConfig.smartLists.first!.viewClass == UpcomingTasksView.self {
                taskListView = UpcomingTasksView(frame: fullScreenFrame, taskLists: allTaskLists, app: self)
            }
        } else {
            taskListView = TaskListView(frame: fullScreenFrame, taskLists: allTaskLists, app: self)
        }
        containerView.addSubview(taskListView)
    }
    
//MARK: Task Actions
    
    func CreateNewTask(tasklist: TaskList? = nil, task: Task? = nil) {
        DispatchQueue.main.async { [self] in
            taskListView.tableView.setContentOffset(CGPoint(x: 0, y: taskListView.originalTableContentOffsetY), animated: true)
        }
        
        StopEditingAllTasks()
        
        let newTask: Task
        if App.selectedTaskListIndex < App.settingsConfig.smartLists.count {
            if tasklist == nil {
                newTask = task ?? Task(taskListID: defaultList.id)
                defaultList.upcomingTasks.insert(newTask, at: 0)
            } else {
                newTask = task ?? Task(taskListID: tasklist!.id)
                tasklist!.upcomingTasks.insert(newTask, at: 0)
            }
        } else if App.selectedTaskListIndex == App.settingsConfig.smartLists.count { //Main task list
            newTask = task ?? Task(taskListID: App.mainTaskList.id)
            App.mainTaskList.upcomingTasks.insert(newTask, at: 0)
        } else {
            newTask = task ?? Task(taskListID: App.userTaskLists[App.selectedTaskListIndex-App.settingsConfig.smartLists.count-1].id)
            App.userTaskLists[App.selectedTaskListIndex-App.settingsConfig.smartLists.count-1].upcomingTasks.insert(newTask, at: 0)
        }
        
        taskListView.allUpcomingTasks.insert(newTask, at: 0)

        CreateNewTaskTableAnimation()
        
        if task != nil {
            taskListView.MoveTaskToRightSortedIndexPath(task: task!)
        }
        
        DispatchQueue.main.async { self.sideMenuView.UpdateUpcomingTasksCounts() }
        
        AnalyticsHelper.LogTaskCreated()
    }
    
    func CreateNewTaskTableAnimation () {
        if taskListView is UpcomingTasksView {
            let view = taskListView as! UpcomingTasksView
            view.sections.insert(UpcomingTasksSection(id: -1, title: "New task", tasks: [view.allUpcomingTasks.first!]), at: 0)
            view.tableView.insertSections(IndexSet(integer: 0), with: .fade)
        } else {
            taskListView.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: UITableView.RowAnimation.automatic)
        }
        
        taskListView.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: false)
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
        
        CompleteTaskTableAnimation(tableIndex: tableIndex, index: index, task: task)
        
        lastCompletedTask = task
        lastDeletedTask = nil
        taskListView.ShowUndoButton()
        
        if task.repeating.count > 0 { AddRepeatingTask(task: task) }
        
        DispatchQueue.main.async { self.sideMenuView.UpdateUpcomingTasksCounts() }
        
        StatsManager.OnTaskComplete(task: task)
        
        AnalyticsHelper.LogTaskCompleted()
    }
    
    func CompleteTaskTableAnimation (tableIndex: Int, index: Int, task: Task) {
        if taskListView is UpcomingTasksView {
            let view = taskListView as! UpcomingTasksView
            var indexPath = IndexPath(row: 0, section: 0)
            for i in 0..<view.sections.count {
                if view.sections[i].tasks.contains(task) {
                    indexPath.section = i
                    indexPath.row = view.sections[i].tasks.firstIndex(of: task)!
                    view.sections[i].tasks.remove(at: indexPath.row)
                    
                    
                    if view.sections[i].tasks.count > 0 { taskListView.tableView.deleteRows(at: [indexPath], with: .right) }
                    else {
                        view.sections.remove(at: indexPath.section)
                        taskListView.tableView.deleteSections(IndexSet(integer: indexPath.section), with: .right)
                    }
                    break
                }
            }
        } else {
            taskListView.tableView.performBatchUpdates({
                taskListView.tableView.deleteRows(at: [IndexPath(row: tableIndex, section: 0)], with: UITableView.RowAnimation.right)
                taskListView.tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: UITableView.RowAnimation.automatic)
            })
        }
        
        if index == 0 && taskListView.allUpcomingTasks.count > 0 { taskListView.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: false) }
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
        
        DeleteTaskTableAnimation(taskListViewIndexPath: indexPath, task: task)
        
        if task.name != "" {
            lastCompletedTask = nil
            lastDeletedTask = task
            taskListView.ShowUndoButton()
        }
        
        taskListView.currentContextMenuPreview = UIView()
        
        DispatchQueue.main.async { self.sideMenuView.UpdateUpcomingTasksCounts() }
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    func DeleteTaskTableAnimation(taskListViewIndexPath: IndexPath, task: Task) {
        if taskListView is UpcomingTasksView {
            let view = taskListView as! UpcomingTasksView
            var indexPath = IndexPath(row: 0, section: 0)
            for i in 0..<view.sections.count {
                if view.sections[i].tasks.contains(task) {
                    indexPath.section = i
                    indexPath.row = view.sections[i].tasks.firstIndex(of: task)!
                    view.sections[i].tasks.remove(at: indexPath.row)
                    
                    if view.sections[i].tasks.count > 0 { taskListView.tableView.deleteRows(at: [indexPath], with: .right) }
                    else {
                        view.sections.remove(at: indexPath.section)
                        taskListView.tableView.deleteSections(IndexSet(integer: indexPath.section), with: .right)
                    }
                    
                    if taskListView.allUpcomingTasks.count > 0 && indexPath == IndexPath(row: 0, section: 0) {
                        taskListView.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: false)
                    }
                    break
                }
            }
        } else {
            taskListView.tableView.deleteRows(at: [taskListViewIndexPath], with: UITableView.RowAnimation.right)
            if taskListView.allUpcomingTasks.count > 0 && taskListViewIndexPath.row == 0 {
                taskListView.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: false)
            }
        }
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
        
        UndoCompletingTaskTableAnimation(undoIndexPath: undoIndexPath, tableIndex: tableIndex, index: index, task: task)
        
        taskListView.HideUndoButton()
        
        DispatchQueue.main.async { self.sideMenuView.UpdateUpcomingTasksCounts() }
        
        
        StatsManager.stats.totalCompletedTasks -= 1
        StatsManager.stats.totalCompletedHighPriorityTasks -= task.priority == .High ? 1 : 0
        if StatsManager.stats.totalCompletedTasks < 0 { StatsManager.stats.totalCompletedTasks = 0}
        if StatsManager.stats.totalCompletedHighPriorityTasks < 0 { StatsManager.stats.totalCompletedHighPriorityTasks = 0}
    }
    
    func UndoCompletingTaskTableAnimation (undoIndexPath: Int, tableIndex: Int, index: Int, task: Task) {
        if taskListView is UpcomingTasksView {
            let view = taskListView as! UpcomingTasksView
            view.ReloadTaskData()
            
            var indexPath = IndexPath(row: 0, section: 0)
            for i in 0..<view.sections.count {
                if view.sections[i].tasks.contains(task) {
                    indexPath.section = i
                    indexPath.row = view.sections[i].tasks.firstIndex(of: task)!
                    
                    if view.sections[i].tasks.count > 1 {
                        taskListView.tableView.insertRows(at: [indexPath], with: .right)
                    } else {
                        taskListView.tableView.insertSections(IndexSet(integer: indexPath.section), with: .right)
                    }
                    
                    if indexPath == IndexPath(row: 0, section: 0) {
                        taskListView.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: false)
                    }
                    break
                }
            }
        } else {
            taskListView.tableView.performBatchUpdates({
                taskListView.tableView.insertRows(at: [IndexPath(row: undoIndexPath, section: 0)], with: UITableView.RowAnimation.right)
                taskListView.tableView.deleteRows(at: [IndexPath(row: tableIndex, section: 1)], with: UITableView.RowAnimation.right)
            })
            if index == 0 { taskListView.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: false) }
        }
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
        
        taskListView.taskLists = App.selectedTaskListIndex < App.settingsConfig.smartLists.count ? allTaskLists : App.selectedTaskListIndex == App.settingsConfig.smartLists.count ? [App.mainTaskList] : [App.userTaskLists[App.selectedTaskListIndex-App.settingsConfig.smartLists.count-1]]
        taskListView.ReloadTaskData(sortOverviewList: App.selectedTaskListIndex < App.settingsConfig.smartLists.count)
        
        let undoIndexPath = !task.isCompleted ? IndexPath(row: taskListView.allUpcomingTasks.firstIndex(of: task)!, section: 0)  : IndexPath(row: taskListView.allCompletedTasks.firstIndex(of: task)!, section: 1)
        if undoIndexPath.row == 0 {
            taskListView.tableView.setContentOffset(CGPoint(x: 0, y: taskListView.originalTableContentOffsetY), animated: true)
        } //Jagged animation fix
        
        UndoDeletingTaskTableAnimation(undoIndexPath: undoIndexPath, task: task)
        
        taskListView.HideUndoButton()
        
        DispatchQueue.main.async { self.sideMenuView.UpdateUpcomingTasksCounts() }
    }
    
    func UndoDeletingTaskTableAnimation (undoIndexPath: IndexPath, task: Task) {
        if taskListView is UpcomingTasksView {
            let view = taskListView as! UpcomingTasksView
            
            var indexPath = IndexPath(row: 0, section: 0)
            for i in 0..<view.sections.count {
                if view.sections[i].tasks.contains(task) {
                    indexPath.section = i
                    indexPath.row = view.sections[i].tasks.firstIndex(of: task)!
                    
                    if view.sections[i].tasks.count > 1 {
                        taskListView.tableView.insertRows(at: [indexPath], with: .right)
                    } else {
                        taskListView.tableView.insertSections(IndexSet(integer: indexPath.section), with: .right)
                    }
                    
                    if indexPath == IndexPath(row: 0, section: 0) {
                        taskListView.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: false)
                    }
                    break
                }
            }
        } else {
            taskListView.tableView.insertRows(at: [undoIndexPath], with: UITableView.RowAnimation.right)
            if undoIndexPath == IndexPath(row: 0, section: 0) { taskListView.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: false) }
        }
        
    }
    
    func UndoAction () {
        if lastCompletedTask != nil {
            StatsManager.DeductPointsForTask(task: lastCompletedTask!)
            UndoCompletingTask(task: lastCompletedTask!)
        } else if lastDeletedTask != nil {
            UndoDeletingTask(task: lastDeletedTask!)
        }
    }
    
    func AddRepeatingTask (task: Task) {
        if task.repeating.count == 0 || !task.isDateAssigned { return }
        
        let newDate: Date
        if task.repeating.count == 1 && (task.repeating.first == .Daily || task.repeating.first == .Weekly || task.repeating.first == .Monthly) {
            if task.repeating.first == .Daily { newDate = Calendar.current.date(byAdding: .day, value: 1, to: task.dateAssigned)! }
            else if task.repeating.first == .Weekly { newDate = Calendar.current.date(byAdding: .day, value: 7, to: task.dateAssigned)! }
            else { newDate = Calendar.current.date(byAdding: .month, value: 1, to: task.dateAssigned)! } //Monthly
        } else {
            var allDates = [Date]()
            for repeatType in task.repeating {
                if repeatType == .Monday { allDates.append(task.dateAssigned.next(.monday)) }
                else if repeatType == .Tuesday { allDates.append(task.dateAssigned.next(.tuesday)) }
                else if repeatType == .Wednesday { allDates.append(task.dateAssigned.next(.wednesday)) }
                else if repeatType == .Thursday { allDates.append(task.dateAssigned.next(.thursday)) }
                else if repeatType == .Friday { allDates.append(task.dateAssigned.next(.friday)) }
                else if repeatType == .Saturday { allDates.append(task.dateAssigned.next(.saturday)) }
                else { allDates.append(task.dateAssigned.next(.sunday)) } //Sunday
            }
            allDates = allDates.sorted { $0 < $1 }
            newDate = allDates.first!
        }
        
        let newTask = Task(name: task.name, priority: task.priority, notes: task.notes, repeating: task.repeating, isComleted: false, isDateAssigned: task.isDateAssigned, isDueTimeAssigned: task.isDueTimeAssigned, dateAssigned: newDate, dateCreated: task.dateCreated, notifications: task.notifications, taskListID: task.taskListID)
        
        CreateNewTask(tasklist: getTaskList(id: newTask.taskListID), task: newTask)
    }
    
    
//MARK: Sidemenu Actions

    func SelectTaskList(index: Int, closeMenu: Bool = true){
        let oldIndex = App.selectedTaskListIndex
        App.selectedTaskListIndex = index
        sideMenuView.UpdateSmartListsVisuals()
        sideMenuView.tableView.reloadData()
        
        if index < App.settingsConfig.smartLists.count { //Selected smart list
            let currentFrame = taskListView.frame
            taskListView.removeFromSuperview()
            if App.settingsConfig.smartLists[index].viewClass == TaskListView.self {
                taskListView = TaskListView(frame: currentFrame, taskLists: allTaskLists, app: self)
            } else if App.settingsConfig.smartLists[index].viewClass == UpcomingTasksView.self {
                taskListView = UpcomingTasksView(frame: currentFrame, taskLists: allTaskLists, app: self)
            }
            containerView.addSubview(taskListView)
        } else {
            if oldIndex < App.settingsConfig.smartLists.count { //Smart list was selected
                let currentFrame = taskListView.frame
                taskListView.removeFromSuperview()
                taskListView = TaskListView(frame: currentFrame, taskLists: allTaskLists, app: self)
                containerView.addSubview(taskListView)
            }
            taskListView.taskLists = index == App.settingsConfig.smartLists.count ? [App.mainTaskList] : [App.userTaskLists[index-App.settingsConfig.smartLists.count-1]]
            taskListView.ReloadView()
        }
        
        taskListView.tableView.setContentOffset(CGPoint(x: 0, y: taskListView.originalTableContentOffsetY), animated: false)
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
        
        SelectTaskList(index: App.userTaskLists.count+App.settingsConfig.smartLists.count)
        
        AnalyticsHelper.LogTaskListCreated(taskList: taskList)
    }
    
    func EditTaskList (oldTaskList: TaskList, updatedTaskList: TaskList) {
        oldTaskList.primaryColor = updatedTaskList.primaryColor
        oldTaskList.name = updatedTaskList.name
        oldTaskList.systemIcon = updatedTaskList.systemIcon
        
        let index = updatedTaskList.id == App.mainTaskList.id ? 0 : App.userTaskLists.firstIndex(of: oldTaskList)! + 1
        sideMenuView.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        
        if App.selectedTaskListIndex < App.settingsConfig.smartLists.count { //if smart list is selected, update it cause it has tasks from updated lists
            SelectTaskList(index: App.selectedTaskListIndex, closeMenu: false)
        } else if App.selectedTaskListIndex == index + App.settingsConfig.smartLists.count { //If this list is currently selected, update it
            SelectTaskList(index: App.selectedTaskListIndex, closeMenu: false)
        }
        
        AnalyticsHelper.LogTaskListEdited(taskList: updatedTaskList)
    }
    
    func DeleteTaskList (taskList: TaskList) {
        let index = App.userTaskLists.firstIndex(of: taskList)!
        App.userTaskLists.remove(at: index)
        
        sideMenuView.tableView.deleteRows(at: [IndexPath(row: index+1, section: 0)], with: .fade)
        
        if index == App.selectedTaskListIndex-App.settingsConfig.smartLists.count-1 {
            SelectTaskList(index: App.selectedTaskListIndex-1, closeMenu: false)
        } else if App.selectedTaskListIndex > App.settingsConfig.smartLists.count+App.userTaskLists.count{
            SelectTaskList(index: App.selectedTaskListIndex-1, closeMenu: false)
        } else {
            SelectTaskList(index: App.selectedTaskListIndex, closeMenu: false)
        }
        
        if App.settingsConfig.defaultListID == taskList.id {
            App.settingsConfig.defaultListID = App.mainTaskList.id
            SaveManager.instance.SaveSettings()
        }
        
        if App.settingsConfig.widgetLists.contains(taskList.id) {
            App.settingsConfig.widgetLists.remove(at: App.settingsConfig.widgetLists.firstIndex(of: taskList.id)!)
        }
        
        if App.settingsConfig.smartLists.contains(.Upcoming) { sideMenuView.UpdateSmartListTasksCount() }
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
    
//MARK: Level functions
    
    func ReachLevel(level: Int) {
        ShowLevelUpNotification(level: level)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            StatsManager.CheckUnlockedBadge(groupID: 6)
        }
    }
    
    func ShowLevelUpNotification (level: Int){
        if notificationView == nil {
            let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            notificationView = NotificationView(level: level)
            keyWindow?.addSubview(notificationView!)
        }
    }
    
    func ShowBadgeNotification (badgeGroup: AchievementBadgeGroup) {
        if notificationView == nil {
            let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            notificationView = NotificationView(badgeGroup: badgeGroup)
            keyWindow?.addSubview(notificationView!)
        }
    }
    
    
//MARK: Backend functions
    
    @objc func AppMovedToBackground() {
        SaveManager.instance.SaveData()
        NotificationHelper.UpdateAppBadge()
        NotificationHelper.ScheduleAllTaskNotifications()
        AnalyticsHelper.LogGeneralStats()
        AnalyticsHelper.RecordUserProperties()
        SyncWidgetData()
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
            cell.slider.StopEditing(putInRightPlace: taskListView is UpcomingTasksView)
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
    
    
//MARK: Widget Funcs
    
    func SyncWidgetData() {
        var allUpcomingTasks = [Task]()
        if App.settingsConfig.widgetLists.count == 0 {
            for list in allTaskLists {
                allUpcomingTasks.append(contentsOf: list.upcomingTasks)
            }
        } else {
            for tasklistID in App.settingsConfig.widgetLists {
                allUpcomingTasks.append(contentsOf: getTaskList(id: tasklistID).upcomingTasks)
            }
        }
        
        allUpcomingTasks = allUpcomingTasks.sorted { taskListView.sortBool(task1: $0, task2: $1, sortingPreference: .ByTimeDue) }
        
        let taskNumber = allUpcomingTasks.count
        
        while allUpcomingTasks.count > WidgetSync.maxNumberOfTasks { allUpcomingTasks.removeLast() }
        
        var upcomingWidgetTasks = [WidgetTask]()
        for task in allUpcomingTasks {
            upcomingWidgetTasks.append(WidgetTask(name: task.name, isCompleted: false, colorHex: getTaskList(id: task.taskListID).primaryColor.hexStringFromColor, isDateAssigned: task.isDateAssigned, isDueTimeAssigned: task.isDueTimeAssigned, dateAssigned: task.dateAssigned, isHighPriority: task.priority == .High))
        }
        
        var allCompletedTasks = [Task]()
        if upcomingWidgetTasks.count < WidgetSync.maxNumberOfTasks {
            if App.settingsConfig.widgetLists.count == 0 {
                for list in allTaskLists {
                    allCompletedTasks.append(contentsOf: list.completedTasks)
                }
            } else {
                for tasklistID in App.settingsConfig.widgetLists {
                    allCompletedTasks.append(contentsOf: getTaskList(id: tasklistID).completedTasks)
                }
            }
            
            allCompletedTasks = allCompletedTasks.sorted { $0.dateCompleted > $1.dateCompleted }
            while allCompletedTasks.count > WidgetSync.maxNumberOfTasks-upcomingWidgetTasks.count { allCompletedTasks.removeLast() }
        }
        
        var completedWidgetTasks = [WidgetTask]()
        for task in allCompletedTasks {
            completedWidgetTasks.append(WidgetTask(name: task.name, isCompleted: task.isCompleted, colorHex: getTaskList(id: task.taskListID).primaryColor.hexStringFromColor, isDateAssigned: task.isDateAssigned, isDueTimeAssigned: task.isDueTimeAssigned, dateAssigned: task.dateAssigned, isHighPriority: task.priority == .High))
        }
        
        if let encoded = try? JSONEncoder().encode(upcomingWidgetTasks) {
            WidgetSync.userDefaults.set(encoded, forKey: WidgetSync.widgetUpcomingTasksSyncKey)
        }
        if let encoded = try? JSONEncoder().encode(completedWidgetTasks) {
            WidgetSync.userDefaults.set(encoded, forKey: WidgetSync.widgetCompletedTasksSyncKey)
        }
        WidgetSync.userDefaults.set(widgetTitle, forKey: WidgetSync.widgetTitleSyncKey)
        WidgetSync.userDefaults.set(taskNumber, forKey: WidgetSync.widgetTasksNumberKey)
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    var widgetTitle: String {
        if App.settingsConfig.userFirstName == "" { return "Tasks" }
        return "Hi, \(App.settingsConfig.userFirstName)"
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
        
        UINotificationFeedbackGenerator().notificationOccurred(.success)
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
