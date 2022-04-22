//
//  CalendarView.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/19/22.
//

import Foundation
import UIKit

class CalendarView: UIView, UIDynamicTheme {
    
    let padding = 16.0
    
    var confirmButton: UIButton!
    var containerView: UIView!
    var calendarView: UIDatePicker!
    
    let taskSlider: TaskSlider
    
    init(frameSize: CGSize, tintColor: UIColor, taskSlider: TaskSlider) {
        self.taskSlider = taskSlider
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        
        let blurEffect = UIVisualEffectView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        blurEffect.effect = UIBlurEffect(style: .systemUltraThinMaterial)
        blurEffect.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(HideViewNoAction)))
        self.backgroundColor = .black.withAlphaComponent(0.2)
        self.addSubview(blurEffect)
        
        
        containerView = UIView (frame: CGRect(x: 0.5*(UIScreen.main.bounds.width-frameSize.width), y: 0.5*(UIScreen.main.bounds.height-frameSize.height), width: frameSize.width, height: frameSize.height))
        containerView.layer.cornerRadius = 20
        containerView.layer.shadowOffset = CGSize.zero
        containerView.layer.shadowRadius = 20
        containerView.layer.shadowOpacity = 0.5
        
        let blurEffect2 = UIVisualEffectView(frame: CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height))
        blurEffect2.effect = UIBlurEffect(style: .systemUltraThinMaterial)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: 20).cgPath
        blurEffect2.layer.mask = shapeLayer
        
        containerView.addSubview(blurEffect2)
        
        
        calendarView = UIDatePicker()
        calendarView.preferredDatePickerStyle = .inline
        calendarView.frame = CGRect(x: padding, y: padding, width: containerView.frame.width-padding*2, height: containerView.frame.height-padding*2)
        calendarView.tintColor = tintColor
        calendarView.datePickerMode = .date
        
        containerView.addSubview(calendarView)
        
        let buttonHeight = 40.0
        let buttonWidth = 0.5*(containerView.frame.width-padding*3)
        let clearButton = UIButton(frame: CGRect(x: padding, y: containerView.frame.height - padding - buttonHeight, width: buttonWidth, height: buttonHeight))
        clearButton.backgroundColor = .systemGray2
        clearButton.setTitle(" Clear", for: .normal)
        clearButton.setTitleColor(.systemGray, for: .highlighted)
        clearButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        clearButton.tintColor = .white
        clearButton.layer.cornerRadius = 10
        clearButton.addTarget(self, action: #selector(Clear), for: .touchUpInside)
        
        confirmButton = UIButton(frame: CGRect(x: padding*2+buttonWidth, y: containerView.frame.height - padding - buttonHeight, width: buttonWidth, height: buttonHeight))
        confirmButton.backgroundColor = tintColor
        confirmButton.setTitle(" Assign", for: .normal)
        confirmButton.setTitleColor(.systemGray, for: .highlighted)
        confirmButton.setImage(UIImage(systemName: "calendar"), for: .normal)
        confirmButton.tintColor = .white
        confirmButton.layer.cornerRadius = 10
        confirmButton.addTarget(self, action: #selector(Confirm), for: .touchUpInside)
        
        containerView.addSubview(clearButton)
        containerView.addSubview(confirmButton)
        
        self.addSubview(containerView)
        
        ShowView()
    }
    
    func ShowView () {
        self.alpha = 0
        containerView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1
            self.containerView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    func HideView () {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
            self.containerView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: {_ in
            self.removeFromSuperview()
        })
    }
    
    @objc func Clear () {
        HideView()
        taskSlider.ClearDate()
    }
    
    @objc func Confirm () {
        HideView()
        let adjDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: calendarView.date)
        taskSlider.AddDate(date: adjDate!)
    }
    
    @objc func HideViewNoAction () {
        HideView()
        taskSlider.HideCalendarView()
    }
    
    func SetThemeColors() {
        let color: UIColor
        if App.selectedTaskListIndex == 0 { color = AppColors.actionButtonTaskListColor(taskListColor: .defaultColor) }
        else if App.selectedTaskListIndex == 1 { color = AppColors.actionButtonTaskListColor(taskListColor: App.mainTaskList.primaryColor) }
        else { color = AppColors.actionButtonTaskListColor(taskListColor: App.userTaskLists[App.selectedTaskListIndex-2].primaryColor) }
        
        UIView.animate(withDuration: 0.25) { [self] in
            calendarView.tintColor = color
            confirmButton.backgroundColor = color
        }
    }
    
    
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
