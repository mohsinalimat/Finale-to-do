//
//  ViewController.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/14/22.
//

import UIKit

class App: UIViewController {

    static var mainTaskList: TaskList = TaskList(name: "Main", primaryColor: .defaultColor, systemIcon: "folder.fill")
    static var userTaskLists: [TaskList] = [TaskList]()
    
    static var selectedTaskListIndex: Int = 0
    
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
    
    let sideMenuWidth = UIScreen.main.bounds.width*0.8
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LoadData()
        
        let sideMenuFrame = CGRect(x: 0, y: 0, width: sideMenuWidth, height: UIScreen.main.bounds.height)
        sideMenuView = SideMenuView(frame: sideMenuFrame, app: self)
        
        let fullScreenFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        taskListView = TaskListView(frame: fullScreenFrame, taskLists: allTaskLists, app: self)
        
        self.view.addSubview(sideMenuView)
        self.view.addSubview(taskListView)
    }
    
    func LoadData() {
        let mainTaskListID = UUID()
        App.mainTaskList.upcomingTasks = [Task(name: "Boy", taskListID: mainTaskListID), Task(name: "I sure wanna", taskListID: mainTaskListID)]
        App.mainTaskList.completedTasks = [Task(name: "Die", isComleted: true, taskListID: mainTaskListID)]
        App.mainTaskList.id = mainTaskListID
        
        let workTaskListID = UUID()
        let homeTaskListID = UUID()
        App.userTaskLists.append(TaskList(name: "Work", primaryColor: .red, systemIcon: "folder.fill", upcomingTasks: [Task(name: "dude", taskListID: workTaskListID)], completedTasks: [Task(name: "dude done", isComleted: true, taskListID: workTaskListID)], id: workTaskListID))
        App.userTaskLists.append(TaskList(name: "Home", primaryColor: .blue, systemIcon: "house.fill", upcomingTasks: [Task(name: "house work", taskListID: homeTaskListID)], completedTasks: [Task(name: "work not done", isComleted: true, taskListID: homeTaskListID)], id: homeTaskListID))
    }
    
/// Task Actions
    
    func CompleteTask(task: Task) {
        var index = -1
        task.isCompleted = true
        task.dateCompleted = Date.now
        
        if App.mainTaskList.upcomingTasks.contains(task) {
            index = App.mainTaskList.upcomingTasks.firstIndex(of: task)!
            
            App.mainTaskList.upcomingTasks.remove(at: index)
            App.mainTaskList.completedTasks.insert(task, at: 0)
        } else {
            for taskList in App.userTaskLists {
                if taskList.id == task.taskListID {
                    index = taskList.upcomingTasks.firstIndex(of: task)!
                    
                    taskList.upcomingTasks.remove(at: index)
                    taskList.completedTasks.insert(task, at: 0)
                    break
                }
            }
        }
        if index == -1 { return }
        
        let tableIndex = taskListView.allUpcomingTasks.firstIndex(of: task)!
        
        taskListView.taskLists = App.selectedTaskListIndex == 0 ? allTaskLists : App.selectedTaskListIndex == 1 ? [App.mainTaskList] : [App.userTaskLists[App.selectedTaskListIndex-2]]
        taskListView.ReloadTaskData()
        
        taskListView.tableView.beginUpdates()
        taskListView.tableView.deleteRows(at: [IndexPath(row: tableIndex, section: 0)], with: UITableView.RowAnimation.right)
        taskListView.tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: UITableView.RowAnimation.automatic)
        taskListView.tableView.endUpdates()
    }
    
///  Sidemenu Actions

    func SelectTaskList(index: Int){
        App.selectedTaskListIndex = index
        sideMenuView.overviewMenuItem.ReloadVisuals()
        sideMenuView.tableView.reloadData()
        
        taskListView.taskLists = index == 0 ? allTaskLists : index == 1 ? [App.mainTaskList] : [App.userTaskLists[index-2]]
        taskListView.ReloadView()
        
        CloseSideMenu()
    }
    
    func ToggleSideMenu () {
        if isSideMenuOpen { CloseSideMenu() }
        else { OpenSideMenu() }
    }
    
    func OpenSideMenu () {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) { [self] in
            taskListView.frame.origin.x = sideMenuWidth
        }
    }
    
    func CloseSideMenu () {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) { [self] in
            taskListView.frame.origin.x = 0
        }
    }
    
    var originX = 0.0
    var prevIsOpen = false
    func DragSideMenu (sender: UIPanGestureRecognizer) {
        if sender.state == .began {
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
}

