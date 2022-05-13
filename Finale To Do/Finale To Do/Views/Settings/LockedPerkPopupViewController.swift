//
//  LevelLockedViewController.swift
//  Finale To Do
//
//  Created by Grant Oganan on 5/11/22.
//

import Foundation
import UIKit


class LockedPerkPopupViewController: UIViewController {
    
    let padding = 20.0
    
    let containerView = UIView()
    let parentVC: UIViewController?
    
    init(warningText: String, coloredSubstring: String? = nil, parentVC: UIViewController? = nil) {
        self.parentVC = parentVC
        super.init(nibName: nil, bundle: nil)
        overrideUserInterfaceStyle = App.settingsConfig.interface == .System ? .unspecified : App.settingsConfig.interface == .Light ? .light : .dark
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Dismiss)))
        self.view.backgroundColor = .black.withAlphaComponent(0.3)
        
        
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        containerView.frame = CGRect(x: padding, y: 0, width: width-padding*2, height: 0)
        containerView.layer.cornerRadius = 16
        
        let warningLabel = UILabel(frame: CGRect(x: padding, y: padding, width: containerView.frame.width-padding*2, height: 0))
        warningLabel.attributedText = getWarningText(warningText: warningText, coloredSubstring: coloredSubstring)
        warningLabel.font = .preferredFont(forTextStyle: .headline)
        warningLabel.textAlignment = .center
        warningLabel.numberOfLines = 0
        warningLabel.sizeToFit()
        warningLabel.frame.origin.x = 0.5*(containerView.frame.width - warningLabel.frame.width)
        
        let openProfileButton = UIButton(frame: CGRect(x: padding*3, y: warningLabel.frame.maxY+padding, width: containerView.frame.width-padding*6, height: 40.0))
        openProfileButton.backgroundColor = ThemeManager.currentTheme.primaryElementColor()
        openProfileButton.setTitle("Go to my profile", for: .normal)
        openProfileButton.setTitleColor(UIColor.systemGray, for: .highlighted)
        openProfileButton.layer.cornerRadius = 8
        openProfileButton.addTarget(self, action: #selector(GoToProfile), for: .touchUpInside)
        
        let dismissButton = UIButton(frame: CGRect(x: padding*3, y: openProfileButton.frame.maxY, width: containerView.frame.width-padding*6, height: 40.0))
        dismissButton.setTitle("Dismiss", for: .normal)
        dismissButton.setTitleColor(UIColor.systemGray, for: .highlighted)
        dismissButton.layer.cornerRadius = 8
        dismissButton.titleLabel?.font = .preferredFont(forTextStyle: .subheadline)
        dismissButton.addTarget(self, action: #selector(Dismiss), for: .touchUpInside)
        dismissButton.setTitleColor(.label, for: .normal)
        
        containerView.frame.size.height = (dismissButton.frame.maxY+padding) - (warningLabel.frame.minY-padding)
        containerView.frame.origin.y = 0.5*(height-containerView.frame.size.height)
        
        let blurEffect1 = UIVisualEffectView(frame: CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height))
        blurEffect1.effect = UIBlurEffect(style: .systemUltraThinMaterial)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: containerView.layer.cornerRadius).cgPath
        blurEffect1.layer.mask = shapeLayer
        containerView.addSubview(blurEffect1)
        containerView.layer.shadowOffset = CGSize.zero
        containerView.layer.shadowRadius = 15
        containerView.layer.shadowOpacity = 0.3
        containerView.addGestureRecognizer(UITapGestureRecognizer()) // this way I am blocking dismissing when tapped on the container
        
        containerView.addSubview(warningLabel)
        containerView.addSubview(openProfileButton)
        containerView.addSubview(dismissButton)
        
        self.view.addSubview(containerView)
        
        ShowView()
    }
    
    @objc func Dismiss () {
        HideView()
    }
    @objc func GoToProfile() {
        Dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {[self] in
            parentVC?.show(UserProfileNavigationController(), sender: nil)
        }
    }
    
    func ShowView () {
        self.view.alpha = 0
        containerView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                self.view.alpha = 1
                self.containerView.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        }
    }
    func HideView () {
        UIView.animate(withDuration: 0.2, animations: {
            self.view.alpha = 0
            self.containerView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: {_ in
            self.dismiss(animated: false)
        })
    }
    
    func getWarningText(warningText: String, coloredSubstring: String? = nil) -> NSMutableAttributedString {
        let mutableAttributedString = NSMutableAttributedString.init(string: warningText)
        
        if coloredSubstring == nil { return mutableAttributedString }
        
        let range = (warningText as NSString).range(of: coloredSubstring!)
        
        mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: ThemeManager.currentTheme.primaryElementColor(), range: range)
        return mutableAttributedString
    }
    
    
    
    
    
    
    
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
