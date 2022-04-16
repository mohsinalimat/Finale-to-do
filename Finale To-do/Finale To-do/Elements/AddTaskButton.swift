//
//  AddTaskButton.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/15/22.
//

import Foundation
import UIKit

class AddTaskButton: UIView {
    
    var verticalLine: UIView!
    var horizontalLine: UIView!
    var colorPanel: UIView!
    
    init(frame: CGRect, color: UIColor) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = frame.height*0.5
        
        let blur = UIVisualEffectView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        blur.effect = UIBlurEffect(style: .systemUltraThinMaterial)
        blur.layer.cornerRadius = frame.height*0.5
        blur.clipsToBounds = true
        self.addSubview(blur)
        
        colorPanel = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        colorPanel.backgroundColor = App.selectedTaskListIndex == 0 ? .defaultColor : color
        colorPanel.layer.compositingFilter = UITraitCollection.current.userInterfaceStyle == .light ? "multiplyBlendMode" : "screenBlendMode"
        colorPanel.layer.opacity = UITraitCollection.current.userInterfaceStyle == .light ? 1 : 0.8
        colorPanel.layer.cornerRadius = frame.height*0.5
        self.addSubview(colorPanel)
        
        
        let lineWidth = frame.width*0.07
        let lineHeight = frame.height*0.6
        verticalLine = UIView(frame: CGRect(x: 0.5*(frame.width-lineWidth), y: 0.5*(frame.height-lineHeight), width: lineWidth, height: lineHeight))
        verticalLine.layer.cornerRadius = lineWidth*0.5
        verticalLine.backgroundColor = color.lerp(second: .white, percentage: 0.7)
        
        horizontalLine = UIView(frame: CGRect(x: 0.5*(frame.width-lineHeight), y: 0.5*(frame.height-lineWidth), width: lineHeight, height: lineWidth))
        horizontalLine.layer.cornerRadius = lineWidth*0.5
        horizontalLine.backgroundColor = color.lerp(second: .white, percentage: 0.7)
        
        self.addSubview(verticalLine)
        self.addSubview(horizontalLine)
    }
    
    func ReloadVisuals(color: UIColor) {
        verticalLine.backgroundColor = color.lerp(second: .white, percentage: 0.7)
        horizontalLine.backgroundColor = color.lerp(second: .white, percentage: 0.7)
        
        colorPanel.backgroundColor = App.selectedTaskListIndex == 0 ? .defaultColor : color
        colorPanel.layer.compositingFilter = UITraitCollection.current.userInterfaceStyle == .light ? "multiplyBlendMode" : "screenBlendMode"
        colorPanel.layer.opacity = UITraitCollection.current.userInterfaceStyle == .light ? 1 : 0.8
    }
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
