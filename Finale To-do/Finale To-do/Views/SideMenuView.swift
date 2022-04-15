//
//  SideMenuView.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/15/22.
//

import Foundation
import UIKit

class SideMenuView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    let app: App
    
    let padding = 32.0
    let menuItemHeight = 50.0
    
    let tableView: UITableView
    var overviewMenuItem: TaskListMenuItem!
    
    init(frame: CGRect, app: App) {
        self.app = app
        
        tableView = UITableView()
        
        super.init(frame: frame)
        
        self.backgroundColor = .defaultColor.thirdColor
        
        let homeLabel = UILabel(frame: CGRect(x: padding, y: frame.height*0.2-30, width: frame.width-padding*2, height: 30))
        homeLabel.text = "Home"
        homeLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        
        self.addSubview(homeLabel)
        
        overviewMenuItem = TaskListMenuItem(frame: CGRect(x: padding*0.5, y: homeLabel.frame.maxY+padding*0.5, width: frame.width-padding, height: menuItemHeight), taskList: App.mainTaskList, index: 0, app: app)
        
        self.addSubview(overviewMenuItem)
        
        let listsLabel = UILabel(frame: CGRect(x: padding, y: overviewMenuItem.frame.maxY + padding*0.5, width: frame.width-padding*2, height: 30))
        listsLabel.text = "Lists"
        listsLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        
        self.addSubview(listsLabel)
        
        tableView.frame = CGRect(x: padding*0.5, y: listsLabel.frame.maxY+padding*0.5, width: frame.width-padding, height: frame.height*0.87-listsLabel.frame.maxY)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = menuItemHeight
        tableView.register(TaskListTableCell.self, forCellReuseIdentifier: "sideMenuTaskListCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        
        self.addSubview(tableView)
        
        let addListButton = UIButton(frame: CGRect(x: padding, y: tableView.frame.maxY+padding*0.5, width: (frame.width-padding*2)*0.5, height: 25))
        addListButton.setTitle("Add list", for: .normal)
        addListButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addListButton.setTitleColor(.gray, for: .highlighted)
        addListButton.tintColor = .white
        addListButton.contentHorizontalAlignment = .leading
        addListButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
        addListButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        
        self.addSubview(addListButton)
        
        let settingsButton = UIButton(frame: CGRect(x: frame.width-padding-25, y: addListButton.frame.origin.y, width: 25, height: 25))
        settingsButton.setImage(UIImage(systemName: "gearshape"), for: .normal)
        settingsButton.tintColor = .white
        
        self.addSubview(settingsButton)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return App.userTaskLists.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sideMenuTaskListCell", for: indexPath) as! TaskListTableCell
        
        cell.Setup(taskList: App.userTaskLists[indexPath.row], frameSize: CGSize(width: tableView.frame.width, height: tableView.rowHeight), index: indexPath.row+1, app: app)
        
        return cell
    }
    
    
    
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class TaskListMenuItem: UIView {
    
    let app: App
    
    let padding = 8.0
    let imageWidthProportion = 0.1
    let index: Int
    
    var isSelected: Bool {
        get {
            return App.selectedTaskListIndex == index
        }
    }
    
    init(frame: CGRect, taskList: TaskList, index: Int, app: App) {
        self.index = index
        self.app = app
        super.init(frame: frame)
        
        self.backgroundColor = isSelected ? .defaultColor.lerp(second: .defaultColor.thirdColor, percentage: 0.7) : .clearInteractive
        self.layer.cornerRadius = 10
        
        let iconView = UIImageView(frame: CGRect(x: padding*2+1, y: 1, width: (frame.width-padding*2)*imageWidthProportion-2, height: frame.height-2))
        iconView.image = UIImage(systemName: taskList.systemIcon)
        iconView.tintColor = taskList.primaryColor
        iconView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel(frame: CGRect(x: (frame.width-padding*2)*imageWidthProportion+padding*3, y: 0, width: (frame.width-padding*3)*(1-imageWidthProportion), height: frame.height))
        titleLabel.text = taskList.name
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SelectList))
        self.addGestureRecognizer(tapGesture)
        
        self.addSubview(iconView)
        self.addSubview(titleLabel)
    }
    
    @objc func SelectList () {
        app.SelectTaskList(index: index)
    }
    
    func ReloadVisuals () {
        self.backgroundColor = isSelected ? .defaultColor.lerp(second: .defaultColor.thirdColor, percentage: 0.7) : .clearInteractive
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class TaskListTableCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        isUserInteractionEnabled = true
        backgroundColor = .clear
    }
    
    func Setup(taskList: TaskList, frameSize: CGSize, index: Int, app: App) {
        for subview in contentView.subviews {
            subview.removeFromSuperview()
        }
        contentView.addSubview(TaskListMenuItem(frame: CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height), taskList: taskList, index: index, app: app))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
