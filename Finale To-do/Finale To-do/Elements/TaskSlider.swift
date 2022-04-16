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
    
    let padding = 8.0
    let sliderCornerRadius = 10.0
    let sliderBackgroundColor = UIColor.systemGray6
    
    var sliderView: UIView
    var sliderHandle: UIView
    var taskNameInputField: UITextField
    
    let sliderHandleWidth: CGFloat
    let sliderHandleOriginX: CGFloat
    let fullSliderWidth: CGFloat
    
    let placeholders: [String] = ["Finish annual report", "Create images for the presentation", "Meditate", "Plan holidays with the family", "Help mom with groceries", "Buy new shoes", "Get cat food", "Get dog food", "Brush my corgie", "Say hi to QQ", "Chmok my QQ", "Buy airplane tickets", "Cancel streaming subscription", "Schedule coffee chat", "Schedule work meeting", "Dye my hair", "Download Elden Ring", "Get groceries"]
    
    init(task: Task, frame: CGRect, sliderColor: UIColor, app: App) {
        self.task = task
        self.app = app
        
        sliderHandleWidth = !task.isCompleted ? frame.width*0.08 : 0
        fullSliderWidth = frame.width
        
        taskNameInputField = UITextField(frame: CGRect(x: sliderHandleWidth+padding, y: 0, width: frame.width-sliderHandleWidth-padding, height: frame.height))
        
        sliderView = UIView(frame: CGRect(x: 0, y: 0, width: sliderHandleWidth, height: frame.height))
        
        sliderHandleOriginX = 2.5
        sliderHandle = UIView(frame: CGRect(x: sliderHandleOriginX, y: 2.5, width: sliderView.frame.width-5, height: sliderView.frame.height-5))
        
        super.init(frame: frame)
        
        let background = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        background.layer.cornerRadius = sliderCornerRadius
        background.backgroundColor = !task.isCompleted ? sliderBackgroundColor : sliderColor.secondaryColor.withAlphaComponent(sliderColor.secondaryColor.components.alpha*0.5)
        
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
        taskNameInputField.textColor = task.isCompleted ? .systemGray : .label
        taskNameInputField.isEnabled = isEditing
        
        sliderView.backgroundColor = sliderColor
        sliderView.layer.cornerRadius = sliderCornerRadius
        sliderView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(Dragging)))

        sliderHandle.backgroundColor = !task.isCompleted ? sliderColor.thirdColor : .clear
        sliderHandle.layer.cornerRadius = sliderCornerRadius*0.85
        sliderHandle.isUserInteractionEnabled = false
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(StartEditing))
        doubleTap.numberOfTapsRequired = 2
        
        addGestureRecognizer(doubleTap)
        
        addSubview(background)
        addSubview(sliderView)
        addSubview(sliderHandle)
        addSubview(taskNameInputField)
    }
    
    @objc func Dragging(sender: UIPanGestureRecognizer) {
        if sender.state == .changed {
            sliderView.frame.size.width = max(sliderHandleWidth, min(sender.translation(in: self).x + sliderHandleWidth, fullSliderWidth))
            sliderHandle.frame.origin.x = max(sliderHandleOriginX, min(sliderHandleOriginX + sender.translation(in: self).x, fullSliderWidth-sliderHandleWidth*0.925))
        } else if sender.state == .ended {
            if sender.velocity(in: self).x > 2200 {
                let duration = sender.velocity(in: self).x*0.00006
                UIView.animate(withDuration: duration) { [self] in
                    sliderView.frame.size.width = fullSliderWidth
                    sliderHandle.frame.origin.x = fullSliderWidth-sliderHandleWidth*0.925
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + duration*0.9) { [self] in
                    app.CompleteTask(task: task)
                }
            } else if sliderView.frame.size.width == fullSliderWidth {
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [self] in
            taskNameInputField.becomeFirstResponder()
        }
    }
    
    func StopEditing () {
        taskNameInputField.resignFirstResponder()
        isEditing = false
        taskNameInputField.isEnabled = false
        task.name = taskNameInputField.text!
        if taskNameInputField.text == "" {
            app.DeleteTask(task: task)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        StopEditing()
        return true
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
