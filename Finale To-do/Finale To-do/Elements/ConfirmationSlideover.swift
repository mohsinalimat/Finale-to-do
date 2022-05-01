//
//  ConfirmationSlideover.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/20/22.
//

import Foundation
import UIKit

class ConfirmationSlideover: UIView, UIDynamicTheme {
    
    let slideOverHeight = 200.0
    let padding = 16.0
    
    var blackoutView: UIView!
    var containerView: UIView!
    var confirmButton: UIButton!
    let confirmAction: () -> Void
    
    init(title: String, subTitle: String, confirmActionTitle: String, confirmAction: @escaping () -> Void) {
        self.confirmAction = confirmAction
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        
        blackoutView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        blackoutView.backgroundColor = .black
        blackoutView.alpha = 0
        blackoutView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Cancel)))
        
        containerView = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height+10, width: UIScreen.main.bounds.width, height: slideOverHeight))
        containerView.backgroundColor = ThemeManager.currentTheme.tintedBackgroundColor
        containerView.layer.cornerRadius = AppConfiguration.slideoverCornerRadius
        containerView.AddStandardShadow()
        
        let titleLabel = UILabel(frame: CGRect(x: padding, y: padding, width: UIScreen.main.bounds.width-padding*2, height: 20))
        titleLabel.text = title
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        
        let subtitleLabel = UILabel(frame: CGRect(x: padding, y: titleLabel.frame.maxY+padding*0.5, width: UIScreen.main.bounds.width-padding*2, height: 30))
        subtitleLabel.text = subTitle
        subtitleLabel.textColor = .systemGray
        subtitleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        subtitleLabel.textAlignment = .center
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        
        let buttonHeight = 40.0
        let buttonWidth = 0.5*(containerView.frame.width-padding*3)
        let cancelButton = UIButton(frame: CGRect(x: padding, y: subtitleLabel.frame.maxY + padding, width: buttonWidth, height: buttonHeight))
        cancelButton.backgroundColor = .systemGray2
        cancelButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        cancelButton.setTitle(" Cancel", for: .normal)
        cancelButton.setTitleColor(.systemGray, for: .highlighted)
        cancelButton.layer.cornerRadius = 10
        cancelButton.tintColor = .white
        cancelButton.addTarget(self, action: #selector(Cancel), for: .touchUpInside)
        
        confirmButton = UIButton(frame: CGRect(x: padding*2+buttonWidth, y: cancelButton.frame.origin.y, width: buttonWidth, height: buttonHeight))
        confirmButton.backgroundColor = AppColors.actionButtonDestructiveColor
        confirmButton.setImage(UIImage(systemName: "trash"), for: .normal)
        confirmButton.setTitle(confirmActionTitle, for: .normal)
        confirmButton.setTitleColor(.systemGray, for: .highlighted)
        confirmButton.tintColor = .white
        confirmButton.layer.cornerRadius = 10
        confirmButton.imageView?.contentMode = .scaleAspectFit
        confirmButton.addTarget(self, action: #selector(Confirm), for: .touchUpInside)
        
        containerView.addSubview(cancelButton)
        containerView.addSubview(confirmButton)
        
        self.addSubview(blackoutView)
        self.addSubview(containerView)
        
        ShowView()
    }
    
    func ShowView() {
        App.instance.ZoomOutContainterView()
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) { [self] in
            blackoutView.alpha = 0.5
            containerView.frame.origin.y = UIScreen.main.bounds.height - containerView.frame.size.height
        }
    }
    
    func Dismiss () {
        App.instance.ZoomInContainterView()
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: { [self] in
            blackoutView.alpha = 0
            containerView.frame.origin.y = UIScreen.main.bounds.height + 10
        }, completion: {_ in
            self.removeFromSuperview()
        })
    }
    
    @objc func Cancel () {
        Dismiss()
    }
    
    @objc func Confirm () {
        confirmAction()
        Dismiss()
    }
    
    func ReloadThemeColors() {
        UIView.animate(withDuration: 0.25) { [self] in 
            containerView.backgroundColor = ThemeManager.currentTheme.tintedBackgroundColor
            confirmButton.backgroundColor = AppColors.actionButtonDestructiveColor
        }
    }
    
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
