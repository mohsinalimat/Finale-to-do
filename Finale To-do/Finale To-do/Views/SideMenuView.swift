//
//  SideMenuView.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/15/22.
//

import Foundation
import UIKit

class SideMenuView: UIView, UITableViewDataSource, UITableViewDelegate, UITableViewDragDelegate, UITableViewDropDelegate, UIDynamicTheme {
    
    let app: App
    
    let padding = 32.0
    let menuItemHeight = 50.0
    
    let tableView: UITableView
    var overviewMenuItem: TaskListMenuItem!
    
    var currentContextMenuView: TaskListMenuItem?
    
    let settingsNavControllers: SettingsNavigationController
    
    init(frame: CGRect, app: App) {
        self.app = app
        
        tableView = UITableView()
        settingsNavControllers = SettingsNavigationController()
        super.init(frame: frame)
        
        self.backgroundColor = AppColors.sidemenuBackgroundColor
        
        let homeLabel = UILabel(frame: CGRect(x: padding, y: frame.height*0.2-30, width: frame.width-padding*2, height: 30))
        homeLabel.text = "Home"
        homeLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        homeLabel.textColor = .white
        
        self.addSubview(homeLabel)
        
        overviewMenuItem = TaskListMenuItem(frame: CGRect(x: padding*0.5, y: homeLabel.frame.maxY+padding*0.5, width: frame.width-padding, height: menuItemHeight), taskList: TaskList(name: "Overview", primaryColor: .defaultColor, systemIcon: "tray.full.fill"), index: 0)
        
        self.addSubview(overviewMenuItem)
        
        let listsLabel = UILabel(frame: CGRect(x: padding, y: overviewMenuItem.frame.maxY + padding*0.5, width: frame.width-padding*2, height: 30))
        listsLabel.text = "Lists"
        listsLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        listsLabel.textColor = .white
        
        self.addSubview(listsLabel)
        
        tableView.frame = CGRect(x: padding*0.5, y: listsLabel.frame.maxY+padding*0.5, width: frame.width-padding, height: frame.height*0.87-listsLabel.frame.maxY)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        tableView.dragInteractionEnabled = true
        tableView.rowHeight = menuItemHeight
        tableView.register(TaskListTableCell.self, forCellReuseIdentifier: "sideMenuTaskListCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        
        self.addSubview(tableView)
        
        let addListButton = UIButton(frame: CGRect(x: padding, y: tableView.frame.maxY+padding*0.5, width: (frame.width-padding*2)*0.5, height: 25))
        addListButton.setTitle("Create list", for: .normal)
        addListButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addListButton.setTitleColor(.gray, for: .highlighted)
        addListButton.tintColor = .white
        addListButton.contentHorizontalAlignment = .leading
        addListButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
        addListButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        addListButton.addTarget(self, action: #selector(OpenAddTaskListView), for: .touchUpInside)
        
        self.addSubview(addListButton)
        
        let settingsButton = UIButton(frame: CGRect(x: frame.width-padding-25, y: addListButton.frame.origin.y, width: 25, height: 25))
        settingsButton.setImage(UIImage(systemName: "gearshape"), for: .normal)
        settingsButton.tintColor = .white
        settingsButton.addTarget(self, action: #selector(OpenSettings), for: .touchUpInside)
        
        self.addSubview(settingsButton)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return App.userTaskLists.count+1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sideMenuTaskListCell", for: indexPath) as! TaskListTableCell
        
        if indexPath.row == 0 {
            cell.Setup(taskList: App.mainTaskList, frameSize: CGSize(width: tableView.frame.width, height: tableView.rowHeight), index: 1)
        } else {
            cell.Setup(taskList: App.userTaskLists[indexPath.row-1], frameSize: CGSize(width: tableView.frame.width, height: tableView.rowHeight), index: indexPath.row+1)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil) { suggestedActions in
            let DeleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                let cell = tableView.cellForRow(at: indexPath) as! TaskListTableCell
                App.instance.view.addSubview(ConfirmationSlideover(
                    title: "Delete \"\(cell.taskListMenuItem.taskList.name)\"?",
                    subTitle: "All tasks from this list will be lost",
                    confirmActionTitle: " Delete",
                    confirmAction: { App.instance.DeleteTaskList(taskList: cell.taskListMenuItem.taskList) }
                ))
            }
            let Delete = UIMenu(title: "", options: .displayInline, children: [DeleteAction])
            
            let Edit = UIAction(title: "Edit", image: UIImage(systemName: "square.and.pencil")) { action in
                let cell = tableView.cellForRow(at: indexPath) as! TaskListTableCell
                App.instance.OpenEditTaskListView(taskList: cell.taskListMenuItem.taskList)
            }
            
            let Regular = UIMenu(title: "", options: .displayInline, children: [Edit])
            
            if indexPath.row == 0 { return UIMenu(title: "", children: [Regular]) }
            return UIMenu(title: "", children: [Regular, Delete])
        }
    }
    
    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return getMenuItemPreview(configuration: configuration, isDismissing: false)
    }
    
    func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        let x = getMenuItemPreview(configuration: configuration, isDismissing: true)
        x.parameters.backgroundColor = .clear
        return x
    }
    
