//
//  AddTaskButton.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/15/22.
//

import Foundation
import UIKit

class AddTaskButton: UIView, UIDynamicTheme {
    
    let app: App
    var verticalLine: UIView!
    var horizontalLine: UIView!
    
    let originalSize: CGSize
    var tasklistColor: UIColor!
    
    init(frame: CGRect, tasklistColor: UIColor, app: App) {
        self.app = app
        self.originalSize = frame.size
        self.tasklistColor = tasklistColor
        super.init(frame: frame)
        
        self.layer.cornerRadius = frame.height*0.5
        self.backgroundColor = ThemeManager.currentTheme.primaryElementColor(tasklistColor: tasklistColor)
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize.zero
        
        let lineWidth = frame.width*0.06
        let lineHeight = frame.height*0.45
        verticalLine = UIView(frame: CGRect(x: 0.5*(frame.width-lineWidth), y: 0.5*(frame.height-lineHeight), width: lineWidth, height: lineHeight))
        verticalLine.layer.cornerRadius = lineWidth*0.5
        verticalLine.backgroundColor = .white
        
        horizontalLine = UIView(frame: CGRect(x: 0.5*(frame.width-lineHeight), y: 0.5*(frame.height-lineWidth), width: lineHeight, height: lineWidth))
        horizontalLine.layer.cornerRadius = lineWidth*0.5
        horizontalLine.backgroundColor = .white
        
        self.addSubview(verticalLine)
        self.addSubview(horizontalLine)
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CreateNewTask)))
    }
    
    func ReloadVisuals(color: UIColor) {
        self.tasklistColor = color
        self.backgroundColor = ThemeManager.currentTheme.primaryElementColor(tasklistColor: tasklistColor)
    }
    
    @objc func CreateNewTask(sender: UITapGestureRecognizer) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        })
        app.CreateNewTask()
    }
    
    func ReloadThemeColors() {
        UIView.animate(withDuration: 0.25) { [self] in
            self.backgroundColor = ThemeManager.currentTheme.primaryElementColor(tasklistColor: tasklistColor)
        }
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
