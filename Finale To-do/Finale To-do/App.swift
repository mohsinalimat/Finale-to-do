//
//  ViewController.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/14/22.
//

import UIKit

class App: UIViewController {

    static var mainTaskList: TaskList = TaskList(name: "Overview", primaryColor: .defaultColor, systemIcon: "tray.full.fill")
    static var userTaskLists: [TaskList] = [TaskList]()
    
    static var selectedTaskListIndex: Int = 0
    
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
        taskListView = TaskListView(frame: fullScreenFrame, app: self)
        
        self.view.addSubview(sideMenuView)
        self.view.addSubview(taskListView)
    }
    
    func LoadData() {
        App.mainTaskList.upcomingTasks = [Task(name: "Boy"), Task(name: "I sure wanna")]
        App.mainTaskList.completedTasks = [Task(name: "Die", isComleted: true)]
        
        App.userTaskLists.append(TaskList(name: "Work", primaryColor: .red, systemIcon: "folder.fill", upcomingTasks: [Task(name: "dude")], completedTasks: [Task(name: "dude done")]))
        App.userTaskLists.append(TaskList(name: "Home", primaryColor: .blue, systemIcon: "house.fill", upcomingTasks: [Task(name: "house work")], completedTasks: [Task(name: "work not done")]))
    }
    
/// Task Actions
    
    func CompleteTask(task: Task) {
        if !App.mainTaskList.upcomingTasks.contains(task) { return }
        
        task.isCompleted = true
        
        let index = App.mainTaskList.upcomingTasks.firstIndex(of: task)!
        App.mainTaskList.completedTasks.insert(task, at: 0)
        App.mainTaskList.upcomingTasks.remove(at: index)
        
        taskListView.tableView.beginUpdates()
        taskListView.tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: UITableView.RowAnimation.automatic)
        taskListView.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: UITableView.RowAnimation.right)
        taskListView.tableView.endUpdates()
    }
    
///  Sidemenu Actions

    func SelectTaskList(index: Int){
        App.selectedTaskListIndex = index
        sideMenuView.overviewMenuItem.ReloadVisuals()
        sideMenuView.tableView.reloadData()
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

