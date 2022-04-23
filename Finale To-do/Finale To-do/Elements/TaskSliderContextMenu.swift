//
//  TaskSliderContextMenu.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/20/22.
//

import Foundation
import UIKit

class TaskSliderContextMenu: UIViewController, UITextViewDelegate {
    
    let indexPath: IndexPath
    
    let padding = 16.0
    let spacing = 8.0
    var rowHeight: CGFloat!
    let fontSize = 14.0
    
    let slider: TaskSlider
    
    var containerView: UIView!
    var inputField: UITextView!
    
    let notesPlaceholder = "Add any notes here"
    
    init(slider: TaskSlider, indexPath: IndexPath) {
        self.indexPath = indexPath
        self.slider = slider
        
        super.init(nibName: nil, bundle: nil)
        
        
        let sliderView = TaskSlider(task: slider.task, frame: slider.frame, sliderColor: slider.sliderColor, app: slider.app)
        sliderView.frame.origin = CGPoint(x: 0, y: 0)
        
        let rowWidth = slider.frame.width
        let titleWidth = "Notifications:".size(withAttributes:[.font: UIFont.systemFont(ofSize: fontSize, weight: .bold)]).width
        rowHeight = "Notifications:".size(withAttributes:[.font: UIFont.systemFont(ofSize: fontSize, weight: .bold)]).height
        
        let row1 = CreateRow(title: "Task", content: taskNameContent, fullFrameWidth: rowWidth-padding*2, prevFrame: sliderView.frame, titleWidth: titleWidth)
        
        let row2 = CreateRow(title: "List", content: listNameContent, fullFrameWidth: rowWidth-padding*2, prevFrame: row1.frame, titleWidth: titleWidth)
        
        let row3 = CreateRow(title: "Priority", content: priorityContent, fullFrameWidth: rowWidth-padding*2, prevFrame: row2.frame, titleWidth: titleWidth)
        
        let row4 = CreateRow(title: "Due", content: dueContent, fullFrameWidth: rowWidth-padding*2, prevFrame: row3.frame, titleWidth: titleWidth)
        
        let row5: UIView
        if !slider.task.isCompleted {
            row5 = CreateRow(title: "Notifications", content: notificationContent, fullFrameWidth: rowWidth-padding*2, prevFrame: row4.frame, titleWidth: titleWidth)
        } else {
            row5 = CreateRow(title: "Completed", content: completedOnContent, fullFrameWidth: rowWidth-padding*2, prevFrame: row4.frame, titleWidth: titleWidth)
        }
        
        let notesArea = CreateNotesArea(prevFrameMaxY: row5.frame.maxY)
        
        containerView = UIView(frame: CGRect(x: 0, y: 0, width: slider.frame.width, height: notesArea.frame.maxY + padding))
        containerView.layer.cornerRadius = 10
        containerView.addSubview(sliderView)
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
        
        let textBackgroundView = UIView(frame: CGRect(x: 0, y: titleLabel.frame.maxY + spacing*0.5, width: containerView.frame.width, height: containerView.frame.height - titleLabel.frame.size.height-spacing*0.5))
        textBackgroundView.layer.cornerRadius = 10
        
        inputField = UITextView(frame: CGRect(x: spacing, y: 0, width: textBackgroundView.frame.width-spacing*2, height: textBackgroundView.frame.height))
        inputField.text = slider.task.notes == "" ? notesPlaceholder : slider.task.notes
        inputField.textColor = slider.task.notes == "" ? .systemGray2 : .label
        inputField.delegate = self
        inputField.font = UIFont.systemFont(ofSize: fontSize)
        textBackgroundView.backgroundColor = inputField.backgroundColor
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(textBackgroundView)
        
        textBackgroundView.addSubview(inputField)
        
        return containerView
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == notesPlaceholder {
            textView.text = ""
            textView.textColor = .label
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = notesPlaceholder
            textView.textColor = .systemGray2
        }
    }
    @objc func TapOutside () {
        inputField.resignFirstResponder()
        slider.taskNameInputField.resignFirstResponder()
    }
    
    
    func CreateRow (title: String, content: NSMutableAttributedString, fullFrameWidth: CGFloat, prevFrame: CGRect, titleWidth: CGFloat) -> UIView {
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
    
    var taskNameContent: NSMutableAttributedString {
        return NSMutableAttributedString(string: slider.task.name)
    }
    
    var listNameContent: NSMutableAttributedString {
        if slider.task.taskListID == App.mainTaskList.id { return NSMutableAttributedString(string: App.mainTaskList.name) }
        
        for taskList in App.userTaskLists {
            if slider.task.taskListID == taskList.id { return NSMutableAttributedString(string: taskList.name) }
        }
        
        return NSMutableAttributedString(string: "No list")
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
    
    var priorityContent: NSMutableAttributedString {
        return NSMutableAttributedString(string: slider.task.priority == .Regular ? "Normal" : "High")
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
        
        UIView.animate(withDuration: 0.25) { [self] in
            containerView.frame.origin.x = 0.5*(UIScreen.main.bounds.width-view.frame.width)
            containerView.frame.origin.y = handle.frame.maxY + padding
        }
        
        let closeButton = UIButton(frame: CGRect(x: padding, y: containerView.frame.maxY + padding, width: UIScreen.main.bounds.width-padding*2, height: 40))
        closeButton.backgroundColor = slider.sliderColor
        closeButton.layer.cornerRadius = 10
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.systemGray, for: .highlighted)
        closeButton.tintColor = .white
        closeButton.addTarget(self, action: #selector(CloseButton), for: .touchUpInside)
        
        self.view.addSubview(closeButton)
        self.view.addSubview(handle)
        
        slider.StartEditing(focusTextField: false)
    }
    
    @objc func CloseButton () {
        Dismiss()
    }
    
    func Dismiss () {
        SaveChanges()
        self.modalTransitionStyle = .coverVertical
        self.dismiss(animated: true)
    }
    
    func SaveChanges () {
        if inputField.text != notesPlaceholder {
            slider.task.notes = inputField.text
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
