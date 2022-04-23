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
    var color: UIColor!
    
    init(frame: CGRect, color: UIColor, app: App) {
        self.app = app
        self.originalSize = frame.size
        self.color = color
        super.init(frame: frame)
        
        self.layer.cornerRadius = frame.height*0.5
        self.backgroundColor = AppColors.actionButtonTaskListColor(taskListColor: color)
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(CreateNewTask))
        self.addGestureRecognizer(tapGesture)
    }
    
    func ReloadVisuals(color: UIColor) {
        self.color = AppColors.actionButtonTaskListColor(taskListColor: color)
        self.backgroundColor = self.color
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
    
    func SetThemeColors() {
        UIView.animate(withDuration: 0.25) { [self] in
            self.backgroundColor = AppColors.actionButtonTaskListColor(taskListColor: color)
        }
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
