//
//  UndoButton.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/19/22.
//

import Foundation
import UIKit

class UndoButton: UIView {
    
    let originalSize: CGSize
    
    init(frame: CGRect, color: UIColor) {
        self.originalSize = frame.size
        super.init(frame: frame)
        
        self.layer.cornerRadius = frame.height*0.5
        self.backgroundColor = color
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize.zero
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        imageView.image = UIImage(systemName: "arrow.uturn.left", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
        imageView.tintColor = color.lerp(second: .white, percentage: 0.7)
        imageView.contentMode = .scaleAspectFit
        imageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(UndoTask))
        self.addGestureRecognizer(tapGesture)
        
        self.addSubview(imageView)
    }
    
    func ReloadVisuals(color: UIColor) {
        self.backgroundColor = color
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
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
