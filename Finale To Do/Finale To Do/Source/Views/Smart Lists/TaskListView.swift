//
//  HomeView.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/14/22.
//

import UIKit
import SwiftUI

class TaskListView: UIView, UITableViewDataSource, UITableViewDelegate, UITableViewDragDelegate, UITableViewDropDelegate, UIDynamicTheme, UIGestureRecognizerDelegate {

    let app: App
    
    let padding = 16.0
    let sliderHeight = 36.0
    
    var contentView: UIView!
    var blurEffect: UIVisualEffectView!
    var colorPanelHeader: UIView!
    var headerGradientLayer: CAGradientLayer!
    var hamburgerButton: UIButton!
    var sortButton: UIButton?
    var titleLabel: UILabel!
    var tableView: UITableView!
    var placeholderView: UIView?
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
    
    var taskMovedToTopOriginalIndex: Int?
    
    init(frame: CGRect, taskLists: [TaskList], app: App) {
        self.app = app
        self.taskLists = taskLists
        
        super.init(frame: frame)
        
        self.backgroundColor = .systemBackground
        
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
        headerGradientLayer = CAGradientLayer()
        headerGradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        headerGradientLayer.endPoint = CGPoint(x: 1.3, y: -0.3)
        headerGradientLayer.frame = colorPanelHeader.bounds
        colorPanelHeader.layer.insertSublayer(headerGradientLayer, at:0)
        SetHeaderGradient(color: App.selectedTaskListIndex < App.settingsConfig.smartLists.count ? .clear : taskLists[0].primaryColor)
        colorPanelHeader.layer.compositingFilter = ThemeManager.currentTheme.interface == .Light ? "multiplyBlendMode" : "screenBlendMode"
        colorPanelHeader.layer.opacity = ThemeManager.currentTheme.interface == .Light ? 1 : 0.8
        header.addSubview(colorPanelHeader)
        
        
        let hamburgerButtonSize = frame.width * 0.1
        hamburgerButton = UIButton(frame: CGRect(x: padding, y: frame.height*0.4, width: hamburgerButtonSize, height: hamburgerButtonSize))
        hamburgerButton.tintColor = headerElementsColor
        hamburgerButton.setImage(UIImage(systemName: "line.3.horizontal"), for: .normal)
        hamburgerButton.imageView?.contentMode = .scaleAspectFit
        hamburgerButton.contentVerticalAlignment = .fill
        hamburgerButton.contentHorizontalAlignment = .fill
        hamburgerButton.addTarget(self, action: #selector(ToggleSideMenu), for: .touchUpInside)
        
        header.addSubview(hamburgerButton)
        
        AddSortButton()
        if sortButton != nil { header.addSubview(sortButton!) }
        
        let titleHeight = header.frame.height*0.3
        let titleWidth = header.frame.width-padding*2
        titleLabel = UILabel(frame: CGRect(x: padding - titleWidth*0.5, y: hamburgerButton.frame.maxY + padding*0.45 + titleHeight*0.5, width: titleWidth, height: titleHeight))
        titleLabel.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        titleLabel.text = headerTitle
        titleLabel.textColor = headerElementsColor
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.layer.anchorPoint = CGPoint(x: 0, y: 1)
        originalTitlePositionY = titleLabel.frame.origin.y
        
        header.addSubview(titleLabel)
        
        addSubview(header)
        
        originalTableContentOffsetY = tableView.contentOffset.y
    }
    
    func AddSortButton () {
        let sortButtonSize = frame.width * 0.1
        sortButton = UIButton(frame: CGRect(x: frame.width-sortButtonSize-padding, y: hamburgerButton.frame.origin.y, width: sortButtonSize, height: sortButtonSize))
        sortButton?.tintColor = headerElementsColor
        sortButton?.setImage(UIImage(systemName: "arrow.up.arrow.down", withConfiguration: UIImage.SymbolConfiguration.init(weight: .semibold)), for: .normal)
        sortButton?.contentVerticalAlignment = .fill
        sortButton?.contentHorizontalAlignment = .fill
        sortButton?.imageEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 0)
        sortButton?.imageView?.contentMode = .scaleAspectFit
        sortButton?.contentHorizontalAlignment = .right
        sortButton?.showsMenuAsPrimaryAction = true
        sortButton?.menu = sortButtonMenu
        sortButton?.addAction(UIAction {_ in
            App.instance.StopEditingAllTasks()
        }, for: .menuActionTriggered)
    }
    
