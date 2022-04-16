//
//  TaskSlider.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/14/22.
//

import UIKit
import SwiftUI

class TaskSlider: UIView {
    
    let app: App
    
    var task: Task
    
    let padding = 8.0
    let sliderCornerRadius = 10.0
    let sliderBackgroundColor = UIColor.systemGray6
    
    var sliderView: UIView
    var sliderHandle: UIView
    var taskNameLabel: UILabel
    
    let sliderHandleWidth: CGFloat
    let sliderHandleOriginX: CGFloat
    let fullSliderWidth: CGFloat
    
    init(task: Task, frame: CGRect, sliderColor: UIColor, app: App) {
        self.task = task
        self.app = app
        
        sliderHandleWidth = !task.isCompleted ? frame.width*0.08 : 0
        fullSliderWidth = frame.width
        
        taskNameLabel = UILabel(frame: CGRect(x: sliderHandleWidth+padding, y: 0, width: frame.width-sliderHandleWidth-padding, height: frame.height))
        
        sliderView = UIView(frame: CGRect(x: 0, y: 0, width: sliderHandleWidth, height: frame.height))
        
        sliderHandleOriginX = sliderView.frame.width*0.075
        sliderHandle = UIView(frame: CGRect(x: sliderHandleOriginX, y: sliderView.frame.height*0.075, width: sliderView.frame.width*0.85, height: sliderView.frame.height*0.85))
        
        super.init(frame: frame)
        
        let background = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        background.layer.cornerRadius = sliderCornerRadius
        background.backgroundColor = !task.isCompleted ? sliderBackgroundColor : sliderColor.secondaryColor.withAlphaComponent(sliderColor.secondaryColor.components.alpha*0.5)
        
        let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: task.name)
        if task.isCompleted {
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSRange(location: 0, length: attributeString.length))
        }
        taskNameLabel.attributedText = attributeString
        taskNameLabel.textColor = !task.isCompleted ? .label : .systemGray
        
        sliderView.backgroundColor = sliderColor
        sliderView.layer.cornerRadius = sliderCornerRadius
        sliderView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(Dragging)))

        sliderHandle.backgroundColor = sliderColor.thirdColor
        sliderHandle.layer.cornerRadius = sliderCornerRadius*0.85
        sliderHandle.isUserInteractionEnabled = false
        
        addSubview(background)
        addSubview(sliderView)
        addSubview(sliderHandle)
        addSubview(taskNameLabel)
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
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [self] in
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
    
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class TaskSliderTableCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        isUserInteractionEnabled = true
    }
    
    func Setup(task: Task, sliderSize: CGSize, cellSize: CGSize, sliderColor: UIColor, app: App) {
        for subview in contentView.subviews {
            subview.removeFromSuperview()
        }
        contentView.addSubview(TaskSlider(
                task: task,
                frame: CGRect(x: 0.5*(cellSize.width - sliderSize.width), y: 0.5*(cellSize.height - sliderSize.height), width: sliderSize.width, height: sliderSize.height),
                sliderColor: sliderColor, app: app))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
