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
    
    let colorLayer = UIView()
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
        
        let iphoneFrameWidth = screenshotWidth*1.3
        let iphoneFrameHeight = screenshotHeight*1.3
        let iphoneFrameView = UIImageView(frame: CGRect(x: 0.5*(width-iphoneFrameWidth), y: padding + 0.5*(screenshotHeight-iphoneFrameHeight), width: iphoneFrameWidth, height: iphoneFrameHeight))
        iphoneFrameView.image = UIImage(named: "iPhone Frame")
        iphoneFrameView.contentMode = .scaleAspectFit
        colorLayer.frame = iphoneFrameView.frame
        colorLayer.layer.compositingFilter = "multiplyBlendMode"
        colorLayer.backgroundColor = ThemeManager.currentTheme.primaryElementColor()
        let mask = UIImageView(image: UIImage(named: "iPhone Frame"))
        mask.frame = CGRect(x: 0, y: 0, width: colorLayer.frame.width, height: colorLayer.frame.height)
        mask.contentMode = .scaleAspectFit
        colorLayer.mask = mask
        
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
        
        scrollView.addSubview(screenshotView)
        scrollView.addSubview(iphoneFrameView)
        scrollView.addSubview(colorLayer)
        scrollView.addSubview(descriptionContainer)
        
        scrollView.contentSize.height = descriptionContainer.frame.maxY + padding*5
        
        self.view.addSubview(scrollView)
    }
    
    func ReloadThemeColors() {
        overrideUserInterfaceStyle = App.settingsConfig.interface == .System ? .unspecified : App.settingsConfig.interface == .Light ? .light : .dark
        UIView.animate(withDuration: 0.25) { [self] in
            descriptionContainer.backgroundColor = ThemeManager.currentTheme.settingsRowBackgroundColor
            colorLayer.backgroundColor = ThemeManager.currentTheme.primaryElementColor()
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
