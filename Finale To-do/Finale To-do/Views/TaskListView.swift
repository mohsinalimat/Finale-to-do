//
//  HomeView.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/14/22.
//

import UIKit
import SwiftUI

class TaskListView: UIView, UITableViewDataSource, UITableViewDelegate, UITableViewDragDelegate, UITableViewDropDelegate, UIDynamicTheme {

    let app: App
    
    let padding = 16.0
    let sliderHeight = 36.0
    
    var contentView: UIView!
    var blurEffect: UIVisualEffectView!
    var colorPanelHeader: UIView!
    var hamburgerButton: UIButton!
    var sortButton: UIButton!
    var titleLabel: UILabel!
    var tableView: UITableView!
    var addTaskButton: AddTaskButton!
    
    var taskLists: [TaskList]
    
    var allUpcomingTasks = [Task]()
    var allCompletedTasks = [Task]()
    
    var originalAddTaskPositionY = 0.0
    var originalTableContentOffsetY = 0.0
    var originalHeaderHeight = 0.0
    var originalTitlePositionY = 0.0
    
    var currentContextMenuPreviewCenter: CGPoint?
    var currentContextMenuPreview: UIView?
    var currentSliderEditing: TaskSlider?
    
    var undoButton: UndoButton?
    var lastTaskUndoTimer: Timer?
    var lastTaskUndoTimeThreashold = 3.0
    
    init(frame: CGRect, taskLists: [TaskList], app: App) {
        self.app = app
        self.taskLists = taskLists
        
        super.init(frame: frame)
        
        DrawContent(frame: CGRect(x: 0, y: frame.height*0.2, width: frame.width, height: frame.height*0.8))
        DrawHeader(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height*0.2))
        
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
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
        