    func tableView(_ tableView: UITableView, dropPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        let dragPreviewParams = UIDragPreviewParameters()
        let cell = tableView.cellForRow(at: indexPath) as! TaskListTableCell
        dragPreviewParams.visiblePath = UIBezierPath(roundedRect: cell.taskListMenuItem.frame, cornerRadius: 10.0)
        dragPreviewParams.backgroundColor = cell.taskListMenuItem.isSelected ? AppColors.sidemenuSelectedItemColor : .clear
        return dragPreviewParams
    }
    func tableView(_ tableView: UITableView, dragPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        let dragPreviewParams = UIDragPreviewParameters()
        let cell = tableView.cellForRow(at: indexPath) as! TaskListTableCell
        dragPreviewParams.visiblePath = UIBezierPath(roundedRect: cell.taskListMenuItem.frame, cornerRadius: 10.0)
        dragPreviewParams.backgroundColor = cell.taskListMenuItem.isSelected ? AppColors.sidemenuSelectedItemColor : .clear
        return dragPreviewParams
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {}
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        let cell = tableView.cellForRow(at: indexPath) as! TaskListTableCell
        dragItem.localObject = cell.contentView
        dragItem.previewProvider = {
            let dragPreviewParams = UIDragPreviewParameters()
            dragPreviewParams.visiblePath = UIBezierPath(roundedRect: cell.taskListMenuItem.bounds, cornerRadius: 10.0)
            dragPreviewParams.backgroundColor = AppColors.sidemenuSelectedItemColor
            return UIDragPreview(view: cell.taskListMenuItem, parameters: dragPreviewParams)
        }
        return [dragItem]
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if sourceIndexPath.row == 0 { return sourceIndexPath }
        if proposedDestinationIndexPath.row != 0 { return proposedDestinationIndexPath }
        else { return IndexPath(row: 1, section: 0) }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath.row == 0 { return }
        let mover = App.userTaskLists.remove(at: sourceIndexPath.row-1)
        App.userTaskLists.insert(mover, at: destinationIndexPath.row-1)
        tableView.reloadData()
    }
    
    func getMenuItemPreview(configuration: UIContextMenuConfiguration, isDismissing: Bool) -> UITargetedPreview {
        let indexPath = configuration.identifier as! IndexPath
        
        let previewView: TaskListMenuItem
        if !isDismissing {
            let cell = tableView.cellForRow(at: indexPath) as! TaskListTableCell
            previewView = cell.taskListMenuItem
            currentContextMenuView = previewView
        } else {
            previewView = currentContextMenuView!
        }
        
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = AppColors.sidemenuSelectedItemColor
        parameters.visiblePath = UIBezierPath(roundedRect: previewView.bounds, cornerRadius: 10)

        return UITargetedPreview(view: previewView, parameters: parameters)
    }
    
    
    @objc func OpenAddTaskListView () {
        app.OpenAddTaskListView()
    }
    
