//
//  UndoButton.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/19/22.
//

import Foundation
import UIKit

class UndoButton: UIView, UIDynamicTheme {
    
    let originalSize: CGSize
    
    var tasklistColor: UIColor!
    
    init(frame: CGRect, tasklistColor: UIColor) {
        self.originalSize = frame.size
        self.tasklistColor = tasklistColor
        super.init(frame: frame)
        
        self.layer.cornerRadius = frame.height*0.5
        self.backgroundColor = ThemeManager.currentTheme.primaryElementColor(tasklistColor: tasklistColor)
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize.zero
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        imageView.image = UIImage(systemName: "arrow.uturn.left", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(UndoTask))
        self.addGestureRecognizer(tapGesture)
        
        self.addSubview(imageView)
    }
    
    func ReloadVisuals(color: UIColor) {
        self.tasklistColor = color
        self.backgroundColor = ThemeManager.currentTheme.primaryElementColor(tasklistColor: tasklistColor)
    }
    
    @objc func UndoTask(sender: UITapGestureRecognizer) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        })
        App.instance.UndoAction()
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
