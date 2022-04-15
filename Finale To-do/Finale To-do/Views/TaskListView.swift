//
//  HomeView.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/14/22.
//

import UIKit

class TaskListView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    let app: App
    
    let padding = 16.0
    
    var tableView: UITableView!
    var addTaskButton: AddTaskButton!
    
    let sliderHeight = 30.0
    
    init(frame: CGRect, app: App) {
        self.app = app
        
        super.init(frame: frame)
        
        DrawContent(frame: CGRect(x: 0, y: frame.height*0.2, width: frame.width, height: frame.height*0.8))
        DrawHeader(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height*0.2))
    }
    
    func DrawHeader(frame: CGRect) {
        let header = UIView(frame: frame)
        
        let blur = UIVisualEffectView(frame: header.frame)
        blur.effect = UIBlurEffect(style: .systemUltraThinMaterial)
        header.addSubview(blur)
        
        let hamburgerButtonSize = frame.width * 0.1
        let hamburgerButton = UIButton(frame: CGRect(x: padding, y: padding*4, width: hamburgerButtonSize, height: hamburgerButtonSize))
        hamburgerButton.tintColor = .label
        hamburgerButton.setImage(UIImage(systemName: "line.3.horizontal"), for: .normal)
        hamburgerButton.imageView?.contentMode = .scaleAspectFit
        hamburgerButton.contentVerticalAlignment = .fill
        hamburgerButton.contentHorizontalAlignment = .fill
        hamburgerButton.addTarget(self, action: #selector(ToggleSideMenu), for: .touchUpInside)
        
        header.addSubview(hamburgerButton)
        
        let titleLabel = UILabel(frame: CGRect(x: padding, y: hamburgerButton.frame.maxY + padding*0.5, width: header.frame.width-padding*2, height: header.frame.height*0.3))
        titleLabel.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        titleLabel.text = "Hi, Grant"
        
        
        header.addSubview(titleLabel)
        
        addSubview(header)
    }
    
    func DrawContent(frame: CGRect) {
        let contentView = UIView(frame: frame)
        
        tableView = UITableView(frame: CGRect(x: 0, y: -frame.origin.y, width: frame.width, height: frame.height+frame.origin.y))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 40+padding*0.5
        tableView.register(TaskSliderTableCell.self, forCellReuseIdentifier: "taskCell")
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: frame.origin.y, left: 0, bottom: 0, right: 0)
        
        contentView.addSubview(tableView)
        
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(DragGesture))
        dragGesture.minimumNumberOfTouches = 1
        contentView.addGestureRecognizer(dragGesture)
        
        let addTaskButtonSize = 50.0
        addTaskButton = AddTaskButton(frame: CGRect(x: frame.width-addTaskButtonSize-padding*2, y: frame.height-addTaskButtonSize-padding*3, width: addTaskButtonSize, height: addTaskButtonSize), color: .defaultColor)
        
        contentView.addSubview(addTaskButton)
        
        addSubview(contentView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? App.mainTaskList.upcomingTasks.count : App.mainTaskList.completedTasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskSliderTableCell
        
        cell.Setup(
            task: indexPath.section == 0 ? App.mainTaskList.upcomingTasks[indexPath.row] : App.mainTaskList.completedTasks[indexPath.row],
            sliderSize: CGSize(width: tableView.frame.width-padding*2, height: tableView.rowHeight-padding*0.5),
            cellSize: CGSize(width: tableView.frame.width, height: tableView.rowHeight),
            sliderColor: .defaultColor, app: app)
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Upcoming" : "Completed"
    }
    
    
    
    @objc func ToggleSideMenu () {
        app.ToggleSideMenu()
    }
    
    @objc func DragGesture (sender: UIPanGestureRecognizer) {
        app.DragSideMenu(sender: sender)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
