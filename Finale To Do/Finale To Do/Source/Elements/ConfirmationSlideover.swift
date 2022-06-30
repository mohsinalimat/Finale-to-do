//
//  ConfirmationSlideover.swift
//  Finale To-do
//
//  Created by Grant Oganyan on 4/20/22.
//

import Foundation
import UIKit

class ConfirmationSlideover: UIViewController, UIDynamicTheme {
    
    let padding = 16.0
    let confirmAction: () -> Void
    var confirmActionColor: UIColor?
    
    let confirmButton = UIButton()
    
    init (title: String, description: String, confirmActionTitle: String, confirmActionColor: UIColor? = nil, cancelActionTitle: String = "Cancel", confirmAction: @escaping () -> Void) {
        self.confirmAction = confirmAction
        self.confirmActionColor = confirmActionColor
        
        super.init(nibName: nil, bundle: nil)
        self.overrideUserInterfaceStyle = App.settingsConfig.interface == .System ? .unspecified : App.settingsConfig.interface == .Light ? .light : .dark
        self.isModalInPresentation = true
        self.modalPresentationStyle = .formSheet
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TapCancel)))
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        containerView.layer.cornerRadius = AppConfiguration.slideoverCornerRadius
        containerView.AddStandardShadow()
        
        let blurEffect = UIVisualEffectView(frame: CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height))
        blurEffect.effect = UIBlurEffect(style: .systemUltraThinMaterial)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: containerView.layer.cornerRadius).cgPath
        blurEffect.layer.mask = shapeLayer
        
        let titleLabel = UILabel(frame: CGRect(x: padding, y: padding, width: containerView.frame.width-padding*2, height: 20))
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.text = title
        
        let descriptionLabel = UILabel(frame: CGRect(x: padding, y: titleLabel.frame.maxY + padding, width: containerView.frame.width-padding*2, height: 0))
        descriptionLabel.textColor = .label
        descriptionLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = description
        descriptionLabel.sizeToFit()
        descriptionLabel.frame.origin.x = 0.5*(containerView.frame.width - descriptionLabel.frame.width)
        
        let buttonHeight = 40.0
        
        confirmButton.frame = CGRect(x: padding, y:  descriptionLabel.frame.maxY + padding*2, width: containerView.frame.width-padding*2, height: buttonHeight)
        confirmButton.backgroundColor = confirmActionColor ?? ThemeManager.currentTheme.primaryElementColor()
        confirmButton.setTitle(confirmActionTitle, for: .normal)
        confirmButton.setTitleColor(UIColor.systemGray, for: .highlighted)
        confirmButton.layer.cornerRadius = 8
        confirmButton.addTarget(self, action: #selector(TapConfirm), for: .touchUpInside)
        confirmButton.titleLabel?.font = .Rubik(size: 18)
        
        let cancelButton = UIButton(frame: CGRect(x: padding, y: confirmButton.frame.maxY, width: containerView.frame.width-padding*2, height: buttonHeight))
        cancelButton.setTitle(cancelActionTitle, for: .normal)
        cancelButton.setTitleColor(UIColor.systemGray, for: .highlighted)
        cancelButton.setTitleColor(UIColor.label, for: .normal)
        cancelButton.addTarget(self, action: #selector(TapCancel), for: .touchUpInside)
        cancelButton.titleLabel?.font = .Rubik(size: 16)
        
        containerView.addSubview(blurEffect)
        self.view.addSubview(containerView)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(confirmButton)
        containerView.addSubview(cancelButton)
        containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: nil)) //Prevents touches inside the container
        
        containerView.frame.origin.y = UIScreen.main.bounds.height - UIApplication.shared.windows.first!.safeAreaInsets.bottom - cancelButton.frame.maxY - padding*4
    }
    
    @objc func TapConfirm () {
        confirmAction()
        Dismiss()
    }
    @objc func TapCancel () {
        Dismiss()
    }
    
    func Dismiss() {
        self.dismiss(animated: true)
    }
    
    func ReloadThemeColors() {
        self.overrideUserInterfaceStyle = App.settingsConfig.interface == .System ? .unspecified : App.settingsConfig.interface == .Light ? .light : .dark
        UIView.animate(withDuration: 0.25) { [self] in
            confirmButton.backgroundColor = confirmActionColor ?? ThemeManager.currentTheme.primaryElementColor()
        }
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        ThemeManager.currentTheme = App.settingsConfig.GetCurrentTheme()
        ReloadThemeColors()
        App.instance.SetSubviewColors(of: self.view)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
