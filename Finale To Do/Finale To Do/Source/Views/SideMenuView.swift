//
//  SideMenuView.swift
//  Finale To-do
//
//  Created by Grant Oganyan on 4/15/22.
//

import Foundation
import UIKit

class SideMenuView: UIView, UITableViewDataSource, UITableViewDelegate, UITableViewDragDelegate, UITableViewDropDelegate, UIDynamicTheme {
    
    let app: App
    
    let padding = 32.0
    let menuItemHeight = 50.0
    
    let tableView: UITableView
    var userPanel: UserPanel!
    var smartListsItems = [TaskListMenuItem]()
    var listsLabel: UILabel!
    
    var currentContextMenuView: TaskListMenuItem?
    
    var selectedTaskListID: UUID?
    
    init(frame: CGRect, app: App) {
        self.app = app
        
        tableView = UITableView()
        super.init(frame: frame)
        
        self.backgroundColor = ThemeManager.currentTheme.sidemenuBackgroundColor
        
        let userPanelHeight = (frame.width-padding)*0.1+padding-2 //55.0
        userPanel = UserPanel(frame: CGRect(x: padding*0.5, y: frame.height*0.2-userPanelHeight, width: frame.width-padding, height: userPanelHeight))
        
        self.addSubview(userPanel)
        
        listsLabel = UILabel(frame: CGRect(x: padding, y: 0, width: frame.width-padding*2, height: menuItemHeight))
        listsLabel.text = "Lists"
        listsLabel.font = .preferredFont(forTextStyle: .headline)
        listsLabel.textColor = .white
        
        DrawSmartLists()
        
        self.addSubview(listsLabel)
        
        tableView.frame = CGRect(x: padding*0.5, y: listsLabel.frame.maxY, width: frame.width-padding, height: frame.height*0.87-listsLabel.frame.maxY)
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
        addListButton.setTitle("Create List", for: .normal)
        addListButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addListButton.setTitleColor(.gray, for: .highlighted)
        addListButton.tintColor = .white
        addListButton.contentHorizontalAlignment = .leading
        addListButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
        addListButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        addListButton.addTarget(self, action: #selector(OpenAddTaskListView), for: .touchUpInside)
        
        self.addSubview(addListButton)
        
        let settingsButtonSize = 50.0
        let settingsButton = UIButton(frame: CGRect(x: frame.width-padding-settingsButtonSize, y: addListButton.frame.origin.y + 0.5*(addListButton.frame.height-settingsButtonSize), width: settingsButtonSize, height: settingsButtonSize))
        settingsButton.setImage(UIImage(systemName: "gearshape"), for: .normal)
        settingsButton.tintColor = .white
        settingsButton.addTarget(self, action: #selector(OpenSettings), for: .touchUpInside)
        settingsButton.contentHorizontalAlignment = .right
        
        self.addSubview(settingsButton)
        
    }
    
    func DrawSmartLists () {
        for smartList in smartListsItems { smartList.removeFromSuperview() }
        smartListsItems.removeAll()
        
        for i in 0..<App.settingsConfig.smartLists.count {
            let menuItem = TaskListMenuItem(
                frame: CGRect(x: padding*0.5, y: Double(i)*menuItemHeight + userPanel.frame.maxY+padding*0.5, width: frame.width-padding, height: menuItemHeight),
                taskList: TaskList(name: App.settingsConfig.smartLists[i].title, primaryColor: .defaultColor, systemIcon: App.settingsConfig.smartLists[i].icon),
                index: i,
                taskCountNumber: App.settingsConfig.smartLists[i].taskCountNumber)
            smartListsItems.append(menuItem)
            self.addSubview(menuItem)
        }
        
        let maxY = smartListsItems.count > 0 ? smartListsItems.last!.frame.maxY : userPanel.frame.maxY + padding*0.5
        listsLabel.frame.origin.y = maxY
        tableView.frame.origin.y = listsLabel.frame.maxY
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return App.userTaskLists.count+1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sideMenuTaskListCell", for: indexPath) as! TaskListTableCell
        
        if indexPath.row == 0 {
            cell.Setup(taskList: App.mainTaskList, frameSize: CGSize(width: tableView.frame.width, height: tableView.rowHeight), index: App.settingsConfig.smartLists.count, taskCountNumber: { App.mainTaskList.upcomingTasks.count })
        } else {
            cell.Setup(taskList: App.userTaskLists[indexPath.row-1], frameSize: CGSize(width: tableView.frame.width, height: tableView.rowHeight), index: indexPath.row+App.settingsConfig.smartLists.count, taskCountNumber: { App.userTaskLists[indexPath.row-1].upcomingTasks.count } )
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil) { suggestedActions in
            let cell = tableView.cellForRow(at: indexPath) as! TaskListTableCell
            
            let DeleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                let confirmationVC = ConfirmationSlideover(
                    title: "Delete \"\(cell.taskListMenuItem.taskList.name)\"?",
                    description: "All tasks from this list will be lost",
                    confirmActionTitle: "Delete",
                    confirmActionColor: .systemRed,
                    confirmAction: { App.instance.DeleteTaskList(taskList: cell.taskListMenuItem.taskList) })
                App.instance.present(confirmationVC, animated: true)
            }
            let Delete = UIMenu(title: "", options: .displayInline, children: [DeleteAction])
            
            let Edit = UIAction(title: "Edit", image: UIImage(systemName: "square.and.pencil")) { action in
                let cell = tableView.cellForRow(at: indexPath) as! TaskListTableCell
                App.instance.OpenEditTaskListView(taskList: cell.taskListMenuItem.taskList)
            }
            
            let isIncludedInSmartList = App.settingsConfig.listsShownInSmartLists.contains(cell.taskListMenuItem.taskList.id) || App.settingsConfig.listsShownInSmartLists.count == 0
            let ToggleSmartListInclusion = UIAction(title: isIncludedInSmartList ? "Hide from Smart Lists" : "Show in Smart Lists", image: UIImage(systemName: isIncludedInSmartList ? "minus.square" : "plus.square")) { action in
                self.ToggleSmartListInclusion(tasklist: cell.taskListMenuItem.taskList)
            }
            
            var regularChildren = [Edit, ToggleSmartListInclusion]
            if isIncludedInSmartList && App.settingsConfig.listsShownInSmartLists.count == 1 { regularChildren.removeLast() }
            
            let Regular = UIMenu(title: "", options: .displayInline, children: regularChildren)
            
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
        dragPreviewParams.backgroundColor = cell.taskListMenuItem.isSelected ? ThemeManager.currentTheme.sidemenuSelectionColor : .clear
        return dragPreviewParams
    }
    func tableView(_ tableView: UITableView, dragPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        let dragPreviewParams = UIDragPreviewParameters()
        let cell = tableView.cellForRow(at: indexPath) as! TaskListTableCell
        dragPreviewParams.visiblePath = UIBezierPath(roundedRect: cell.taskListMenuItem.frame, cornerRadius: 10.0)
        dragPreviewParams.backgroundColor = cell.taskListMenuItem.isSelected ? ThemeManager.currentTheme.sidemenuSelectionColor : .clear
        selectedTaskListID = App.selectedTaskListIndex < App.settingsConfig.smartLists.count ? nil : App.selectedTaskListIndex == App.settingsConfig.smartLists.count ? App.mainTaskList.id : App.userTaskLists[App.selectedTaskListIndex-App.settingsConfig.smartLists.count-1].id
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
            dragPreviewParams.backgroundColor = ThemeManager.currentTheme.sidemenuSelectionColor
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
        
        if selectedTaskListID == nil { return }
        if selectedTaskListID == App.mainTaskList.id { return }
        for tasklist in App.userTaskLists {
            if tasklist.id == selectedTaskListID {
                App.instance.SelectTaskList(index: App.userTaskLists.firstIndex(of: tasklist)!+App.settingsConfig.smartLists.count+1, closeMenu: false)
                break
            }
        }
    }
    
    func ToggleSmartListInclusion(tasklist: TaskList) {
        let isIncludedInSmartList = App.settingsConfig.listsShownInSmartLists.contains(tasklist.id) || App.settingsConfig.listsShownInSmartLists.count == 0
        
        if !isIncludedInSmartList {
            if !App.settingsConfig.listsShownInSmartLists.contains(tasklist.id) {
                App.settingsConfig.listsShownInSmartLists.append(tasklist.id)
                if App.settingsConfig.listsShownInSmartLists.count >= App.userTaskLists.count + 1 {
                    App.settingsConfig.listsShownInSmartLists.removeAll()
                }
            }
        } else {
            if App.settingsConfig.listsShownInSmartLists.contains(tasklist.id) {
                App.settingsConfig.listsShownInSmartLists.remove(at: App.settingsConfig.listsShownInSmartLists.firstIndex(of: tasklist.id)!)
            } else if App.settingsConfig.listsShownInSmartLists.count == 0 {
                if App.mainTaskList.id != tasklist.id {
                    App.settingsConfig.listsShownInSmartLists.append(App.mainTaskList.id)
                }
                for userlist in App.userTaskLists {
                    if userlist.id == tasklist.id { continue }
                    App.settingsConfig.listsShownInSmartLists.append(userlist.id)
                }
            }
        }
        App.instance.SelectTaskList(index: App.selectedTaskListIndex, closeMenu: false)
        App.instance.sideMenuView.UpdateSmartListTasksCount()
        SaveManager.instance.SaveSettings()
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
        parameters.backgroundColor = ThemeManager.currentTheme.sidemenuSelectionColor
        parameters.visiblePath = UIBezierPath(roundedRect: previewView.bounds, cornerRadius: 10)

        return UITargetedPreview(view: previewView, parameters: parameters)
    }
    
    
    @objc func OpenAddTaskListView () {
        app.OpenAddTaskListView()
    }
    
    @objc func OpenSettings () {
        App.instance.present(SettingsNavigationController(), animated: true)
    }
    
    func ReloadThemeColors() {
        UIView.animate(withDuration: 0.25) {
            self.backgroundColor = ThemeManager.currentTheme.sidemenuBackgroundColor
        }
    }
    
    func UpdateUpcomingTasksCounts () {
        UpdateSmartListTasksCount()
        for cell in tableView.visibleCells {
            let taskListCell = cell as! TaskListTableCell
            taskListCell.taskListMenuItem.ReloadTaskCountNumber()
        }
    }
    
    func UpdateSmartListTasksCount () {
        for cell in smartListsItems {
            let taskListCell = cell as! TaskListMenuItem
            taskListCell.ReloadTaskCountNumber()
        }
    }
    
    func OpenUserOverview () {
        self.parentViewController?.show(UserProfileNavigationController(), sender: self)
    }
    
    func UpdateSmartListsVisuals () {
        for smartList in smartListsItems { smartList.ReloadVisuals() }
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
    
    var taskCountNumber: (()->Int)?
    
    var isSelected: Bool {
        get {
            return App.selectedTaskListIndex == index
        }
    }
    
    init(frame: CGRect, taskList: TaskList, index: Int, taskCountNumber: (()->Int)? = nil) {
        self.index = index
        self.taskList = taskList
        self.taskCountNumber = taskCountNumber
        super.init(frame: frame)
        
        self.backgroundColor = isSelected ? ThemeManager.currentTheme.sidemenuSelectionColor : .clearInteractive
        self.layer.cornerRadius = 10
        self.tintAdjustmentMode = .normal
        
        let iconView = UIImageView(frame: CGRect(x: padding*2+1, y: 1, width: (frame.width-padding*2)*imageWidthProportion-2, height: frame.height-2))
        iconView.image = UIImage(systemName: taskList.systemIcon)
        iconView.tintColor = taskList.primaryColor
        iconView.contentMode = .scaleAspectFit
        
        let upcomingTaskCountLabelWidth: CGFloat
        if taskCountNumber != nil {
            upcomingTaskCountLabelWidth = 20
            upcomingTaskCountLabel = UILabel(frame: CGRect(x: frame.width-padding*2-upcomingTaskCountLabelWidth, y: 0, width: upcomingTaskCountLabelWidth, height: frame.height))
            upcomingTaskCountLabel.textColor = .lightGray
            upcomingTaskCountLabel.text = taskCountNumber!() == 0 ? "" : taskCountNumber!().description
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
        self.backgroundColor = isSelected ? ThemeManager.currentTheme.sidemenuSelectionColor : .clearInteractive
    }
    
    func ReloadThemeColors() {
        UIView.animate(withDuration: 0.25) {
            self.ReloadVisuals()
        }
    }
    
    func ReloadTaskCountNumber () {
        if taskCountNumber != nil {
            upcomingTaskCountLabel.text = taskCountNumber!() == 0 ? "" : taskCountNumber!().description
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
    
    func Setup(taskList: TaskList, frameSize: CGSize, index: Int, taskCountNumber: (()->Int)? = nil) {
        for subview in contentView.subviews {
            subview.removeFromSuperview()
        }
        taskListMenuItem = TaskListMenuItem(frame: CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height), taskList: taskList, index: index, taskCountNumber: taskCountNumber)
        contentView.addSubview(taskListMenuItem)
    }
    
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class UserPanel: UIView, UIDynamicTheme {
    
    let padding = 16.0
    
    var levelFrame: LevelFrame!
    let usernameLabel = UILabel()
    var progressBar: ProgressBar!
    
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
        let levelIconSize = frame.height
        levelFrame = LevelFrame(frame: CGRect(x: 0, y: 0, width: levelIconSize, height: levelIconSize))
        
        let usernameWidth = frame.width - levelIconSize - padding*0.5
        let usernameHeight = 20.0
        usernameLabel.frame = CGRect(x: levelFrame.frame.maxX+padding*0.45, y: 0.3*(levelIconSize-usernameHeight), width: usernameWidth, height: usernameHeight)
        usernameLabel.textColor = .white
        ReloadName()
        
        progressBar = ProgressBar(frame: CGRect(x: usernameLabel.frame.origin.x, y: usernameLabel.frame.maxY + padding*0.5, width: usernameWidth-padding, height: 3))
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Tap)))
        
        progressBar.UpdateProgress(progress: StatsManager.levelProgress)
        
        self.addSubview(levelFrame)
        self.addSubview(usernameLabel)
        self.addSubview(progressBar)
    }
    
    
    
    func ReloadThemeColors() {
        UIView.animate(withDuration: 0.25) { [self] in
            levelFrame.UpdateColor(color: ThemeManager.currentTheme.primaryElementColor())
        }
        progressBar.ReloadColors()
    }
    
    func ReloadName () {
        usernameLabel.text = App.settingsConfig.userFullName == "" ? "User" : App.settingsConfig.userFullName
    }
    
    func ReloadPanel () {
        progressBar.UpdateProgress(progress: StatsManager.levelProgress)
        levelFrame.UpdateLevel(level: StatsManager.stats.level)
    }
    
    @objc func Tap () {
        App.instance.sideMenuView.OpenUserOverview()
    }
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class LevelFrame: UIView {
    
    let levelIcon = UIImageView()
    let levelLabel = UILabel()
    let colorLayer = UIView()
    
    override init (frame: CGRect) {
        
        super.init(frame: frame)
        
        let iconSize = frame.width * 0.95
        levelIcon.frame = CGRect(x: 0.5*(frame.width-iconSize), y: 0.5*(frame.height-iconSize), width: iconSize, height: iconSize)
        levelIcon.contentMode = .scaleAspectFit
        colorLayer.frame = levelIcon.frame
        colorLayer.layer.compositingFilter = "multiplyBlendMode"
        
        levelLabel.frame = levelIcon.frame
        levelLabel.frame.origin.y -= frame.width/57
        levelLabel.textColor = .white
        levelLabel.textAlignment = .center
        levelLabel.font = .systemFont(ofSize: 20*(frame.width/57), weight: .semibold)
        
        self.addSubview(levelIcon)
        self.addSubview(colorLayer)
        self.addSubview(levelLabel)
        
        UpdateLevel(level: StatsManager.stats.level)
        UpdateColor(color: ThemeManager.currentTheme.primaryElementColor())
    }
    
    func UpdateLevel(level: Int) {
        let iconSize = frame.width * 0.95
        levelLabel.text = level.description
        levelIcon.image = StatsManager.stats.level < 20 ? UIImage(named: "Level Frame 1") : UIImage(named: "Level Frame 2")
        let mask = UIImageView(image: levelIcon.image)
        mask.frame = CGRect(x: -0.5, y: -0.5, width: iconSize+1, height: iconSize+1)
        mask.contentMode = .scaleAspectFit
        colorLayer.mask = mask
    }
    
    func UpdateColor(color: UIColor) {
        colorLayer.backgroundColor = color
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


class ProgressBar: UIView {
 
    
    let progressbarBackground = UIView()
    let progressbarForeground = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        progressbarBackground.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        progressbarBackground.backgroundColor = ThemeManager.currentTheme.sidemenuSelectionColor
        progressbarBackground.layer.cornerRadius = progressbarBackground.frame.height*0.5
        
        progressbarForeground.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        progressbarForeground.backgroundColor = ThemeManager.currentTheme.primaryElementColor()
        progressbarForeground.layer.cornerRadius = progressbarForeground.frame.height*0.5
        
        self.addSubview(progressbarBackground)
        self.addSubview(progressbarForeground)
    }
    
    func UpdateProgress (progress: CGFloat) {
        progressbarForeground.frame.size.width = progressbarBackground.frame.width * progress
    }
    
    func ReloadColors() {
        UIView.animate(withDuration: 0.25) { [self] in
            progressbarBackground.backgroundColor = ThemeManager.currentTheme.sidemenuSelectionColor
            progressbarForeground.backgroundColor = ThemeManager.currentTheme.primaryElementColor()
        }
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
