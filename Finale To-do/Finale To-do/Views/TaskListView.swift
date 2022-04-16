//
//  HomeView.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/14/22.
//

import UIKit
import SwiftUI

class TaskListView: UIView, UITableViewDataSource, UITableViewDelegate, UITableViewDragDelegate, UITableViewDropDelegate {

    let app: App
    
    let padding = 16.0
    let sliderHeight = 30.0
    
    var blurEffect: UIVisualEffectView!
    var colorPanelHeader: UIView!
    var hamburgerButton: UIButton!
    var titleLabel: UILabel!
    var tableView: UITableView!
    var addTaskButton: AddTaskButton!
    
    var taskLists: [TaskList]
    
    var allUpcomingTasks = [Task]()
    var allCompletedTasks = [Task]()
    
    var originalTableContentOffsetY = 0.0
    var originalHeaderHeight = 0.0
    var originalTitlePositionY = 0.0
    var originalTitleFontSize = 40.0
    
    init(frame: CGRect, taskLists: [TaskList], app: App) {
        self.app = app
        self.taskLists = taskLists
        
        super.init(frame: frame)
        
        DrawContent(frame: CGRect(x: 0, y: frame.height*0.2, width: frame.width, height: frame.height*0.8))
        DrawHeader(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height*0.2))
        
