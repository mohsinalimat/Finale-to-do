//
//  AddTaskButton.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/15/22.
//

import Foundation
import UIKit

class AddTaskButton: UIView {
    
    let app: App
    var verticalLine: UIView!
    var horizontalLine: UIView!
    
    let originalSize: CGSize
    
    init(frame: CGRect, color: UIColor, app: App) {
        self.app = app
        self.originalSize = frame.size
        super.init(frame: frame)
        
        self.layer.cornerRadius = frame.height*0.5
        self.backgroundColor = color
        self.layer.shadowRadius = 7
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize.zero
        
        let lineWidth = frame.width*0.07
        let lineHeight = frame.height*0.5
        verticalLine = UIView(frame: CGRect(x: 0.5*(frame.width-lineWidth), y: 0.5*(frame.height-lineHeight), width: lineWidth, height: lineHeight))
        verticalLine.layer.cornerRadius = lineWidth*0.5
        verticalLine.backgroundColor = color.lerp(second: .white, percentage: 0.7)
        
        horizontalLine = UIView(frame: CGRect(x: 0.5*(frame.width-lineHeight), y: 0.5*(frame.height-lineWidth), width: lineHeight, height: lineWidth))
        horizontalLine.layer.cornerRadius = lineWidth*0.5
        horizontalLine.backgroundColor = color.lerp(second: .white, percentage: 0.7)
        
        self.addSubview(verticalLine)
        self.addSubview(horizontalLine)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(CreateNewTask))
        self.addGestureRecognizer(tapGesture)
    }
    
    func ReloadVisuals(color: UIColor) {
        verticalLine.backgroundColor = color.lerp(second: .white, percentage: 0.7)
        horizontalLine.backgroundColor = color.lerp(second: .white, percentage: 0.7)
        self.backgroundColor = color
    }
    
    @objc func CreateNewTask(sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        })
        app.CreateNewTask(sender: sender)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