        let sortButtonSize = hamburgerButtonSize
        sortButton = UIButton(frame: CGRect(x: frame.width-sortButtonSize-padding, y: hamburgerButton.frame.origin.y, width: sortButtonSize, height: sortButtonSize))
        sortButton.tintColor = App.selectedTaskListIndex == 0 ? .label : .white
        sortButton.setImage(UIImage(systemName: "arrow.up.arrow.down"), for: .normal)
        sortButton.contentVerticalAlignment = .fill
        sortButton.contentHorizontalAlignment = .fill
        sortButton.imageEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 0)
        sortButton.imageView?.contentMode = .scaleAspectFit
        sortButton.contentHorizontalAlignment = .right
        sortButton.showsMenuAsPrimaryAction = true
        sortButton.menu = sortButtonMenu
        
        header.addSubview(sortButton)
        
        let titleHeight = header.frame.height*0.3
        let titleWidth = header.frame.width-padding*2
        titleLabel = UILabel(frame: CGRect(x: padding - titleWidth*0.5, y: hamburgerButton.frame.maxY + padding*0.45 + titleHeight*0.5, width: titleWidth, height: titleHeight))
        titleLabel.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        titleLabel.text = App.selectedTaskListIndex == 0 ? "Hi, Grant" : taskLists[0].name
        titleLabel.textColor = App.selectedTaskListIndex == 0 ? .label : .white
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.layer.anchorPoint = CGPoint(x: 0, y: 1)
        originalTitlePositionY = titleLabel.frame.origin.y
        
        header.addSubview(titleLabel)
        
        addSubview(header)
        
        originalTableContentOffsetY = tableView.contentOffset.y
    }
    
    func DrawContent(frame: CGRect) {
        contentView?.removeFromSuperview()
        contentView = UIView(frame: frame)
        
        tableView = UITableView(frame: CGRect(x: 0, y: -frame.origin.y, width: frame.width, height: frame.height+frame.origin.y))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = sliderHeight+padding*0.5
        tableView.register(TaskSliderTableCell.self, forCellReuseIdentifier: "taskCell")
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: frame.origin.y, left: 0, bottom: 0, right: 0)
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        tableView.dragInteractionEnabled = true
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TouchedTable)))
        
        contentView.addSubview(tableView)
        
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(DragGesture))
        dragGesture.minimumNumberOfTouches = 1
        contentView.addGestureRecognizer(dragGesture)
        
        let addTaskButtonSize = 56.0
        originalAddTaskPositionY = frame.height-addTaskButtonSize-padding*3
        addTaskButton = AddTaskButton(frame: CGRect(x: frame.width-addTaskButtonSize-padding, y: originalAddTaskPositionY, width: addTaskButtonSize, height: addTaskButtonSize), color: .defaultColor, app: app)
        
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
        
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: {  
            let cell = tableView.cellForRow(at: indexPath) as! TaskSliderTableCell
            
            return TaskSliderContextMenu(slider: cell.slider, indexPath: indexPath)
        }, actionProvider: { _ in
            let cell = tableView.cellForRow(at: indexPath) as! TaskSliderTableCell
            let DeleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                self.app.DeleteTask(task: cell.slider.task)
            }
            let Delete = UIMenu(title: "", options: .displayInline, children: [DeleteAction])
            
            let Undo = UIAction(title: "Undo", image: UIImage(systemName: "arrow.uturn.left")) { action in
                self.app.UndoCompletingTask(task: cell.slider.task)
            }
            let Edit = UIAction(title: "Edit", image: UIImage(systemName: "square.and.pencil")) { action in
                cell.slider.StartEditing()
            }
            let AssignDate = UIAction(title: cell.slider.task.isDateAssigned ? "Change date" : "Assign date", image: UIImage(systemName: "calendar")) { action in
                cell.slider.ShowCalendarView()
            }
            
            var items = [UIAction]()
            if indexPath.section == 0 { items.append(AssignDate); items.append(Edit) }
            if indexPath.section == 1 { items.append(Undo) }
            
            let Regular = UIMenu(title: "", options: .displayInline, children: items)
            
            return UIMenu(title: "", children: [Regular, Delete])
        })
    }
    
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        
        if let preview = animator.previewViewController {
            let x = preview as! TaskSliderContextMenu
            if x.slider.task.isCompleted {
                animator.preferredCommitStyle = .dismiss
            } else {
                animator.addCompletion {
                    x.PresentFullScreen()
                    App.instance.present(preview, animated: true)
                }
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return getSliderPreview(configuration: configuration, isDismissing: true)
    }
    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return getSliderPreview(configuration: configuration, isDismissing: false)
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
        if sourceIndexPath.section == 1 || App.selectedTaskListIndex == 0 { return sourceIndexPath }
        if proposedDestinationIndexPath.section == 0 { return proposedDestinationIndexPath }
        else { return IndexPath(row: allUpcomingTasks.count-1, section: 0) }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath.section == 1 || App.selectedTaskListIndex == 0 { return }
        
        let mover = allUpcomingTasks.remove(at: sourceIndexPath.row)
        allUpcomingTasks.insert(mover, at: destinationIndexPath.row)
        if App.selectedTaskListIndex == 0 {
            // do nothing
        } else if App.selectedTaskListIndex == 1 {
            App.mainTaskList.upcomingTasks.remove(at: sourceIndexPath.row)
            App.mainTaskList.upcomingTasks.insert(mover, at: destinationIndexPath.row)
            App.mainTaskList.sortingPreference = .Unsorted
        } else {
            App.userTaskLists[App.selectedTaskListIndex-2].upcomingTasks.remove(at: sourceIndexPath.row)
            App.userTaskLists[App.selectedTaskListIndex-2].upcomingTasks.insert(mover, at: destinationIndexPath.row)
            App.userTaskLists[App.selectedTaskListIndex-2].sortingPreference = .Unsorted
        }
        sortButton.menu = sortButtonMenu
    }
    
    func getSliderPreview(configuration: UIContextMenuConfiguration, isDismissing: Bool = false) -> UITargetedPreview {
        let indexPath = configuration.identifier as! IndexPath
        
        if !isDismissing {
            let cell = tableView.cellForRow(at: indexPath) as! TaskSliderTableCell
            currentContextMenuPreview = cell.slider
            currentContextMenuPreviewCenter = cell.center
        }
        let previewView = currentContextMenuPreview!
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        parameters.visiblePath = UIBezierPath(roundedRect: previewView.bounds, cornerRadius: 10)
        
        let target = UIPreviewTarget(container: tableView, center: currentContextMenuPreviewCenter!)
        
        return UITargetedPreview(view: previewView, parameters: parameters, target: target)
    }
    
    
    
    
    var scrollDelta: CGFloat {
        return max(0, originalTableContentOffsetY - tableView.contentOffset.y)
    }
    var maxScrollDelta = 0.0
    var stopped = false
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if titleLabel == nil || colorPanelHeader == nil || blurEffect == nil { return }
        
        if titleLabel.intrinsicContentSize.width*(1 + maxScrollDelta*0.0005) < UIScreen.main.bounds.width-padding*2 {
            maxScrollDelta = scrollDelta
        } else {
            stopped = true
        }
        if stopped && scrollDelta < maxScrollDelta {
            maxScrollDelta = scrollDelta
            stopped = false
        }
        
        titleLabel.transform = CGAffineTransform(scaleX: (1 + maxScrollDelta*0.0005), y: (1 + maxScrollDelta*0.0005) )
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
    
    func ReloadTaskData(sortOverviewList: Bool = true) {
        allUpcomingTasks.removeAll()
        allCompletedTasks.removeAll()
        for taskList in taskLists {
            allUpcomingTasks.append(contentsOf: taskList.upcomingTasks)
            allCompletedTasks.append(contentsOf: taskList.completedTasks)
        }
        allCompletedTasks = allCompletedTasks.sorted { $0.dateCompleted > $1.dateCompleted }
        if App.selectedTaskListIndex == 0 && sortOverviewList { SortUpcomingTasks(sortPreference: App.instance.overviewSortingPreference, animated: false) }
    }
    
    func ReloadView () {
        ReloadTaskData()
        tableView.reloadData()
        tableView.setContentOffset(CGPoint(x: 0, y: tableView.frame.minY), animated: false)
        originalTableContentOffsetY = tableView.contentOffset.y
        titleLabel.text = App.selectedTaskListIndex == 0 ? "Hi, Grant" : taskLists[0].name
        titleLabel.textColor = App.selectedTaskListIndex == 0 ? .label : .white
        hamburgerButton.tintColor = App.selectedTaskListIndex == 0 ? .label : .white
        sortButton.tintColor = App.selectedTaskListIndex == 0 ? .label : .white
        sortButton.menu = sortButtonMenu
        colorPanelHeader.backgroundColor = App.selectedTaskListIndex == 0 ? .clear : taskLists[0].primaryColor
        colorPanelHeader.layer.compositingFilter = UITraitCollection.current.userInterfaceStyle == .light ? "multiplyBlendMode" : "screenBlendMode"
        colorPanelHeader.layer.opacity = UITraitCollection.current.userInterfaceStyle == .light ? 1 : 0.8
        addTaskButton.ReloadVisuals(color: App.selectedTaskListIndex == 0 ? .defaultColor : taskLists[0].primaryColor)
        if undoButton != nil {
            undoButton!.removeFromSuperview()
            undoButton = nil
        }
    }
    
    @objc func KeyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) { [self] in
                let y = frame.height - UIScreen.main.bounds.height*0.17 - keyboardHeight - App.instance.view.safeAreaInsets.bottom - addTaskButton.frame.height
                addTaskButton.frame.origin.y = y
            }
        }
    }
    @objc func KeyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) { [self] in
            addTaskButton.frame.origin.y = originalAddTaskPositionY
        }
    }
    
    func ShowUndoButton () {
        lastTaskUndoTimer?.invalidate()
        lastTaskUndoTimer = Timer.scheduledTimer(timeInterval: lastTaskUndoTimeThreashold, target: self, selector: #selector(HideUndoButton), userInfo: nil, repeats: false)
        
        if undoButton != nil { return }
        
        undoButton = UndoButton(frame: CGRect(x: -addTaskButton.frame.width - 10, y: addTaskButton.frame.origin.y, width: addTaskButton.frame.width, height: addTaskButton.frame.height), color: addTaskButton.backgroundColor!)
        
        contentView.addSubview(undoButton!)
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: { [self] in
            undoButton!.frame.origin.x = padding
        })
    }
    
    @objc func HideUndoButton () {
        if undoButton == nil { return }
        
        lastTaskUndoTimer?.invalidate()
        App.instance.lastDeletedTask = nil
        App.instance.lastCompletedTask = nil
        App.instance.undoTaskIndexPath = nil
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: { [self] in
            undoButton!.frame.origin.x = -undoButton!.frame.width - 10
        }, completion: { [self] _ in
            if undoButton != nil { undoButton!.removeFromSuperview() }
            undoButton = nil
        })
    }
    
    @objc func TouchedTable (sender: UITapGestureRecognizer) {
        sender.cancelsTouchesInView = false
        
        currentSliderEditing?.StopEditing()
        currentSliderEditing = nil
    }
    
    func SetThemeColors() {
        UIView.animate(withDuration: 0.25) { [self] in
            colorPanelHeader.backgroundColor = AppColors.tasklistHeaderColor(taskList: taskLists[0])
            colorPanelHeader.layer.compositingFilter = UITraitCollection.current.userInterfaceStyle == .light ? "multiplyBlendMode" : "screenBlendMode"
            colorPanelHeader.layer.opacity = UITraitCollection.current.userInterfaceStyle == .light ? 1 : 0.8
        }
    }
    
    var sortButtonMenu: UIMenu {
        
        let unsorted = UIAction(title: "Unsorted", image: UIImage(systemName: "xmark.app"), state: getSortItemState(sortingPreference: .Unsorted)) { [self] _ in
            SortUpcomingTasks(sortPreference: .Unsorted)
        }
        let list = UIAction(title: "By list", image: UIImage(systemName: "equal.square"), state: getSortItemState(sortingPreference: .ByList)) { [self] _ in
            SortUpcomingTasks(sortPreference: .ByList)
        }
        let timeCreated = UIAction(title: "By time created", image: UIImage(systemName: "arrow.uturn.left.square"), state: getSortItemState(sortingPreference: .ByTimeCreated)) { [self] _ in
            SortUpcomingTasks(sortPreference: .ByTimeCreated)
        }
        let timeDue = UIAction(title: "By time due", image: UIImage(systemName: "timer.square"), state: getSortItemState(sortingPreference: .ByTimeDue)) { [self] _ in
            SortUpcomingTasks(sortPreference: .ByTimeDue)
        }
        let priority = UIAction(title: "By priority", image: UIImage(systemName: "exclamationmark.square"), state: getSortItemState(sortingPreference: .ByPriority)) { [self] _ in
            SortUpcomingTasks(sortPreference: .ByPriority)
        }
        let name = UIAction(title: "By name", image: UIImage(systemName: "square.text.square"), state: getSortItemState(sortingPreference: .ByName)) { [self] _ in
            SortUpcomingTasks(sortPreference: .ByName)
        }
        
        let defaultAction = UIMenu(title: "", options: .displayInline, children: [App.selectedTaskListIndex == 0 ? list : unsorted])
        return UIMenu(title: "", children: [defaultAction, timeCreated, timeDue, priority, name])
    }
    
    func getSortItemState (sortingPreference: SortingPreference) -> UIMenuElement.State {
        if App.selectedTaskListIndex == 0 { return sortingPreference == App.instance.overviewSortingPreference ? .on : .off }
        return sortingPreference == taskLists[0].sortingPreference ? .on : .off
    }
    
    func SortUpcomingTasks(sortPreference: SortingPreference, animated: Bool = true) {
        if App.selectedTaskListIndex == 0 {
            App.instance.overviewSortingPreference = sortPreference
        } else {
            taskLists[0].sortingPreference = sortPreference
        }
        sortButton.menu = sortButtonMenu
        
        var beforeSort = [Task]()
        if animated {
            beforeSort.append(contentsOf: allUpcomingTasks)
        }
        
        if App.selectedTaskListIndex == 0 {
            allUpcomingTasks = allUpcomingTasks.sorted { sortBool(task1: $0, task2: $1, sortingPreference: sortPreference) }
        } else if App.selectedTaskListIndex == 1 {
            App.mainTaskList.upcomingTasks = App.mainTaskList.upcomingTasks.sorted { sortBool(task1: $0, task2: $1, sortingPreference: sortPreference) }
        } else {
            App.userTaskLists[App.selectedTaskListIndex-2].upcomingTasks = App.userTaskLists[App.selectedTaskListIndex-2].upcomingTasks.sorted { sortBool(task1: $0, task2: $1, sortingPreference: sortPreference) }
        }
        
        if App.selectedTaskListIndex != 0 {
            taskLists = App.selectedTaskListIndex == 1 ? [App.mainTaskList] : [App.userTaskLists[App.selectedTaskListIndex-2]]
            ReloadTaskData()
        }
        
        if animated {
            tableView.performBatchUpdates({
                for i in 0..<allUpcomingTasks.count {
                    let newRow = allUpcomingTasks.firstIndex(of: beforeSort[i])!
                    tableView.moveRow(at: IndexPath(row: i, section: 0), to: IndexPath(row: newRow, section: 0))
                }
            })
        } else {
            if tableView?.window != nil { tableView.reloadData() }
        }
        
        if tableView.cellForRow(at: IndexPath(row: 0, section: 0)) != nil {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: false)
        }
    }
    
    func MoveTaskToRightSortedIndexPath (originalIndexPath: IndexPath, task: Task) {
        let sortPreference: SortingPreference
        if App.selectedTaskListIndex == 0 {
            sortPreference = App.instance.overviewSortingPreference
        } else {
            sortPreference = taskLists[0].sortingPreference
        }
        
        var dummyArray = [Task]()
        dummyArray.append(contentsOf: allUpcomingTasks)
        
        dummyArray = dummyArray.sorted { sortBool(task1: $0, task2: $1, sortingPreference: sortPreference) }
        
        let newIndexPath = IndexPath(row: dummyArray.firstIndex(of: task)!, section: 0)
        
        if originalIndexPath == newIndexPath { return }
        
        tableView.moveRow(at: originalIndexPath, to: newIndexPath)
        allUpcomingTasks.remove(at: originalIndexPath.row)
        allUpcomingTasks.insert(task, at: newIndexPath.row)
        if App.selectedTaskListIndex == 1 {
            App.mainTaskList.upcomingTasks.remove(at: originalIndexPath.row)
            App.mainTaskList.upcomingTasks.insert(task, at: newIndexPath.row)
        } else if App.selectedTaskListIndex != 0 {
            App.userTaskLists[App.selectedTaskListIndex-2].upcomingTasks.remove(at: originalIndexPath.row)
            App.userTaskLists[App.selectedTaskListIndex-2].upcomingTasks.insert(task, at: newIndexPath.row)
        }
        
        if allUpcomingTasks.count > 0 { tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: false) }
    }
    
    func sortBool(task1: Task, task2: Task, sortingPreference: SortingPreference) -> Bool {
        switch sortingPreference {
            case .Unsorted:
                return false
            case .ByList:
                return getListPosition(listID: task1.taskListID) < getListPosition(listID: task2.taskListID)
            case .ByTimeCreated:
                return task1.dateCreated > task2.dateCreated
            case .ByTimeDue:
                if task1.isDateAssigned && task2.isDateAssigned {
                    return task1.dateAssigned < task2.dateAssigned
                }
                return task1.isDateAssigned
            case .ByPriority:
                if task1.priority.rawValue == task2.priority.rawValue {
                    return sortBool(task1: task1, task2: task2, sortingPreference: .ByTimeDue)
                }
                return task1.priority.rawValue > task2.priority.rawValue
            case .ByName:
                return task1.name < task2.name
        }
    }
    
    
    func getListPosition (listID: UUID) -> Int {
        if listID == App.mainTaskList.id { return 0 }
        for i in 0..<App.userTaskLists.count {
            if App.userTaskLists[i].id == listID { return i }
        }
        return -1
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
