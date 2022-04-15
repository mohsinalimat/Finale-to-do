//
//  AddTaskButton.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/15/22.
//

import Foundation
import UIKit

class AddTaskButton: UIView {
    
    init(frame: CGRect, color: UIColor) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = frame.height*0.5
        self.backgroundColor = color
        
        let lineWidth = frame.width*0.07
        let lineHeight = frame.height*0.6
        let verticalLine = UIView(frame: CGRect(x: 0.5*(frame.width-lineWidth), y: 0.5*(frame.height-lineHeight), width: lineWidth, height: lineHeight))
        verticalLine.layer.cornerRadius = lineWidth*0.5
        verticalLine.backgroundColor = color.lerp(second: .white, percentage: 0.7)
        
        let horizontalLine = UIView(frame: CGRect(x: 0.5*(frame.width-lineHeight), y: 0.5*(frame.height-lineWidth), width: lineHeight, height: lineWidth))
        horizontalLine.layer.cornerRadius = lineWidth*0.5
        horizontalLine.backgroundColor = color.lerp(second: .white, percentage: 0.7)
        
        self.addSubview(verticalLine)
        self.addSubview(horizontalLine)
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
