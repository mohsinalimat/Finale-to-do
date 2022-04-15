//
//  ViewController.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/14/22.
//

import UIKit

class App: UIViewController {

    static var mainTaskList: TaskList = TaskList(name: "Main", primaryColor: .defaultColor, systemIcon: "folder.filled")
    
    var homeView: HomeView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LoadData()
        
        let fullScreenFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        homeView = HomeView(frame: fullScreenFrame, app: self)
        
        self.view.addSubview(homeView)
    }
    
    func LoadData() {
        App.mainTaskList.upcomingTasks = [Task(name: "Boy"), Task(name: "I sure wanna")]
        App.mainTaskList.completedTasks = [Task(name: "Die", isComleted: true)]
    }
    
/// Task Actions
    
    func CompleteTask(task: Task) {
        if !App.mainTaskList.upcomingTasks.contains(task) { return }
        
        task.isCompleted = true
        
        let index = App.mainTaskList.upcomingTasks.firstIndex(of: task)!
        App.mainTaskList.completedTasks.insert(task, at: 0)
        App.mainTaskList.upcomingTasks.remove(at: index)
        
        homeView.tableView.beginUpdates()
        homeView.tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: UITableView.RowAnimation.automatic)
        homeView.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: UITableView.RowAnimation.right)
        homeView.tableView.endUpdates()
    }
}