    func DrawContent(frame: CGRect) {
        contentView?.removeFromSuperview()
        contentView = UIView(frame: frame)
        contentView.backgroundColor = ThemeManager.currentTheme.tasklistBackgroundColor
        
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
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .clear
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: UIScreen.main.bounds.height*0.45))
        footerView.backgroundColor = .clear
        tableView.tableFooterView = footerView
        
        contentView.addSubview(tableView)
        
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(DragGesture))
        dragGesture.minimumNumberOfTouches = 1
        dragGesture.delegate = self
        contentView.addGestureRecognizer(dragGesture)
        
        let addTaskButtonSize = 56.0
        originalAddTaskPositionY = frame.height-addTaskButtonSize-padding*3
        addTaskButton = AddTaskButton(frame: CGRect(x: frame.width-addTaskButtonSize-padding, y: originalAddTaskPositionY, width: addTaskButtonSize, height: addTaskButtonSize), tasklistColor: App.selectedTaskListIndex < App.settingsConfig.smartLists.count ? .defaultColor : taskLists[0].primaryColor, app: app)
        
        contentView.addSubview(addTaskButton)
        
        addSubview(contentView)
    }
    
    func SetHeaderGradient(color: UIColor) {
        let firstColor = ThemeManager.currentTheme.tasklistHeaderColor(tasklistColor: color)
        let secondColor = ThemeManager.currentTheme.tasklistHeaderGradientSecondaryColor(tasklistColor: color)
        headerGradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
        
    }
    
    var headerElementsColor: UIColor {
        if App.selectedTaskListIndex >= App.settingsConfig.smartLists.count { return ThemeManager.currentTheme.tasklistHeaderElementsColor }
        
        if ThemeManager.currentTheme.usesDynamicColors { return .label }
        else { return ThemeManager.currentTheme.tasklistHeaderElementsColor }
    }
    
    var headerTitle: String {
        if App.selectedTaskListIndex < App.settingsConfig.smartLists.count {
            return App.settingsConfig.smartLists[App.selectedTaskListIndex].taskListHeaderTitle
        } else {
            return taskLists[0].name
        }
    }
    
    func OpenTaskDetailsView (slider: TaskSlider) {
        App.instance.present(TaskSliderContextMenu(slider: slider, fullscreen: true), animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        TogglePlaceholder()
        return section == 0 ? allUpcomingTasks.count : App.settingsConfig.hideCompletedTasks ? min(App.settingsConfig.maxTasksIfCompletedTasksHidden, allCompletedTasks.count) : allCompletedTasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskSliderTableCell
        
        let task = indexPath.section == 0 ? allUpcomingTasks[indexPath.row] : allCompletedTasks[indexPath.row]
        cell.Setup(
            task: task,
            sliderSize: CGSize(width: tableView.frame.width-padding*2, height: tableView.rowHeight-padding*0.5),
            cellSize: CGSize(width: tableView.frame.width, height: tableView.rowHeight),
            taskListColor: getTaskListColor(id: task.taskListID), app: app)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if app.isSideMenuOpen { return nil }
        
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: {  
            let cell = tableView.cellForRow(at: indexPath) as! TaskSliderTableCell
            return TaskSliderContextMenu(slider: cell.slider)
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
                self.OpenTaskDetailsView(slider: cell.slider)
            }
            let AssignDate = UIAction(title: cell.slider.task.isDateAssigned ? "Change Date" : "Assign Date", image: UIImage(systemName: "calendar")) { action in
                cell.slider.ShowCalendarView(taskSliderContextMenu: nil)
            }
            let skipRepeating = UIAction(title: "Skip", image: UIImage(systemName: "arrow.right")) { action in
                self.app.SkipRepeatingTask(task: cell.slider.task)
            }
            
            var items = [UIAction]()
            if cell.slider.task.isCompleted {
                items.append(Undo)
            } else {
                if cell.slider.task.repeating.count > 0 && cell.slider.task.isDateAssigned && !cell.slider.task.isCompleted { items.append(skipRepeating) }
                items.append(AssignDate)
                items.append(Edit)
            }
            
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let cell = tableView.cellForRow(at: indexPath) as! TaskSliderTableCell

        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion) in
            self.OpenTaskDetailsView(slider: cell.slider)
            completion(true)
        }
        
        let undoAction = UIContextualAction(style: .normal, title: "Undo") { (action, view, completion) in
            self.app.UndoCompletingTask(task: cell.slider.task)
            completion(true)
        }

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            self.app.DeleteTask(task: cell.slider.task)
            completion(true)
        }

        return UISwipeActionsConfiguration(actions: [deleteAction, cell.slider.task.isCompleted ? undoAction : editAction])
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
        if sourceIndexPath.section == 1 || App.selectedTaskListIndex < App.settingsConfig.smartLists.count { return sourceIndexPath }
        if proposedDestinationIndexPath.section == 0 { return proposedDestinationIndexPath }
        else { return IndexPath(row: allUpcomingTasks.count-1, section: 0) }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath.section == 1 || App.selectedTaskListIndex < App.settingsConfig.smartLists.count { return }
        
        let mover = allUpcomingTasks.remove(at: sourceIndexPath.row)
        allUpcomingTasks.insert(mover, at: destinationIndexPath.row)
        if App.selectedTaskListIndex < App.settingsConfig.smartLists.count {
            // do nothing
        } else if App.selectedTaskListIndex == App.settingsConfig.smartLists.count {
            App.mainTaskList.upcomingTasks.remove(at: sourceIndexPath.row)
            App.mainTaskList.upcomingTasks.insert(mover, at: destinationIndexPath.row)
            App.mainTaskList.sortingPreference = .Unsorted
        } else {
            App.userTaskLists[App.selectedTaskListIndex-App.settingsConfig.smartLists.count-1].upcomingTasks.remove(at: sourceIndexPath.row)
            App.userTaskLists[App.selectedTaskListIndex-App.settingsConfig.smartLists.count-1].upcomingTasks.insert(mover, at: destinationIndexPath.row)
            App.userTaskLists[App.selectedTaskListIndex-App.settingsConfig.smartLists.count-1].sortingPreference = .Unsorted
        }
        sortButton?.menu = sortButtonMenu
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
        CATransaction.setValue(kCFBooleanTrue, forKey:kCATransactionDisableActions)
        colorPanelHeader.layer.sublayers?[0].frame.size.height = originalHeaderHeight + scrollDelta
        CATransaction.commit()
        
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
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translation(in: superview!)
            return app.isSideMenuOpen ? translation.x <= 0 : translation.x >= 0
        }
        return false
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
            if App.selectedTaskListIndex >= App.settingsConfig.smartLists.count || App.settingsConfig.listsShownInSmartLists.count == 0 || App.settingsConfig.listsShownInSmartLists.contains(taskList.id) {
                allUpcomingTasks.append(contentsOf: taskList.upcomingTasks)
                allCompletedTasks.append(contentsOf: taskList.completedTasks)
            }
        }
        allCompletedTasks = allCompletedTasks.sorted { $0.dateCompleted > $1.dateCompleted }
        if App.selectedTaskListIndex < App.settingsConfig.smartLists.count && sortOverviewList { SortUpcomingTasks(sortPreference: App.instance.overviewSortingPreference, animated: false) }
    }
    
    func ReloadView () {
        ReloadTaskData()
        tableView.reloadData()
        DispatchQueue.main.async { [self] in
            tableView.setContentOffset(CGPoint(x: 0, y: tableView.frame.minY), animated: false)
            originalTableContentOffsetY = tableView.contentOffset.y
        }
        titleLabel.text = headerTitle
        titleLabel.textColor = headerElementsColor
        hamburgerButton.tintColor = headerElementsColor
        sortButton?.tintColor = headerElementsColor
        sortButton?.menu = sortButtonMenu
        contentView.backgroundColor = ThemeManager.currentTheme.tasklistBackgroundColor
        SetHeaderGradient(color: App.selectedTaskListIndex < App.settingsConfig.smartLists.count ? .clear : taskLists[0].primaryColor)
        colorPanelHeader.layer.compositingFilter = ThemeManager.currentTheme.interface == .Light ? "multiplyBlendMode" : "screenBlendMode"
        colorPanelHeader.layer.opacity = ThemeManager.currentTheme.interface == .Light ? 1 : 0.8
        addTaskButton.ReloadVisuals(color: App.selectedTaskListIndex < App.settingsConfig.smartLists.count ? .defaultColor : taskLists[0].primaryColor)
        if undoButton != nil {
            undoButton!.removeFromSuperview()
            undoButton = nil
        }
    }
    
    @objc func KeyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) { [self] in
                let y = contentView.frame.height - keyboardHeight - addTaskButton.frame.height - padding
                addTaskButton.frame.origin.y = y
            }
            if currentSliderEditing != nil {
                let sliderMaxY = currentSliderEditing!.superview!.convert(currentSliderEditing!.frame, to: nil).maxY
                let threasholdY = addTaskButton.superview!.convert(addTaskButton.frame, to: nil).origin.y - padding
                if sliderMaxY > threasholdY {
                    DispatchQueue.main.async { [self] in
                        tableView.setContentOffset(CGPoint(x: 0, y: tableView.contentOffset.y + (sliderMaxY-threasholdY) ), animated: true)
                    }
                }
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
        
        undoButton = UndoButton(frame: CGRect(x: -addTaskButton.frame.width - 10, y: addTaskButton.frame.origin.y, width: addTaskButton.frame.width, height: addTaskButton.frame.height), tasklistColor: addTaskButton.backgroundColor!)
        
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
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: { [self] in
            undoButton!.frame.origin.x = -undoButton!.frame.width - 10
        }, completion: { [self] _ in
            if undoButton != nil { undoButton!.removeFromSuperview() }
            undoButton = nil
        })
    }
    
    @objc func TouchedTable (sender: UITapGestureRecognizer) {
        sender.cancelsTouchesInView = false
        
        currentSliderEditing?.StopEditing(putInRightPlace: true)
        currentSliderEditing = nil
    }
    
    func ReloadThemeColors() {
        UIView.animate(withDuration: 0.25) { [self] in
            colorPanelHeader.layer.compositingFilter = ThemeManager.currentTheme.interface == .Light ? "multiplyBlendMode" : "screenBlendMode"
            colorPanelHeader.layer.opacity = ThemeManager.currentTheme.interface == .Light ? 1 : 0.8
            SetHeaderGradient(color: App.selectedTaskListIndex < App.settingsConfig.smartLists.count ? .clear : taskLists[0].primaryColor)
            titleLabel.textColor = headerElementsColor
            hamburgerButton.tintColor = headerElementsColor
            sortButton?.tintColor = headerElementsColor
            contentView.backgroundColor = ThemeManager.currentTheme.tasklistBackgroundColor
        }
    }
    
    func UpdateAllDateLabels () {
        let allCells = tableView.visibleCells as! [TaskSliderTableCell]
        
        for cell in allCells {
            cell.slider.UpdateDateLabel()
        }
    }
    
    var sortButtonMenu: UIMenu {
        
        let unsorted = UIAction(title: "Unsorted", image: UIImage(systemName: "xmark.app"), state: getSortItemState(sortingPreference: .Unsorted)) { [self] _ in
            SortUpcomingTasks(sortPreference: .Unsorted)
        }
        let list = UIAction(title: "By list", image: UIImage(systemName: "square.text.square"), state: getSortItemState(sortingPreference: .ByList)) { [self] _ in
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
        let name = UIAction(title: "By name", image: UIImage(systemName: "equal.square"), state: getSortItemState(sortingPreference: .ByName)) { [self] _ in
            SortUpcomingTasks(sortPreference: .ByName)
        }
        
        let defaultAction = UIMenu(title: "", options: .displayInline, children: [App.selectedTaskListIndex < App.settingsConfig.smartLists.count ? list : unsorted])
        return UIMenu(title: "", children: [defaultAction, timeCreated, timeDue, priority, name])
    }
    
    func getSortItemState (sortingPreference: SortingPreference) -> UIMenuElement.State {
        if App.selectedTaskListIndex < App.settingsConfig.smartLists.count { return sortingPreference == App.instance.overviewSortingPreference ? .on : .off }
        return sortingPreference == taskLists[0].sortingPreference ? .on : .off
    }
    
    func SortUpcomingTasks(sortPreference: SortingPreference, animated: Bool = true) {
        if App.selectedTaskListIndex < App.settingsConfig.smartLists.count {
            App.instance.overviewSortingPreference = sortPreference
        } else {
            taskLists[0].sortingPreference = sortPreference
        }
        sortButton?.menu = sortButtonMenu
        
        var beforeSort = [Task]()
        if animated {
            beforeSort.append(contentsOf: allUpcomingTasks)
        }
        
        if App.selectedTaskListIndex < App.settingsConfig.smartLists.count {
            allUpcomingTasks = allUpcomingTasks.sorted { sortBool(task1: $0, task2: $1, sortingPreference: sortPreference) }
        } else if App.selectedTaskListIndex == App.settingsConfig.smartLists.count {
            App.mainTaskList.upcomingTasks = App.mainTaskList.upcomingTasks.sorted { sortBool(task1: $0, task2: $1, sortingPreference: sortPreference) }
        } else {
            App.userTaskLists[App.selectedTaskListIndex-App.settingsConfig.smartLists.count-1].upcomingTasks = App.userTaskLists[App.selectedTaskListIndex-App.settingsConfig.smartLists.count-1].upcomingTasks.sorted { sortBool(task1: $0, task2: $1, sortingPreference: sortPreference) }
        }
        
        if App.selectedTaskListIndex > App.settingsConfig.smartLists.count {
            taskLists = App.selectedTaskListIndex == App.settingsConfig.smartLists.count ? [App.mainTaskList] : [App.userTaskLists[App.selectedTaskListIndex-App.settingsConfig.smartLists.count-1]]
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
//            if tableView?.window != nil { tableView.reloadData() }
        }
        
        if tableView.cellForRow(at: IndexPath(row: 0, section: 0)) != nil {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: false)
        }
    }
    
    func MoveTaskToRightSortedIndexPath (task: Task, moveRow: Bool = true) {
        let newIndexPath = GetSortedIndexPath(task: task)
        let originalIndexPath = IndexPath(row: task.isCompleted ? App.instance.taskListView.allCompletedTasks.firstIndex(of: task)! : App.instance.taskListView.allUpcomingTasks.firstIndex(of: task)!, section: task.isCompleted ? 1 : 0)
        if originalIndexPath == newIndexPath { return }
        
        if moveRow { tableView.moveRow(at: originalIndexPath, to: newIndexPath) }
        allUpcomingTasks.remove(at: originalIndexPath.row)
        allUpcomingTasks.insert(task, at: newIndexPath.row)
        if App.selectedTaskListIndex == App.settingsConfig.smartLists.count {
            App.mainTaskList.upcomingTasks.remove(at: originalIndexPath.row)
            App.mainTaskList.upcomingTasks.insert(task, at: newIndexPath.row)
        } else if App.selectedTaskListIndex > App.settingsConfig.smartLists.count {
            App.userTaskLists[App.selectedTaskListIndex-App.settingsConfig.smartLists.count-1].upcomingTasks.remove(at: originalIndexPath.row)
            App.userTaskLists[App.selectedTaskListIndex-App.settingsConfig.smartLists.count-1].upcomingTasks.insert(task, at: newIndexPath.row)
        }
        
        if allUpcomingTasks.count > 0 { tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: false) }
    }
    
    func GetSortedIndexPath (task: Task) -> IndexPath {
        let sortPreference: SortingPreference
        if App.selectedTaskListIndex < App.settingsConfig.smartLists.count { //This needs to be fixed to only be true when 'Overview' is selected
            sortPreference = App.instance.overviewSortingPreference
        } else {
            sortPreference = taskLists[0].sortingPreference
        }
        
        var dummyArray = [Task]()
        dummyArray.append(contentsOf: allUpcomingTasks)
        if !dummyArray.contains(task) { dummyArray.append(task) }
        
        dummyArray = dummyArray.sorted { sortBool(task1: $0, task2: $1, sortingPreference: sortPreference) }
        
        return IndexPath(row: dummyArray.firstIndex(of: task)!, section: 0)
    }
    func GetSortedArrayIndex (task: Task) -> Int {
        var sortPreference = SortingPreference.Unsorted
        
        var dummyArray = [Task]()
        if task.taskListID == App.mainTaskList.id {
            dummyArray.append(contentsOf: !task.isCompleted ? App.mainTaskList.upcomingTasks : App.mainTaskList.completedTasks)
            sortPreference = App.mainTaskList.sortingPreference
        } else {
            for taskList in App.userTaskLists {
                if taskList.id == task.taskListID {
                    dummyArray.append(contentsOf: !task.isCompleted ? taskList.upcomingTasks : taskList.completedTasks)
                    sortPreference = taskList.sortingPreference
                    break
                }
            }
        }
        
        if !dummyArray.contains(task) { dummyArray.append(task) }
        
        dummyArray = dummyArray.sorted { sortBool(task1: $0, task2: $1, sortingPreference: sortPreference) }
        
        return dummyArray.firstIndex(of: task)!
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
                if task1.dateAssigned == task2.dateAssigned {
                    return sortBool(task1: task1, task2: task2, sortingPreference: .ByList)
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
            if App.userTaskLists[i].id == listID { return i+1 }
        }
        return -1
    }
    
    func TogglePlaceholder () {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            if shouldShowPlaceholder {
                placeholderView?.removeFromSuperview()
                placeholderView = DrawPlaceholder()
                contentView.addSubview(placeholderView!)
                placeholderView?.alpha = 0
                UIView.animate(withDuration: 0.25) { [self] in
                    tableView.alpha = 0
                    placeholderView?.alpha = 1
                }
            } else {
                if tableView.alpha == 1 { return }
                
                UIView.animate(withDuration: 0.25) { [self] in
                    tableView.alpha = 1
                    placeholderView?.alpha = 0
                }
            }
        }
    }
    
    var shouldShowPlaceholder: Bool {
        return allUpcomingTasks.count == 0 && allCompletedTasks.count == 0
    }
    
    func DrawPlaceholder () -> UIView {
        let container = UIView(frame: CGRect(x: 0, y: contentView.frame.height*0.15, width: contentView.frame.width, height: contentView.frame.height*0.4))
        
        let icon = ClipboardIcon(position: CGPoint(x: container.center.x, y: container.frame.height*0.3), color: App.selectedTaskListIndex < App.settingsConfig.smartLists.count ? .defaultColor : taskLists[0].primaryColor)
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: icon.frame.maxY+padding, width: container.frame.width, height: 20))
        titleLabel.text = placeholderTitle
        titleLabel.textAlignment = .center
        
        let subtitleLabel = UILabel(frame: CGRect(x: 0.5*(container.frame.width-titleLabel.frame.width*0.7), y: titleLabel.frame.maxY+padding, width: titleLabel.frame.width*0.7, height: 40))
        subtitleLabel.text = placeholderSubtitle
        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        subtitleLabel.textColor = .systemGray
        subtitleLabel.numberOfLines = 2
        subtitleLabel.textAlignment = .center
        subtitleLabel.adjustsFontSizeToFitWidth = true
        
        container.addSubview(icon)
        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)
        
        return container
    }
    
    var placeholderTitle: String {
        return "You don't have any tasks here yet."
    }
    var placeholderSubtitle: String {
        return "Relax and enjoy. When you are ready, press + to add new tasks."
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class ClipboardIcon: UIView, UIDynamicTheme {
    
    var board: UIView!
    var paper: UIView!
    var verticalLine: UIView!
    var horizontalLine: UIView!
    var clipper: UIView!
    var clipperCircle: UIView!
    var clipperCircleInside: UIView!
    
    var color: UIColor!
    
    init(position: CGPoint, width: CGFloat = 90, color: UIColor) {
        let padding = 6.0
        let height = width*1.4
        self.color = color
        super.init(frame: CGRect(x: position.x-0.5*width, y: position.y-0.5*width, width: width, height: height))
        
        let backgroundSize = height * 0.85
        let background = UIView(frame: CGRect(x: 0.5*(width-backgroundSize), y: 0.5*(height-backgroundSize), width: backgroundSize, height: backgroundSize))
        background.layer.cornerRadius = backgroundSize*0.5
        background.backgroundColor = .systemGray6
        
        let boardWidth = width-padding*2.0
        let boardHeight = boardWidth*1.2941
        board = UIView(frame: CGRect(x: padding, y: padding, width: boardWidth, height: boardHeight))
        board.layer.cornerRadius = width*0.1
        
        let paperIndent = board.frame.width*0.1
        paper = UIView(frame: CGRect(x: paperIndent, y: paperIndent, width: boardWidth-paperIndent*2, height: boardHeight-paperIndent*2))
        paper.backgroundColor = .systemGray5
        paper.layer.cornerRadius = width*0.06
        paper.layer.shadowOffset = CGSize.zero
        paper.layer.shadowRadius = width*0.02
        paper.layer.shadowOpacity = 0.5
        
        let lineWidth = paper.frame.width*0.04
        let lineHeight = paper.frame.width*0.3
        verticalLine = UIView(frame: CGRect(x: 0.5*(paper.frame.width-lineWidth), y: 0.5*(paper.frame.height-lineHeight), width: lineWidth, height: lineHeight))
        verticalLine.layer.cornerRadius = lineWidth*0.5
        
        horizontalLine = UIView(frame: CGRect(x: 0.5*(paper.frame.width-lineHeight), y: 0.5*(paper.frame.height-lineWidth), width: lineHeight, height: lineWidth))
        horizontalLine.layer.cornerRadius = lineWidth*0.5
        
        paper.addSubview(horizontalLine)
        paper.addSubview(verticalLine)
        
        let cliperWidth = boardWidth*0.5
        let clipperHeight = boardHeight*0.2
        clipper = UIView(frame: CGRect(x: 0.5*(boardWidth-cliperWidth), y: -clipperHeight*0.25, width: cliperWidth, height: clipperHeight))
        clipper.layer.cornerRadius = 5
        clipper.layer.shadowOffset = CGSize(width: 0, height: cliperWidth*0.02)
        clipper.layer.shadowRadius = width*0.02
        clipper.layer.shadowOpacity = 0.3
        
        let clipperCircleSize = cliperWidth*0.5
        clipperCircle = UIView(frame: CGRect(x: 0.5*(cliperWidth-clipperCircleSize), y: -clipperCircleSize*0.5, width: clipperCircleSize, height: clipperCircleSize))
        clipperCircle.layer.cornerRadius = clipperCircleSize*0.5
        
        let insideCircleSize = clipperCircleSize*0.45
        clipperCircleInside = UIView(frame: CGRect(x: 0.5*(clipperCircleSize-insideCircleSize), y: 0.5*(clipperCircleSize-insideCircleSize), width: insideCircleSize, height: insideCircleSize))
        clipperCircleInside.backgroundColor = .systemBackground
        clipperCircleInside.layer.cornerRadius = clipperCircleInside.frame.width*0.5
        
        clipperCircle.addSubview(clipperCircleInside)
        
        board.frame.origin.y = 0.5*(height-(board.frame.height+clipperCircle.frame.height)) + clipperCircle.frame.height*0.85
        background.center = board.center
        
        self.addSubview(background)
        self.addSubview(board)
        board.addSubview(paper)
        board.addSubview(clipper)
        clipper.addSubview(clipperCircle)
        
        ChangeColor(color: color)
    }
    
    func ChangeColor(color: UIColor) {
        board.backgroundColor = ThemeManager.currentTheme.interface == .Light ? ThemeManager.currentTheme.primaryElementColor(tasklistColor: color).light : ThemeManager.currentTheme.primaryElementColor(tasklistColor: color).dark
        verticalLine.backgroundColor = ThemeManager.currentTheme.primaryElementColor(tasklistColor: color)
        horizontalLine.backgroundColor = ThemeManager.currentTheme.primaryElementColor(tasklistColor: color)
        clipper.backgroundColor = ThemeManager.currentTheme.primaryElementColor(tasklistColor: color)
        clipperCircle.backgroundColor = ThemeManager.currentTheme.primaryElementColor(tasklistColor: color)
    }
    
    func ReloadThemeColors() {
        UIView.animate(withDuration: 0.25) { [self] in
            ChangeColor(color: color)
            clipperCircleInside.backgroundColor = .systemBackground
            paper.backgroundColor = .systemGray6
        }
    }
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
