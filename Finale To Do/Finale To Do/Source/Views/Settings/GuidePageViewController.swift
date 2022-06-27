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
    
    let iphoneFrameView = UIView()
    let descriptionContainer = UIView()
    
    init(titleText: String, descriptionText: String) {
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = ThemeManager.currentTheme.settingsBackgroundColor
        overrideUserInterfaceStyle = App.settingsConfig.interface == .System ? .unspecified : App.settingsConfig.interface == .Light ? .light : .dark
        
        self.title = titleText
        
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        
        let screenshotWidth: CGFloat = width*0.5
        let screenshotHeight: CGFloat = screenshotWidth*19.5/9.0
        
        let screenshotView = UIImageView(frame: CGRect(x: 0.5*(width-screenshotWidth), y: padding, width: screenshotWidth, height: screenshotHeight))
        screenshotView.image = UIImage(named: titleText)
        screenshotView.contentMode = .scaleAspectFit
        screenshotView.layer.cornerRadius = 20
        screenshotView.clipsToBounds = true
        
        let iphoneFrameSize = 8.0
        let iphoneFrameWidth = screenshotWidth + iphoneFrameSize*2
        let iphoneFrameHeight = screenshotHeight + iphoneFrameSize*2
        
        iphoneFrameView.frame = CGRect(x: 0.5*(width-iphoneFrameWidth), y: padding + 0.5*(screenshotHeight-iphoneFrameHeight), width: iphoneFrameWidth, height: iphoneFrameHeight)
        iphoneFrameView.layer.cornerRadius = 26
        iphoneFrameView.backgroundColor = ThemeManager.currentTheme.primaryElementColor()
        
        descriptionContainer.frame = CGRect(x: padding, y: screenshotView.frame.maxY+padding*2, width: width-padding*2, height: 0)
        descriptionContainer.layer.cornerRadius = 12
        descriptionContainer.backgroundColor = ThemeManager.currentTheme.settingsRowBackgroundColor
        
        let descriptionLabel = UILabel(frame: CGRect(x: padding, y: padding, width: descriptionContainer.frame.width-padding*2, height: 0))
        descriptionLabel.text = descriptionText
        descriptionLabel.font = .preferredFont(forTextStyle: .body)
        descriptionLabel.textAlignment = .left
        descriptionLabel.numberOfLines = 0
        descriptionLabel.sizeToFit()
        
        descriptionContainer.addSubview(descriptionLabel)
        descriptionContainer.frame.size.height = descriptionLabel.frame.height+padding*2
        
        scrollView.addSubview(iphoneFrameView)
        scrollView.addSubview(screenshotView)
        scrollView.addSubview(descriptionContainer)
        
        scrollView.contentSize.height = descriptionContainer.frame.maxY + padding*5
        
        self.view.addSubview(scrollView)
    }
    
    func ReloadThemeColors() {
        overrideUserInterfaceStyle = App.settingsConfig.interface == .System ? .unspecified : App.settingsConfig.interface == .Light ? .light : .dark
        UIView.animate(withDuration: 0.25) { [self] in
            descriptionContainer.backgroundColor = ThemeManager.currentTheme.settingsRowBackgroundColor
            iphoneFrameView.backgroundColor = ThemeManager.currentTheme.primaryElementColor()
            self.view.backgroundColor = ThemeManager.currentTheme.settingsBackgroundColor
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        ThemeManager.currentTheme = App.settingsConfig.GetCurrentTheme()
        App.instance.SetSubviewColors(of: self.view)
        ReloadThemeColors()
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsHelper.LogGuideOpen(page: self.title ?? "Unknown Guide Page")
    }
    
}