        ReloadTaskData()
    }
    
    func DrawHeader(frame: CGRect) {
        let header = UIView(frame: frame)
        originalHeaderHeight = frame.height
        
        blurEffect = UIVisualEffectView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        blurEffect.effect = UIBlurEffect(style: .systemUltraThinMaterial)
        header.addSubview(blurEffect)
        
        colorPanelHeader = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        colorPanelHeader.backgroundColor = App.selectedTaskListIndex == 0 ? .clear : taskLists[0].primaryColor
        colorPanelHeader.layer.compositingFilter = UITraitCollection.current.userInterfaceStyle == .light ? "multiplyBlendMode" : "screenBlendMode"
        colorPanelHeader.layer.opacity = UITraitCollection.current.userInterfaceStyle == .light ? 1 : 0.8
        header.addSubview(colorPanelHeader)
        
        let hamburgerButtonSize = frame.width * 0.1
        hamburgerButton = UIButton(frame: CGRect(x: padding, y: frame.height*0.4, width: hamburgerButtonSize, height: hamburgerButtonSize))
        hamburgerButton.tintColor = App.selectedTaskListIndex == 0 ? .label : .white
        hamburgerButton.setImage(UIImage(systemName: "line.3.horizontal"), for: .normal)
        hamburgerButton.imageView?.contentMode = .scaleAspectFit
        hamburgerButton.contentVerticalAlignment = .fill
        hamburgerButton.contentHorizontalAlignment = .fill
        hamburgerButton.addTarget(self, action: #selector(ToggleSideMenu), for: .touchUpInside)
        
        header.addSubview(hamburgerButton)
        
        titleLabel = UILabel(frame: CGRect(x: padding, y: hamburgerButton.frame.maxY + padding*0.45, width: header.frame.width-padding*2, height: header.frame.height*0.3))
        titleLabel.font = UIFont.systemFont(ofSize: originalTitleFontSize, weight: .bold)
        titleLabel.text = App.selectedTaskListIndex == 0 ? "Hi, Grant" : taskLists[0].name
        titleLabel.textColor = App.selectedTaskListIndex == 0 ? .label : .white
        originalTitlePositionY = titleLabel.frame.origin.y
        
        header.addSubview(titleLabel)
        
        addSubview(header)
        
        originalTableContentOffsetY = tableView.contentOffset.y
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
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        tableView.dragInteractionEnabled = true
        
        contentView.addSubview(tableView)
        
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(DragGesture))
        dragGesture.minimumNumberOfTouches = 1
        contentView.addGestureRecognizer(dragGesture)
        
        let addTaskButtonSize = 56.0
        addTaskButton = AddTaskButton(frame: CGRect(x: frame.width-addTaskButtonSize-padding*2, y: frame.height-addTaskButtonSize-padding*3, width: addTaskButtonSize, height: addTaskButtonSize), color: .defaultColor, app: app)
        
        contentView.addSubview(addTaskButton)
        
        addSubview(contentView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? allUpcomingTasks.count : allCompletedTasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskSliderTableCell
        
        let task = indexPath.section == 0 ? allUpcomingTasks[indexPath.row] : allCompletedTasks[indexPath.row]
        cell.Setup(
            task: task,
            sliderSize: CGSize(width: tableView.frame.width-padding*2, height: tableView.rowHeight-padding*0.5),
            cellSize: CGSize(width: tableView.frame.width, height: tableView.rowHeight),
            sliderColor: getTaskListColor(id: task.taskListID), app: app)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil) { suggestedActions in
            
            let Delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                let cell = tableView.cellForRow(at: indexPath) as! TaskSliderTableCell
                self.app.DeleteTask(task: cell.slider.task)
            }

            return UIMenu(title: "", children: [Delete])
        }
    }
    
    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return getSliderPreview(configuration: configuration)
    }
    
    func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return getSliderPreview(configuration: configuration)
    }
    
    func tableView(_ tableView: UITableView, dropPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        let dragPreviewParams = UIDragPreviewParameters()
        let cell = tableView.cellForRow(at: indexPath) as! TaskSliderTableCell
        dragPreviewParams.visiblePath = UIBezierPath(roundedRect: cell.slider.frame, cornerRadius: 10.0)
        dragPreviewParams.backgroundColor = .clear
        return dragPreviewParams
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {}
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        if indexPath.section == 1 { return [] }
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        let cell = tableView.cellForRow(at: indexPath) as! TaskSliderTableCell
        dragItem.localObject = cell.contentView
        dragItem.previewProvider = {
            let dragPreviewParams = UIDragPreviewParameters()
            dragPreviewParams.visiblePath = UIBezierPath(roundedRect: cell.slider.bounds, cornerRadius: 10.0)
            return UIDragPreview(view: cell.slider, parameters: dragPreviewParams)
        }
        return [dragItem]
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if proposedDestinationIndexPath.section == 0 { return proposedDestinationIndexPath }
        else { return IndexPath(row: allUpcomingTasks.count-1, section: 0) }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let mover = allUpcomingTasks.remove(at: sourceIndexPath.row)
        allUpcomingTasks.insert(mover, at: destinationIndexPath.row)
        if App.selectedTaskListIndex == 0 {
            var prevTaskIndex = -1
            for i in 0..<allUpcomingTasks.count {
                if allUpcomingTasks[i].taskListID == mover.taskListID {
                    if i < destinationIndexPath.row {
                        prevTaskIndex = i
                    }
                }
            }
            let taskList = app.getTaskList(id: mover.taskListID)
            let index = taskList.upcomingTasks.firstIndex(of: mover)!
            taskList.upcomingTasks.remove(at: index)
            if prevTaskIndex != -1 {
                let insertIndex = taskList.upcomingTasks.firstIndex(of: allUpcomingTasks[prevTaskIndex])! + 1
                taskList.upcomingTasks.insert(mover, at: insertIndex)
            } else {
                taskList.upcomingTasks.insert(mover, at: 0)
            }
        } else if App.selectedTaskListIndex == 1 {
            App.mainTaskList.upcomingTasks.remove(at: sourceIndexPath.row)
            App.mainTaskList.upcomingTasks.insert(mover, at: destinationIndexPath.row)
        } else {
            App.userTaskLists[App.selectedTaskListIndex-2].upcomingTasks.remove(at: sourceIndexPath.row)
            App.userTaskLists[App.selectedTaskListIndex-2].upcomingTasks.insert(mover, at: destinationIndexPath.row)
        }
    }
    
    func getSliderPreview(configuration: UIContextMenuConfiguration) -> UITargetedPreview {
        let indexPath = configuration.identifier as! IndexPath
        
        let cell = tableView.cellForRow(at: indexPath) as! TaskSliderTableCell
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        parameters.visiblePath = UIBezierPath(roundedRect: cell.slider.bounds, cornerRadius: 10)

        return UITargetedPreview(view: cell.slider, parameters: parameters)
    }
    
    var scrollDelta: CGFloat {
        return max(0, originalTableContentOffsetY - tableView.contentOffset.y)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if titleLabel == nil || colorPanelHeader == nil || blurEffect == nil { return }
        
        titleLabel.font = UIFont.systemFont(ofSize: originalTitleFontSize+scrollDelta*0.05, weight: .bold)
        titleLabel.frame.origin.y = originalTitlePositionY + scrollDelta
        colorPanelHeader.frame.size.height = originalHeaderHeight + scrollDelta
        blurEffect.frame.size.height = originalHeaderHeight + scrollDelta
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
    
    func getTaskListColor (id: UUID) -> UIColor {
        for taskList in taskLists {
            if taskList.id == id {
                return taskList.primaryColor
            }
        }
        return .purple
    }
    
    func ReloadTaskData() {
        allUpcomingTasks.removeAll()
        allCompletedTasks.removeAll()
        for taskList in taskLists {
            allUpcomingTasks.append(contentsOf: taskList.upcomingTasks)
            allCompletedTasks.append(contentsOf: taskList.completedTasks)
        }
        allCompletedTasks = allCompletedTasks.sorted { $0.dateCompleted > $1.dateCompleted }
    }
    
    func ReloadView () {
        ReloadTaskData()
        tableView.reloadData()
        originalTableContentOffsetY = tableView.contentOffset.y
        titleLabel.text = App.selectedTaskListIndex == 0 ? "Hi, Grant" : taskLists[0].name
        titleLabel.textColor = App.selectedTaskListIndex == 0 ? .label : .white
        hamburgerButton.tintColor = App.selectedTaskListIndex == 0 ? .label : .white
        colorPanelHeader.backgroundColor = App.selectedTaskListIndex == 0 ? .clear : taskLists[0].primaryColor
        colorPanelHeader.layer.compositingFilter = UITraitCollection.current.userInterfaceStyle == .light ? "multiplyBlendMode" : "screenBlendMode"
        colorPanelHeader.layer.opacity = UITraitCollection.current.userInterfaceStyle == .light ? 1 : 0.8
        addTaskButton.ReloadVisuals(color: App.selectedTaskListIndex == 0 ? .defaultColor : taskLists[0].primaryColor)
    }
    
    
    
    
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