    @objc func OpenSettings () {
        settingsNavControllers.popToRootViewController(animated: false)
        let mainPage = settingsNavControllers.topViewController as! SettingsPageViewController
        mainPage.ReloadSettings()
        mainPage.tableView.reloadData()
        App.instance.present(settingsNavControllers, animated: true)
    }
    
    func SetThemeColors() {
        UIView.animate(withDuration: 0.25) {
            self.backgroundColor = AppColors.sidemenuBackgroundColor
        }
    }
    
    func UpdateUpcomingTasksCounts () {
        for cell in tableView.visibleCells {
            let taskListCell = cell as! TaskListTableCell
            taskListCell.taskListMenuItem.upcomingTaskCountLabel.text = taskListCell.taskListMenuItem.taskList.upcomingTasks.count.description
        }
    }
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class TaskListMenuItem: UIView, UIDynamicTheme {
    
    let taskList: TaskList
    let padding = 8.0
    let imageWidthProportion = 0.1
    let index: Int
    
    var upcomingTaskCountLabel: UILabel!
    
    var isSelected: Bool {
        get {
            return App.selectedTaskListIndex == index
        }
    }
    
    init(frame: CGRect, taskList: TaskList, index: Int) {
        self.index = index
        self.taskList = taskList
        super.init(frame: frame)
        
        self.backgroundColor = isSelected ? AppColors.sidemenuSelectedItemColor : .clearInteractive
        self.layer.cornerRadius = 10
        
        let iconView = UIImageView(frame: CGRect(x: padding*2+1, y: 1, width: (frame.width-padding*2)*imageWidthProportion-2, height: frame.height-2))
        iconView.image = UIImage(systemName: taskList.systemIcon)
        iconView.tintColor = taskList.primaryColor
        iconView.contentMode = .scaleAspectFit
        
        let upcomingTaskCountLabelWidth: CGFloat
        if index != 0 {
            upcomingTaskCountLabelWidth = 20
            upcomingTaskCountLabel = UILabel(frame: CGRect(x: frame.width-padding*2-upcomingTaskCountLabelWidth, y: 0, width: upcomingTaskCountLabelWidth, height: frame.height))
            upcomingTaskCountLabel.textColor = .lightGray
            upcomingTaskCountLabel.text = taskList.upcomingTasks.count == 0 ? "" : taskList.upcomingTasks.count.description
            upcomingTaskCountLabel.adjustsFontSizeToFitWidth = true
            upcomingTaskCountLabel.font = .preferredFont(forTextStyle: .subheadline)
            upcomingTaskCountLabel.textAlignment = .right
            self.addSubview(upcomingTaskCountLabel)
        } else { upcomingTaskCountLabelWidth = 0 }
        
        let titleLabelWidth = (frame.width-padding*3)*(1-imageWidthProportion) - padding*3 - upcomingTaskCountLabelWidth
        let titleLabel = UILabel(frame: CGRect(x: (frame.width-padding*2)*imageWidthProportion+padding*3, y: 0, width: titleLabelWidth, height: frame.height))
        titleLabel.text = taskList.name
        titleLabel.textColor = .white
        
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SelectList)))
        
        self.addSubview(iconView)
        self.addSubview(titleLabel)
        
    }
    
    @objc func SelectList () {
        App.instance.SelectTaskList(index: index)
    }
    
    func ReloadVisuals () {
        self.backgroundColor = isSelected ? AppColors.sidemenuSelectedItemColor : .clearInteractive
    }
    
    func SetThemeColors() {
        UIView.animate(withDuration: 0.25) {
            self.ReloadVisuals()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class TaskListTableCell: UITableViewCell {
    
    var taskListMenuItem: TaskListMenuItem!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        isUserInteractionEnabled = true
        backgroundColor = .clear
    }
    
    func Setup(taskList: TaskList, frameSize: CGSize, index: Int) {
        for subview in contentView.subviews {
            subview.removeFromSuperview()
        }
        taskListMenuItem = TaskListMenuItem(frame: CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height), taskList: taskList, index: index)
        contentView.addSubview(taskListMenuItem)
    }
    
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
