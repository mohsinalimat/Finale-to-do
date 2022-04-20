//
//  TaskSlider.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/14/22.
//

import UIKit
import SwiftUI

class TaskSlider: UIView, UITextFieldDelegate {
    
    let app: App
    
    var task: Task
    var isEditing: Bool = false
    let sliderColor: UIColor
    
    let padding = 8.0
    let sliderCornerRadius = 10.0
    
    var sliderView: UIView!
    var sliderHandle: UIView!
    var taskNameInputField: UITextField!
    var dateInfoView: UIView!
    var dateLabel: UILabel!
    var calendarIconView: UIImageView!
    
    let sliderHandleWidth: CGFloat
    let sliderHandleOriginX: CGFloat
    let fullSliderWidth: CGFloat
    let calendarIconWidth: CGFloat
    
    let placeholders: [String] = ["Finish annual report", "Create images for the presentation", "Meditate", "Plan holidays with the family", "Help mom with groceries", "Buy new shoes", "Get cat food", "Get dog food", "Brush my corgie", "Say hi to QQ", "Chmok my QQ", "Buy airplane tickets", "Cancel streaming subscription", "Schedule coffee chat", "Schedule work meeting", "Dye my hair", "Download Elden Ring", "Get groceries"]
    
    init(task: Task, frame: CGRect, sliderColor: UIColor, app: App) {
        self.task = task
        self.app = app
        self.sliderColor = sliderColor
        
        sliderHandleWidth = !task.isCompleted ? frame.width*0.075 : 0
        fullSliderWidth = frame.width
        sliderHandleOriginX = 2.5
        calendarIconWidth = sliderHandleWidth*0.8
        
        super.init(frame: frame)
        

        dateLabel = UILabel()
        if task.isCompleted {
            let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: assignedDateTimeString)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSRange(location: 0, length: attributeString.length))
            dateLabel.attributedText = attributeString
        } else { dateLabel.text = assignedDateTimeString }
        dateLabel.textColor = task.isCompleted ? .systemGray.withAlphaComponent(0.7) : .systemGray
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.frame = CGRect(x: 0, y: 0, width: dateLabel.intrinsicContentSize.width, height: frame.height)
        
        dateInfoView = UIView (frame: CGRect(x: frame.width - dateInfoWidth - padding, y: 0, width: dateInfoWidth, height: frame.height))
        dateInfoView.alpha = task.isDateAssigned ? 1 : 0
        dateInfoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ShowCalendarView)))
        dateInfoView.isUserInteractionEnabled = isEditing ? true : false
        
        calendarIconView = UIImageView(frame: CGRect(x: frame.width - padding - calendarIconWidth, y: 0, width: calendarIconWidth, height: frame.height))
        calendarIconView.image = UIImage(systemName: "calendar")
        calendarIconView.tintColor = .systemGray
        calendarIconView.contentMode = .scaleAspectFit
        calendarIconView.alpha = isEditing && !task.isDateAssigned ? 1 : 0
        calendarIconView.isUserInteractionEnabled = true
        calendarIconView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ShowCalendarView)))
        
        dateInfoView.addSubview(dateLabel)
        
        
        taskNameInputField = UITextField(frame: CGRect(x: sliderHandleWidth+padding, y: 0, width: textInputWidth, height: frame.height))
        
        sliderView = UIView(frame: CGRect(x: 0, y: 0, width: sliderHandleWidth, height: frame.height))
        
        sliderHandle = UIView(frame: CGRect(x: sliderHandleOriginX, y: 2.5, width: sliderView.frame.width-5, height: sliderView.frame.height-5))
        
        let background = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        background.layer.cornerRadius = sliderCornerRadius
        background.backgroundColor = !task.isCompleted ? UIColor.systemGray6 : AppColors().getCompletedSliderColor(taskListColor: sliderColor)
        
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
        
        sliderView.backgroundColor = sliderColor
        sliderView.layer.cornerRadius = sliderCornerRadius
        sliderView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(Dragging)))

        sliderHandle.backgroundColor = !task.isCompleted ? sliderColor.dark : .clear
        sliderHandle.layer.cornerRadius = sliderCornerRadius*0.85
        sliderHandle.isUserInteractionEnabled = false
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(StartEditing))
        doubleTap.numberOfTapsRequired = 2
        
        addGestureRecognizer(doubleTap)
        
        addSubview(background)
        addSubview(dateInfoView)
        addSubview(calendarIconView)
        addSubview(sliderView)
        addSubview(sliderHandle)
        addSubview(taskNameInputField)
    }
    
    var prevProgress = 0.0
    @objc func Dragging(sender: UIPanGestureRecognizer) {
        if taskNameInputField.text == "" { return }
        if sender.state == .began {
            self.endEditing(true)
        } else if sender.state == .changed {
            sliderView.frame.size.width = max(sliderHandleWidth, min(sender.translation(in: self).x + sliderHandleWidth, fullSliderWidth))
            sliderHandle.frame.origin.x = max(sliderHandleOriginX, min(sliderHandleOriginX + sender.translation(in: self).x, fullSliderWidth-sliderHandleWidth*0.925))
            
            let currentProgress = floor(sliderView.frame.size.width*10/fullSliderWidth)/10
            if currentProgress != prevProgress {
                prevProgress = currentProgress
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        } else if sender.state == .ended {
            if sender.velocity(in: self).x > 2000 {
                let duration = sender.velocity(in: self).x*0.00006
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                    app.CompleteTask(task: task)
                }
            } else {
                UIView.animate(withDuration: 0.25) { [self] in
                    sliderView.frame.size.width = sliderHandleWidth
                    sliderHandle.frame.origin.x = sliderHandleOriginX
                }
            }
        }
    }
    
    @objc func StartEditing () {
        isEditing = true
        taskNameInputField.isEnabled = true
        dateInfoView.isUserInteractionEnabled = true
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [self] in
            UIView.animate(withDuration: 0.25) {
                self.taskNameInputField.becomeFirstResponder()
            }
        }
        
        ToggleCalendarButton()
    }
    
    func StopEditing () {
        UIView.animate(withDuration: 0.25) {
            self.taskNameInputField.resignFirstResponder()
        }
        isEditing = false
        taskNameInputField.isEnabled = false
        dateInfoView.isUserInteractionEnabled = false
        
        task.name = taskNameInputField.text!
        
        if taskNameInputField.text == "" {
            app.DeleteTask(task: task)
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
    }
    
    func ClearDate() {
        task.isDateAssigned = false
        calendarIconView.alpha = 1
        UpdateDateLabel()
        
        taskNameInputField.becomeFirstResponder()
    }
    
    func UpdateDateLabel () {
        dateLabel.text = assignedDateTimeString
        dateLabel.frame = CGRect(x: 0, y: 0, width: dateLabel.intrinsicContentSize.width, height: dateInfoView.frame.height)
        
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
    
    @objc func ShowCalendarView () {
        taskNameInputField.resignFirstResponder()
        
        let color = App.selectedTaskListIndex == 0 || App.selectedTaskListIndex == 1 ? UIColor.defaultColor : App.userTaskLists[App.selectedTaskListIndex].primaryColor
        App.instance.view.addSubview(CalendarView(frameSize: CGSize(width: UIScreen.main.bounds.width*0.8, height: UIScreen.main.bounds.width), tintColor: color, taskSlider: self))
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        StopEditing()
        return true
    }
    
    @objc func DetectTextFieldChange() {
        task.name = taskNameInputField.text!
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
    
    var assignedDateTimeString: String {
        if !task.isDateAssigned {
            return ""
        }
        
        let formatter = DateFormatter()
        
        if task.dateAssigned.get(.year) == Date.now.get(.year) { //this year
            if !task.isNotificationEnabled {
                formatter.setLocalizedDateFormatFromTemplate("MMMd")
            } else {
                formatter.setLocalizedDateFormatFromTemplate("MMMd, hh:mm")
            }
        } else { //other years
            formatter.timeStyle = task.isNotificationEnabled ? .short : .none
            formatter.dateStyle = .short
        }
        return formatter.string(from: task.dateAssigned)
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
    }
    
    func Setup(task: Task, sliderSize: CGSize, cellSize: CGSize, sliderColor: UIColor, app: App) {
        for subview in contentView.subviews {
            subview.removeFromSuperview()
        }
        slider = TaskSlider(
            task: task,
            frame: CGRect(x: 0.5*(cellSize.width - sliderSize.width), y: 0.5*(cellSize.height - sliderSize.height), width: sliderSize.width, height: sliderSize.height),
            sliderColor: sliderColor, app: app)
        
        contentView.addSubview(slider)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
