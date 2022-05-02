//
//  TaskSliderContextMenu.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/20/22.
//

import Foundation
import UIKit

class TaskSliderContextMenu: UIViewController, UITextViewDelegate, UIDynamicTheme {
    
    let indexPath: IndexPath
    
    let padding = 16.0
    let spacing = 8.0
    var rowHeight: CGFloat!
    let fontSize = 14.0
    
    let slider: TaskSlider
    
    var containerView: UIView!
    var notesTextBackgroundView: UIView!
    var notesInputField: UITextView!
    var nameInputField: UITextView!
    var listButton: UIButton!
    var priorityButton: UIButton!
    var dueButton: UILabel!
    var notificationButton: UILabel!
    var maxDueNotifButtonWidth: CGFloat!
    
    let notesPlaceholder = "Add any notes here"
    
    var newSlider: TaskSlider!
    var row1: UIView!
    var row2: UIView!
    var row3: UIView!
    var row4: UIView!
    var row5: UIView!
    var notesArea: UIView!
    var closeButton: UIButton?
    
    var originalTaskName: String!
    
    init(slider: TaskSlider, indexPath: IndexPath) {
        self.indexPath = indexPath
        self.slider = slider
        super.init(nibName: nil, bundle: nil)
        
        overrideUserInterfaceStyle = App.settingsConfig.interface == .System ? .unspecified : App.settingsConfig.interface == .Light ? .light : .dark
        
        newSlider = TaskSlider(task: slider.task, frame: slider.frame, taskListColor: slider.taskListColor, app: slider.app)
        newSlider.frame.origin = CGPoint(x: 0, y: 0)
        newSlider.isUserInteractionEnabled = false
        
        let rowWidth = slider.frame.width
        let titleWidth = "Notifications:".size(withAttributes:[.font: UIFont.systemFont(ofSize: fontSize, weight: .bold)]).width
        rowHeight = "Notifications:".size(withAttributes:[.font: UIFont.systemFont(ofSize: fontSize, weight: .bold)]).height
        
        row1 = CreateTaskNameRow(title: "Task", fullFrameWidth: rowWidth-padding*2, prevFrame: newSlider.frame, titleWidth: titleWidth)
        
        row2 = CreateListRow(title: "List", fullFrameWidth: rowWidth-padding*2, prevFrame: row1.frame, titleWidth: titleWidth)
        
        row3 = CreatePriorityRow(title: "Priority", fullFrameWidth: rowWidth-padding*2, prevFrame: row2.frame, titleWidth: titleWidth)
        
        row4 = CreateDueRow(title: "Due", fullFrameWidth: rowWidth-padding*2, prevFrame: row3.frame, titleWidth: titleWidth)
        
        if !slider.task.isCompleted {
            row5 = CreateNotificationRow(title: "Notifications", fullFrameWidth: rowWidth-padding*2, prevFrame: row4.frame, titleWidth: titleWidth)
        } else {
            row5 = CreateStaticRow(title: "Completed", content: completedOnContent, fullFrameWidth: rowWidth-padding*2, prevFrame: row4.frame, titleWidth: titleWidth)
        }
        
        notesArea = CreateNotesArea(prevFrameMaxY: row5.frame.maxY)
        
        containerView = UIView(frame: CGRect(x: 0, y: 0, width: slider.frame.width, height: notesArea.frame.maxY + padding))
        containerView.layer.cornerRadius = 10
        containerView.addSubview(newSlider)
        containerView.addSubview(row1)
        containerView.addSubview(row2)
        containerView.addSubview(row3)
        containerView.addSubview(row4)
        containerView.addSubview(row5)
        containerView.addSubview(notesArea)
        containerView.backgroundColor = .systemGray4
        
        self.view.addSubview(containerView)
        
        self.preferredContentSize = CGSize(width: slider.frame.width, height: notesArea.frame.maxY + padding)
        self.view.backgroundColor = .systemGray5
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TapOutside)))
    }
    
    func CreateNotesArea (prevFrameMaxY: CGFloat) -> UIView {
        let noteAreaHeight = 100.0
        
        let containerView = UIView(frame: CGRect(x: padding, y: prevFrameMaxY + padding, width: slider.frame.width - padding*2, height: noteAreaHeight))
        
        let titleLabel = UILabel(frame: CGRect(x: spacing*1.5, y: 0, width: containerView.frame.width, height: rowHeight))
        titleLabel.text = "Notes:"
        titleLabel.textColor = .systemGray
        titleLabel.font = UIFont.systemFont(ofSize: fontSize)
        titleLabel.textAlignment = .left
        
        notesTextBackgroundView = UIView(frame: CGRect(x: 0, y: titleLabel.frame.maxY + spacing*0.5, width: containerView.frame.width, height: containerView.frame.height - titleLabel.frame.size.height-spacing*0.5))
        notesTextBackgroundView.layer.cornerRadius = 10
        
        notesInputField = UITextView(frame: CGRect(x: spacing, y: 0, width: notesTextBackgroundView.frame.width-spacing*2, height: notesTextBackgroundView.frame.height))
        notesInputField.text = slider.task.notes == "" ? notesPlaceholder : slider.task.notes
        notesInputField.textColor = slider.task.notes == "" ? .systemGray2 : .label
        notesInputField.delegate = self
        notesInputField.font = UIFont.systemFont(ofSize: fontSize)
        notesTextBackgroundView.backgroundColor = notesInputField.backgroundColor
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(notesTextBackgroundView)
        
        notesTextBackgroundView.addSubview(notesInputField)
        
        return containerView
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == notesInputField {
            if textView.text == notesPlaceholder {
                textView.text = ""
                textView.textColor = .label
            }
        } else if textView == nameInputField {
            originalTaskName = textView.text
        }
        DispatchQueue.main.async {
            textView.selectedTextRange = textView.textRange(from: textView.endOfDocument, to: textView.endOfDocument)
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == notesInputField {
            if textView.text.isEmpty {
                textView.text = notesPlaceholder
                textView.textColor = .systemGray2
            }
            SaveNotes()
        } else if textView == nameInputField {
            if textView.text == "" {
                UpdateTaskName(name: originalTaskName)
                textView.text = originalTaskName
            }
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == nameInputField {
            if text == "\n" {
                textView.resignFirstResponder()
                return false
            }
            return true
        } else {
            return true
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        if textView == nameInputField {
            let fixedWidth = textView.frame.size.width
            let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            if textView.frame.size != CGSize(width: max(newSize.width, fixedWidth), height: newSize.height) {
                textView.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
                row1.frame.size.height = max(rowHeight, textView.frame.size.height)
                UpdateViewHeight()
            }
            
            UpdateTaskName(name: textView.text)
        }
    }
    
    @objc func TapOutside () {
        notesInputField.resignFirstResponder()
        nameInputField.resignFirstResponder()
        slider.taskNameInputField.resignFirstResponder()
    }
    
    func CreateTaskNameRow (title: String, fullFrameWidth: CGFloat, prevFrame: CGRect, titleWidth: CGFloat) -> UIView {
        let containerView = UIView()
        
        let titleLabel = CreateTitleLabel(title: title, width: titleWidth)
        
        nameInputField = UITextView(frame: CGRect(x: titleLabel.frame.maxX + padding, y: 0, width: fullFrameWidth-titleLabel.frame.width-padding, height: rowHeight))
        nameInputField.font = UIFont.systemFont(ofSize: fontSize)
        nameInputField.text = slider.task.name
        nameInputField.textAlignment = .left
        nameInputField.textContainer.lineFragmentPadding = 0
        nameInputField.textContainerInset = UIEdgeInsets.zero
        nameInputField.backgroundColor = .clear
        nameInputField.frame.size.height = nameInputField.contentSize.height
        nameInputField.isScrollEnabled = false
        nameInputField.delegate = self
        
        containerView.frame = CGRect(x: padding, y: prevFrame.maxY+spacing, width: fullFrameWidth, height: max(titleLabel.frame.height, nameInputField.frame.height))
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(nameInputField)
        
        return containerView
    }
    
    func CreateListRow (title: String, fullFrameWidth: CGFloat, prevFrame: CGRect, titleWidth: CGFloat) -> UIView {
        let containerView = UIView()
        
        let titleLabel = CreateTitleLabel(title: title, width: titleWidth)
        
        listButton = UIButton(frame: CGRect(x: titleLabel.frame.maxX + padding, y: 0, width: fullFrameWidth-titleLabel.frame.width-padding, height: rowHeight))
        listButton.titleLabel?.textAlignment = .left
        listButton.setTitle(listNameContent, for: .normal)
        listButton.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        listButton.setTitleColor(.label, for: .normal)
        listButton.contentHorizontalAlignment = .left
        listButton.showsMenuAsPrimaryAction = true
        listButton.menu = listMenu
        
        containerView.frame = CGRect(x: padding, y: prevFrame.maxY+spacing, width: fullFrameWidth, height: rowHeight)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(listButton)
        
        return containerView
    }
    
    var listMenu: UIMenu {
        let Main = UIAction(title: App.mainTaskList.name, state: slider.task.taskListID == App.mainTaskList.id ? .on : .off) { [self] _ in
            UpdateList(newList: App.mainTaskList)
        }
        
        var items = [UIAction]()
        
        items.append(Main)
        
        for taskList in App.userTaskLists {
            let listAction = UIAction(title: taskList.name, state: slider.task.taskListID == taskList.id ? .on : .off) { [self] _ in
                UpdateList(newList: taskList)
            }
            items.append(listAction)
        }
        
        return UIMenu(title: "", children: items)
    }
    
    func CreatePriorityRow (title: String, fullFrameWidth: CGFloat, prevFrame: CGRect, titleWidth: CGFloat) -> UIView {
        let containerView = UIView()
        
        let titleLabel = CreateTitleLabel(title: title, width: titleWidth)
        
        priorityButton = UIButton(frame: CGRect(x: titleLabel.frame.maxX + padding, y: 0, width: fullFrameWidth-titleLabel.frame.width-padding, height: rowHeight))
        priorityButton.titleLabel?.textAlignment = .left
        priorityButton.setTitle(slider.task.priority.str, for: .normal)
        priorityButton.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        priorityButton.setTitleColor(.label, for: .normal)
        priorityButton.contentHorizontalAlignment = .left
        priorityButton.showsMenuAsPrimaryAction = true
        priorityButton.menu = priorityMenu
        
        containerView.frame = CGRect(x: padding, y: prevFrame.maxY+spacing, width: fullFrameWidth, height: rowHeight)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(priorityButton)
        
        return containerView
    }
    
    var priorityMenu: UIMenu {
        let Normal = UIAction(title: TaskPriority.Normal.str, state: slider.task.priority == .Normal ? .on : .off) { [self] _ in
            UpdatePriority(priority: .Normal)
        }
        let High = UIAction(title: TaskPriority.High.str, state: slider.task.priority == .High ? .on : .off) { [self] _ in
            UpdatePriority(priority: .High)
        }
        
        return UIMenu(title: "", children: [Normal, High])
    }
    
    func CreateDueRow (title: String, fullFrameWidth: CGFloat, prevFrame: CGRect, titleWidth: CGFloat) -> UIView {
        let containerView = UIView()
        
        let titleLabel = CreateTitleLabel(title: title, width: titleWidth)
        
        dueButton = CreateContentLabel(content: dueContent, width: fullFrameWidth-titleLabel.frame.width-padding, positionX: titleLabel.frame.maxX + padding)
        dueButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(OpenCalendarView)))
        dueButton.isUserInteractionEnabled = true
        maxDueNotifButtonWidth = fullFrameWidth-titleLabel.frame.width-padding
        
        containerView.frame = CGRect(x: padding, y: prevFrame.maxY+spacing, width: fullFrameWidth, height: max(titleLabel.frame.height, dueButton.frame.height))
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(dueButton)
        
        return containerView
    }
    
    func CreateNotificationRow (title: String, fullFrameWidth: CGFloat, prevFrame: CGRect, titleWidth: CGFloat) -> UIView {
        let containerView = UIView()
        
        let titleLabel = CreateTitleLabel(title: title, width: titleWidth)
        
        notificationButton = CreateContentLabel(content: notificationContent, width: fullFrameWidth-titleLabel.frame.width-padding, positionX: titleLabel.frame.maxX + padding)
        notificationButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(OpenCalendarView)))
        notificationButton.isUserInteractionEnabled = true
        
        containerView.frame = CGRect(x: padding, y: prevFrame.maxY+spacing, width: fullFrameWidth, height: max(titleLabel.frame.height, notificationButton.frame.height))
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(notificationButton)
        
        return containerView
    }
    
    func CreateStaticRow (title: String, content: NSMutableAttributedString, fullFrameWidth: CGFloat, prevFrame: CGRect, titleWidth: CGFloat) -> UIView {
        let containerView = UIView()
        
        let titleLabel = CreateTitleLabel(title: title, width: titleWidth)
        let contentLabel = CreateContentLabel(content: content, width: fullFrameWidth-titleLabel.frame.width-padding, positionX: titleLabel.frame.maxX + padding)
        
        containerView.frame = CGRect(x: padding, y: prevFrame.maxY+spacing, width: fullFrameWidth, height: max(titleLabel.frame.height, contentLabel.frame.height))
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(contentLabel)
        
        return containerView
    }
    
    func CreateTitleLabel (title: String, width: CGFloat) -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: rowHeight))
        label.text = "\(title):"
        label.textColor = .systemGray
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        
        return label
    }
    
    func CreateContentLabel (content: NSMutableAttributedString, width: CGFloat, positionX: CGFloat) -> UILabel {
        let label = UILabel(frame: CGRect(x: positionX, y: 0, width: width, height: 0))
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.preferredMaxLayoutWidth = width
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.attributedText = content
        label.textAlignment = .left
        label.sizeToFit()
        label.frame.size = label.bounds.size
        
        return label
    }
    
    func UpdateViewHeight () {
        row2.frame.origin.y = row1.frame.maxY + spacing
        row3.frame.origin.y = row2.frame.maxY + spacing
        row4.frame.origin.y = row3.frame.maxY + spacing
        row5.frame.origin.y = row4.frame.maxY + spacing
        notesArea.frame.origin.y = row5.frame.maxY + padding
        containerView.frame.size.height = notesArea.frame.maxY + padding
        closeButton?.frame.origin.y = containerView.frame.maxY + padding
    }
    func UpdateTaskName (name: String) {
        newSlider.taskNameInputField.text = name
        newSlider.DetectTextFieldChange()
        slider.taskNameInputField.text = name
        slider.DetectTextFieldChange()
        priorityButton.setTitle(slider.task.priority.str, for: .normal)
    }
    func UpdatePriority (priority: TaskPriority) {
        if slider.task.priority != priority {
            if !slider.task.name.contains("!") {
                UpdateTaskName(name: slider.task.name.appending("!"))
                nameInputField.text = slider.task.name
            } else {
                while slider.task.name.contains("!") {
                    let i = slider.task.name.firstIndex(of: "!")!
                    slider.task.name.remove(at: i)
                    UpdateTaskName(name: slider.task.name)
                }
            }
            nameInputField.text = slider.task.name
            priorityButton.menu = priorityMenu
        }
    }
    func UpdateList (newList: TaskList) {
        newSlider.task.taskListID = newList.id
        newSlider.UpdateTaskListColor(newColor: newList.primaryColor)
        slider.task.taskListID = newList.id
        slider.UpdateTaskListColor(newColor: newList.primaryColor)
        
        listButton.setTitle(listNameContent, for: .normal)
        listButton.menu = listMenu
        
        if App.mainTaskList.upcomingTasks.contains(slider.task) {
            App.mainTaskList.upcomingTasks.remove(at: App.mainTaskList.upcomingTasks.firstIndex(of: slider.task)!)
        } else {
            for taskList in App.userTaskLists {
                if taskList.upcomingTasks.contains(slider.task) {
                    taskList.upcomingTasks.remove(at: taskList.upcomingTasks.firstIndex(of: slider.task)!)
                    break
                }
            }
        }
        
        if App.mainTaskList.id == newList.id {
            App.mainTaskList.upcomingTasks.insert(slider.task, at: 0)
        } else {
            for taskList in App.userTaskLists {
                if taskList.id == newList.id {
                    taskList.upcomingTasks.insert(slider.task, at: 0)
                }
            }
        }
        
        App.instance.taskListView.taskLists = App.selectedTaskListIndex == 0 ? App.instance.allTaskLists : App.selectedTaskListIndex == 1 ? [App.mainTaskList] : [App.userTaskLists[App.selectedTaskListIndex-2]]
        App.instance.taskListView.ReloadTaskData()
        App.instance.taskListView.tableView.reloadData()
        
        UIView.animate(withDuration: 0.25) { [self] in
            closeButton?.backgroundColor = ThemeManager.currentTheme.primaryElementColor(tasklistColor: newList.primaryColor) 
        }
        
    }
    
    @objc func OpenCalendarView () {
        slider.ShowCalendarView(taskSliderContextMenu: self)
    }
    
    func OnCalendarViewClose () {
        dueButton.frame.size.width = maxDueNotifButtonWidth
        dueButton.attributedText = dueContent
        dueButton.sizeToFit()
        dueButton.frame.size = dueButton.bounds.size
        
        notificationButton.frame.size.width = maxDueNotifButtonWidth
        notificationButton.attributedText = notificationContent
        notificationButton.sizeToFit()
        notificationButton.frame.size = notificationButton.bounds.size
        row5.frame.size.height = notificationButton.frame.height
        
        newSlider.UpdateDateLabel()
        
        UpdateViewHeight()
    }
                                      
    
    var listNameContent: String {
        if slider.task.taskListID == App.mainTaskList.id { return App.mainTaskList.name }
        
        for taskList in App.userTaskLists {
            if slider.task.taskListID == taskList.id { return taskList.name }
        }
        
        return "No list"
    }
    
    var dueContent: NSMutableAttributedString {
        if !slider.task.isDateAssigned {
            let attString = NSMutableAttributedString(string: "Not set")
            attString.SetColor(color: .systemGray)
            return attString
        }
        
        let formatter = DateFormatter()
        
        formatter.timeStyle = slider.task.isDueTimeAssigned ? .short : .none
        formatter.dateStyle = .long
        
        let attString = NSMutableAttributedString(string: formatter.string(from: slider.task.dateAssigned))
        if slider.task.isOverdue {
            attString.SetColor(color: AppColors.sliderOverdueLabelColor)
        }
        return attString
    }
    
    var notificationContent: NSMutableAttributedString {
        var attString = NSMutableAttributedString(string: "")
        
        if slider.task.notifications.count == 0 {
            attString = NSMutableAttributedString(string: "None")
            attString.SetColor(color: .systemGray)
        } else {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 2
            
            let sortedArray = Array(slider.task.notifications.keys).sorted { $0.rawValue < $1.rawValue }
            
            for notificationType in sortedArray {
                attString.append(NSMutableAttributedString(string: "\(notificationType.str)\n"))
            }
            
            attString.deleteCharacters(in: NSRange(attString.length-1..<attString.length))
            
            attString.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attString.length))
        }
        
        return attString
    }
    
    var completedOnContent: NSMutableAttributedString {
        let formatter = DateFormatter()
        
        formatter.timeStyle = slider.task.isDueTimeAssigned ? .short : .none
        formatter.dateStyle = .long
        
        return NSMutableAttributedString(string: formatter.string(from: slider.task.dateCompleted))
    }
    
    func PresentFullScreen() {
        let handleWidth = UIScreen.main.bounds.width*0.15
        let handle = UIView(frame: CGRect(x: 0.5*(UIScreen.main.bounds.width-handleWidth), y: padding, width: handleWidth, height: 4))
        handle.backgroundColor = .systemGray4
        handle.layer.cornerRadius = 2
        
        
        let notesAreaIncrease = notesArea.frame.height
        notesTextBackgroundView.frame.size.height += notesAreaIncrease
        notesInputField.frame.size.height += notesAreaIncrease
        notesArea.frame.size.height += notesAreaIncrease
        
        containerView.frame.origin.x = 0.5*(UIScreen.main.bounds.width-view.frame.width)
        containerView.frame.origin.y = handle.frame.maxY + padding
        
        closeButton = UIButton(frame: CGRect(x: padding, y: containerView.frame.maxY + padding, width: UIScreen.main.bounds.width-padding*2, height: 40))
        closeButton!.backgroundColor = ThemeManager.currentTheme.primaryElementColor(tasklistColor: slider.taskListColor)
        closeButton!.layer.cornerRadius = 10
        closeButton!.setTitle("Close", for: .normal)
        closeButton!.setTitleColor(.systemGray, for: .highlighted)
        closeButton!.tintColor = .white
        closeButton!.addTarget(self, action: #selector(CloseButton), for: .touchUpInside)
        
        self.view.addSubview(closeButton!)
        self.view.addSubview(handle)
        
        UpdateViewHeight()
    }
    
    @objc func CloseButton () {
        Dismiss()
    }
    
    func Dismiss () {
        self.modalTransitionStyle = .coverVertical
        self.dismiss(animated: true)
    }
    
    func SaveNotes () {
        if notesInputField.text != notesPlaceholder {
            slider.task.notes = notesInputField.text
        }
    }
    
    func ReloadThemeColors() {
        UIView.animate(withDuration: 0.25) { [self] in
            closeButton?.backgroundColor = ThemeManager.currentTheme.primaryElementColor(tasklistColor: slider.taskListColor)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        ThemeManager.currentTheme = App.settingsConfig.GetCurrentTheme()
        ReloadThemeColors()
        App.instance.SetSubviewColors(of: self.view)
    }
    
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
