//
//  TaskSlider.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/14/22.
//

import UIKit
import SwiftUI

class TaskSlider: UIView, UITextFieldDelegate, UIDynamicTheme, UIGestureRecognizerDelegate {
    
    let app: App
    
    var task: Task
    var isEditing: Bool = false
    var taskListColor: UIColor
    
    let padding = 8.0
    let sliderCornerRadius = 10.0
    
    var sliderBackground: UIView!
    var sliderView: UIView!
    var sliderHandle: UIView!
    var dragHandleDummy: UIView!
    var taskNameInputField: UITextField!
    var dateInfoView: UIView!
    var dateLabel: UILabel!
    var calendarIconView: UIImageView!
    
    let sliderHandleWidth: CGFloat
    let sliderHandleOriginX: CGFloat
    let fullSliderWidth: CGFloat
    let calendarIconWidth: CGFloat
    
    let placeholders: [String] = ["Finish annual report", "Create images for the presentation", "Meditate", "Plan holidays with the family", "Help mom with groceries", "Buy new shoes", "Get cat food", "Get dog food", "Brush my corgie", "Congratulate George", "Rearrange furniture", "Buy airplane tickets", "Cancel streaming subscription", "Schedule coffee chat", "Schedule work meeting", "Dye my hair", "Download Elden Ring", "Get groceries"]
    
