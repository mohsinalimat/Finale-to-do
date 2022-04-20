//
//  CalendarView.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/19/22.
//

import Foundation
import UIKit

class CalendarView: UIView {
    
    let padding = 16.0
    
    var containerView: UIView!
    var calendarView: UIDatePicker!
    
    let taskSlider: TaskSlider
    
    init(frameSize: CGSize, tintColor: UIColor, taskSlider: TaskSlider) {
        self.taskSlider = taskSlider
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        
        let blurEffect = UIVisualEffectView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        blurEffect.effect = UIBlurEffect(style: .systemUltraThinMaterial)
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
        clearButton.backgroundColor = .systemGray
        clearButton.setTitle("Clear", for: .normal)
        clearButton.layer.cornerRadius = 10
        clearButton.addTarget(self, action: #selector(Clear), for: .touchUpInside)
        
        let confirmButton = UIButton(frame: CGRect(x: padding*2+buttonWidth, y: containerView.frame.height - padding - buttonHeight, width: buttonWidth, height: buttonHeight))
        confirmButton.backgroundColor = tintColor
        confirmButton.setTitle("Assign date", for: .normal)
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
        taskSlider.AddDate(date: calendarView.date)
    }
    
    
    
    
    
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
