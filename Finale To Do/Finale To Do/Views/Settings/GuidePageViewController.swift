//
//  GuidePageViewController.swift
//  Finale To Do
//
//  Created by Grant Oganan on 5/10/22.
//

import Foundation
import UIKit
import AVFoundation



class GuidePageViewController: UIViewController, UIDynamicTheme {
    
    let padding = 16.0
    
    init(titleText: String, descriptionText: String) {
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = ThemeManager.currentTheme.settingsBackgroundColor
        overrideUserInterfaceStyle = App.settingsConfig.interface == .System ? .unspecified : App.settingsConfig.interface == .Light ? .light : .dark
        
        self.title = titleText
        
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        let screenshotWidth = width*0.8
        let screenshotHeight = height*0.5
        let screenshotView = UIImageView(frame: CGRect(x: 0.5*(width-screenshotWidth), y: padding*4, width: screenshotWidth, height: screenshotHeight))
        screenshotView.image = UIImage(named: titleText)
        screenshotView.contentMode = .scaleAspectFit
        
        let descriptionLabel = UILabel(frame: CGRect(x: padding, y: screenshotView.frame.maxY+padding, width: width-padding*2, height: 0))
        descriptionLabel.text = descriptionText
        descriptionLabel.font = .preferredFont(forTextStyle: .body)
        descriptionLabel.textAlignment = .left
        descriptionLabel.numberOfLines = 0
        descriptionLabel.sizeToFit()
        descriptionLabel.frame.origin.x = 0.5*(width-descriptionLabel.frame.width)
        
        self.view.addSubview(screenshotView)
        self.view.addSubview(descriptionLabel)
    }
    
    func ReloadThemeColors() {
        overrideUserInterfaceStyle = App.settingsConfig.interface == .System ? .unspecified : App.settingsConfig.interface == .Light ? .light : .dark
    }
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