    init(task: Task, frame: CGRect, taskListColor: UIColor, app: App) {
        self.task = task
        self.app = app
        self.taskListColor = taskListColor
        
        sliderHandleWidth = !task.isCompleted ? frame.width*0.075 : 0
        fullSliderWidth = frame.width
        sliderHandleOriginX = 2.5
        calendarIconWidth = sliderHandleWidth*0.8
        
        super.init(frame: frame)

        dateLabel = UILabel()
        dateLabel.attributedText = assignedDateTimeString
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.frame = CGRect(x: 0, y: 0, width: dateLabel.intrinsicContentSize.width, height: frame.height)
        
        dateInfoView = UIView (frame: CGRect(x: frame.width - dateInfoWidth - padding, y: 0, width: dateInfoWidth, height: frame.height))
        dateInfoView.alpha = task.isDateAssigned ? 1 : 0
        dateInfoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DateTap)))
        dateInfoView.isUserInteractionEnabled = isEditing ? true : false
        
        calendarIconView = UIImageView(frame: CGRect(x: frame.width - padding - calendarIconWidth, y: 0, width: calendarIconWidth, height: frame.height))
        calendarIconView.image = UIImage(systemName: "calendar")
        calendarIconView.tintColor = .systemGray
        calendarIconView.contentMode = .scaleAspectFit
        calendarIconView.alpha = isEditing && !task.isDateAssigned ? 1 : 0
        calendarIconView.isUserInteractionEnabled = true
        calendarIconView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DateTap)))
        
        dateInfoView.addSubview(dateLabel)
        
        
        taskNameInputField = UITextField(frame: CGRect(x: sliderHandleWidth+padding, y: 0, width: textInputWidth, height: frame.height))
        
        sliderView = UIView(frame: CGRect(x: 0, y: 0, width: sliderHandleWidth, height: frame.height))
        
        sliderHandle = UIView(frame: CGRect(x: sliderHandleOriginX, y: 2.5, width: sliderView.frame.width-5, height: sliderView.frame.height-5))
        
        sliderBackground = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        sliderBackground.layer.cornerRadius = sliderCornerRadius
        sliderBackground.backgroundColor = sliderBackgroundColor
        
        taskNameInputField.delegate = self
        taskNameInputField.placeholder = placeholders[Int.random(in: 0..<placeholders.count)]
        if task.isCompleted {
            let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: task.name)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSRange(location: 0, length: attributeString.length))
            taskNameInputField.attributedText = attributeString
        } else { taskNameInputField.text = task.name }
        if taskNameInputField.text == "" {
            StartEditing()
        }
        taskNameInputField.textColor = task.isCompleted ? .systemGray.withAlphaComponent(0.7) : .label
        taskNameInputField.isEnabled = isEditing
        taskNameInputField.addTarget(self, action: #selector(DetectTextFieldChange), for: .editingChanged)
        
        sliderView.backgroundColor = taskListColor
        sliderView.layer.cornerRadius = sliderCornerRadius
//        sliderView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(Dragging)))
        sliderView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TapSlider)))

        sliderHandle.backgroundColor = !task.isCompleted ? taskListColor.dark : .clear
        sliderHandle.layer.cornerRadius = sliderCornerRadius*0.85
        sliderHandle.isUserInteractionEnabled = false
        
        dragHandleDummy = UIView(frame: CGRect(x: sliderHandleWidth*0.3, y: 0, width: sliderHandleWidth*2, height: frame.height))
        dragHandleDummy.backgroundColor = .clear
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(Dragging))
        dragGesture.delegate = self
        dragHandleDummy.addGestureRecognizer(dragGesture)
        dragHandleDummy.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TapDummyHandle)))
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(DoubleTap))
        doubleTap.numberOfTapsRequired = 2
        
        addGestureRecognizer(doubleTap)
        
        addSubview(sliderBackground)
        addSubview(dateInfoView)
        addSubview(calendarIconView)
        addSubview(sliderView)
        addSubview(sliderHandle)
        addSubview(dragHandleDummy)
        addSubview(taskNameInputField)
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return !App.instance.isSideMenuOpen
    }
    
    var prevProgress = 0.0
    var originX = 0.0
    @objc func Dragging(sender: UIPanGestureRecognizer) {
        if taskNameInputField.text == "" { return }
        if sender.state == .began {
            StopEditing()
            originX = sender.location(in: self).x - sliderHandleWidth*0.5
            UIView.animate(withDuration: 0.15) { [self] in
                sliderView.frame.size.width = max(sliderHandleWidth, min(sender.translation(in: self).x + sliderHandleWidth + originX, fullSliderWidth))
                sliderHandle.frame.origin.x = max(sliderHandleOriginX, min(sliderHandleOriginX + sender.translation(in: self).x + originX, fullSliderWidth-sliderHandleWidth*0.925))
            }
        } else if sender.state == .changed {
            sliderView.frame.size.width = max(sliderHandleWidth, min(sender.translation(in: self).x + sliderHandleWidth + originX, fullSliderWidth))
            sliderHandle.frame.origin.x = max(sliderHandleOriginX, min(sliderHandleOriginX + sender.translation(in: self).x + originX, fullSliderWidth-sliderHandleWidth*0.925))
            
            let currentProgress = floor(sliderView.frame.size.width*6/fullSliderWidth)/6
            if currentProgress != prevProgress {
                prevProgress = currentProgress
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        } else if sender.state == .ended {
            if sender.velocity(in: self).x > 1500 {
                let duration = sender.velocity(in: self).x*0.00005
                UIView.animate(withDuration: duration) { [self] in
                    sliderView.frame.size.width = fullSliderWidth
                    sliderHandle.frame.origin.x = fullSliderWidth-sliderHandleWidth*0.925
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + duration*0.9) { [self] in
                    app.CompleteTask(task: task)
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
            } else if sliderView.frame.size.width == fullSliderWidth {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                app.CompleteTask(task: task)
            } else {
                UIView.animate(withDuration: 0.25) { [self] in
                    sliderView.frame.size.width = sliderHandleWidth
                    sliderHandle.frame.origin.x = sliderHandleOriginX
                }
            }
        }
    }
    
    @objc func TapSlider () {
        let duration = 0.2
        StopEditing()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut) { [self] in
            sliderView.frame.size.width = fullSliderWidth
            sliderHandle.frame.origin.x = fullSliderWidth-sliderHandleWidth*0.925
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration*0.8) { [self] in
            app.CompleteTask(task: task)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
    @objc func TapDummyHandle (sender: UITapGestureRecognizer) {
        if sliderView.bounds.contains(sender.location(in: self)) {
            TapSlider()
        }
    }
    
    @objc func DoubleTap () {
        StartEditing()
    }
    func StartEditing(focusTextField: Bool = true) {
        if task.isCompleted { return }
        
        isEditing = true
        taskNameInputField.isEnabled = true
        dateInfoView.isUserInteractionEnabled = true
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        if focusTextField {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [self] in
                UIView.animate(withDuration: 0.25) {
                    self.taskNameInputField.becomeFirstResponder()
                }
            }
        }
        
        ToggleCalendarButton()
        
        App.instance.taskListView.currentSliderEditing = self
    }
    
    func StopEditing (putInRightPlace: Bool = false) {
        if !isEditing { return }
        
        UIView.animate(withDuration: 0.25) {
            self.taskNameInputField.resignFirstResponder()
        }
        isEditing = false
        taskNameInputField.isEnabled = false
        dateInfoView.isUserInteractionEnabled = false
        
        task.name = taskNameInputField.text!
        
        if taskNameInputField.text == "" {
            app.DeleteTask(task: task)
        } else if putInRightPlace {
            App.instance.taskListView.MoveTaskToRightSortedIndexPath(task: task)
        }
        
        ToggleCalendarButton()
    }
    
    func AddDate(date: Date) {
        task.isDateAssigned = true
        task.dateAssigned = date
        
        calendarIconView.alpha = 0
        dateInfoView.alpha = 1
        
        UpdateDateLabel()
        
        taskNameInputField.becomeFirstResponder()
        
        AnalyticsHelper.LogTaskAssignedDate()
    }
    
    func ClearDateAndTime() {
        task.isDateAssigned = false
        task.isDueTimeAssigned = false
        task.dateAssigned = Date(timeIntervalSince1970: 0)
        task.RemoveAllNotifications()
        calendarIconView.alpha = isEditing ? 1 : 0
        UpdateDateLabel()
        
        taskNameInputField.becomeFirstResponder()
    }
    
    
    
    func UpdateDateLabel () {
        dateLabel.attributedText = assignedDateTimeString
        dateLabel.frame = CGRect(x: 0, y: 0, width: dateLabel.intrinsicContentSize.width, height: dateInfoView.frame.height)
        dateInfoView.alpha = task.isDateAssigned ? 1 : 0
        
        dateInfoView.frame.size.width = dateInfoWidth
        dateInfoView.frame.origin.x = frame.width - dateInfoWidth - padding
        
        taskNameInputField.frame.size.width = textInputWidth
    }
    
    func ToggleCalendarButton () {
        UIView.animate(withDuration: 0.25) { [self] in
            taskNameInputField.frame.size.width = textInputWidth
            calendarIconView.alpha = isEditing && !task.isDateAssigned ? 1 : 0
        }
    }
    
    @objc func DateTap () {
        ShowCalendarView(taskSliderContextMenu: nil)
    }
    func ShowCalendarView(taskSliderContextMenu: TaskSliderContextMenu?) {
        taskNameInputField.resignFirstResponder()
        
        let color: UIColor
        if App.selectedTaskListIndex == 0 { color = .defaultColor }
        else if App.selectedTaskListIndex == 1 { color = App.mainTaskList.primaryColor }
        else { color = App.userTaskLists[App.selectedTaskListIndex-2].primaryColor }
        
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first

        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            let calendar = CalendarViewController(tintColor: color, taskSlider: self, taskSliderContextMenu: taskSliderContextMenu)
            calendar.modalPresentationStyle = .overFullScreen
            calendar.modalTransitionStyle = .crossDissolve
            topController.present(calendar, animated: false)
        }
    }
    
    func HideCalendarView () {
        taskNameInputField.becomeFirstResponder()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        StopEditing(putInRightPlace: true)
        App.instance.taskListView.currentSliderEditing = nil
        return true
    }
    
    @objc func DetectTextFieldChange() {
        task.name = taskNameInputField.text!
        if taskNameInputField.text!.contains("!")  {
            SetTaskPriority(priority: .High)
            AnalyticsHelper.LogTaskSetHighPriority()
        } else {
            SetTaskPriority(priority: .Normal)
        }
    }
    
    func SetTaskPriority (priority: TaskPriority) {
        task.priority = priority
        ReloadThemeColors()
    }
    
    
    
    
    
    
    var dateInfoWidth: CGFloat {
        return task.isDateAssigned ? dateLabel.intrinsicContentSize.width : 0
    }
    var textInputWidth: CGFloat {
        var width = frame.width-sliderHandleWidth-padding*2
        if task.isDateAssigned { width -= dateInfoView.frame.width + padding }
        if isEditing && !task.isDateAssigned { width -= calendarIconWidth + padding }
        return width
    }
    
    var assignedDateTimeString: NSMutableAttributedString {
        if !task.isDateAssigned {
            return NSMutableAttributedString(string: "")
        }
        
        var attString = NSMutableAttributedString(string: "")
        if Calendar.current.isDateInToday(task.dateAssigned) {
            attString = NSMutableAttributedString(string: "Today")
        } else if Calendar.current.isDateInTomorrow(task.dateAssigned) {
            attString = NSMutableAttributedString(string: "Tomorrow")
        } else if Calendar.current.isDateInYesterday(task.dateAssigned) {
            attString = NSMutableAttributedString(string: "Yesterday")
        } else {
            let formatter = DateFormatter()
            formatter.timeStyle = .none
            if task.dateAssigned.get(.year) == Date.now.get(.year) { //this year
                formatter.setLocalizedDateFormatFromTemplate("MMMd")
            } else { //other years
                formatter.dateStyle = .short
            }
            
            attString = NSMutableAttributedString(string: formatter.string(from: task.dateAssigned))
        }
        
        if task.isDueTimeAssigned {
            let formatter2 = DateFormatter()
            formatter2.timeStyle = .short
            formatter2.dateFormat = .none
            attString.append(NSMutableAttributedString(string: ", \(formatter2.string(from: task.dateAssigned))"))
        }
        
        if task.isCompleted {
            attString.SetColor(color: UIColor.systemGray.withAlphaComponent(0.7))
            attString.Strikethrough()
        } else {
            attString.SetColor(color: !task.isOverdue ? UIColor.systemGray : AppColors.sliderOverdueLabelColor)
        }
        
        return attString
    }
    
    var sliderBackgroundColor: UIColor {
        if task.isCompleted { return AppColors.sliderCompletedBackgroundColor(taskListColor: taskListColor) }
        
        return task.priority == .High ? AppColors.sliderHighPriorityBackgroundColor(taskListColor: taskListColor) : .systemGray6
    }
    
    func ReloadThemeColors() {
        UIView.animate(withDuration: 0.25) { [self] in
            sliderBackground.backgroundColor = sliderBackgroundColor
        }
    }
    
    func UpdateTaskListColor (newColor: UIColor) {
        taskListColor = newColor
        UIView.animate(withDuration: 0.25) { [self] in
            sliderView.backgroundColor = taskListColor
            sliderHandle.backgroundColor = !task.isCompleted ? taskListColor.dark : .clear
            sliderBackground.backgroundColor = sliderBackgroundColor
        }
    }
    
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class TaskSliderTableCell: UITableViewCell {
    
    var slider: TaskSlider!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        isUserInteractionEnabled = true
        shouldIndentWhileEditing = false
        self.backgroundColor = .clear
    }
    
    func Setup(task: Task, sliderSize: CGSize, cellSize: CGSize, taskListColor: UIColor, app: App) {
        for subview in contentView.subviews {
            subview.removeFromSuperview()
        }
        slider = TaskSlider(
            task: task,
            frame: CGRect(x: 0.5*(cellSize.width - sliderSize.width), y: 0.5*(cellSize.height - sliderSize.height), width: sliderSize.width, height: sliderSize.height),
            taskListColor: taskListColor, app: app)
        
        contentView.addSubview(slider)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
