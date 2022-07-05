//
//  AppearancePage.swift
//  Finale To Do
//
//  Created by Grant Oganan on 6/30/22.
//

import Foundation
import UIKit

class SettingsAppearancePage: SettingsPageViewController {
    override func GetSettings() -> [SettingsSection] {
        return [
            
            SettingsSection(options: [.segmentedControlCell(model: SettingsSegmentedControlOption(title: "Interface", items: [InterfaceMode(rawValue: 0)!.str, InterfaceMode(rawValue: 1)!.str, InterfaceMode(rawValue: 2)!.str], selectedItem: App.settingsConfig.interface.rawValue) { sender in
                
                self.SwitchInterface(mode: InterfaceMode(rawValue: sender.selectedSegmentIndex)!)
                
            })]),
            
            SettingsSection(title: "Light Theme", options: [.customViewCell(model: SettingsThemeView(type: .Light))], customHeight: SettingsThemeView.height),
            SettingsSection(title: "Dark Theme", options: [.customViewCell(model: SettingsThemeView(type: .Dark))], customHeight: SettingsThemeView.height),
            
            SettingsSection(title: "App Icon", options: [.customViewCell(model: SettingsAppIconView())], customHeight: SettingsAppIconView.height)
            
        ]
    }
    
    func SwitchInterface(mode: InterfaceMode) {
        App.settingsConfig.interface = mode
        
        App.instance.overrideUserInterfaceStyle = mode == .System ? .unspecified : mode == .Light ? .light : .dark
        navigationController?.overrideUserInterfaceStyle = App.instance.overrideUserInterfaceStyle
        
        let navController = navigationController as? SettingsNavigationController
        navController?.SetAllViewControllerColors()
        
        AnalyticsHelper.LogChangedInterface()
    }
    
    override var PageTitle: String {
        return "Appearance"
    }
    
}


class SettingsThemeView: UIView {
    
    static let height: CGFloat = 122.0
    
    let padding = 16.0
    let cellWidth = 130.0
    let cellHeight = 90.0
    
    var rowWidth: CGFloat!
    var rowHeight: CGFloat!
    
    var themeCells = [AppThemePreviewView]()
    var scrollView = UIScrollView()
    
    let type: InterfaceMode
    let themes: [AppTheme]
    
    init(type: InterfaceMode) {
        self.type = type
        self.themes = type == .Dark ? ThemeManager.darkThemes : ThemeManager.lightThemes
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        self.addSubview(scrollView)
        
        for i in 0..<themes.count {
            let cell = AppThemePreviewView(
                frame: CGRect(x: Double(i)*cellWidth, y: padding, width: cellWidth, height: cellHeight),
                theme: themes[i],
                isSelected: type == .Light ? App.settingsConfig.selectedLightThemeIndex == i : App.settingsConfig.selectedDarkThemeIndex == i,
                parentView: self)
            themeCells.append(cell)
            scrollView.addSubview(cell)
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rowHeight = SettingsAppBadgeCountView.height
        rowWidth = superview!.frame.width
        self.frame.size = CGSize(width: rowWidth, height: rowHeight)
        
        scrollView.frame = CGRect(x: 0, y: 0, width: rowWidth, height: cellHeight + padding*2)
        scrollView.contentSize = CGSize(width: cellWidth * Double(themes.count), height: scrollView.frame.height)
    }
    
    func SelectTheme(theme: AppTheme) {
        ThemeManager.SetTheme(theme: theme)
        
        for themeCell in themeCells {
            if themeCell.theme == theme { themeCell.isSelected = true }
            else { themeCell.isSelected = false }
        }
        
        let navController = self.parentViewController?.navigationController as? SettingsNavigationController
        navController?.SetAllViewControllerColors()
        
        AnalyticsHelper.LogSelectedTheme(theme: theme)
    }
    
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class AppThemePreviewView: UIView, UIDynamicTheme  {
    
    let theme: AppTheme
    
    let padding = 16.0
    
    var _isSelected: Bool = false
    var isSelected: Bool {
        get {
            return _isSelected
        }
        set {
            _isSelected = newValue
            if _isSelected { SelectVisuals() }
            else { DeselectVisuals() }
        }
    }
    
    let parentView: SettingsThemeView
    
    let gradientLayer = CAGradientLayer()
    let previewBackground = UIView()
    let previewHeader = UIView()
    let sidemenuPreview = UIView()
    let actionButton = UIView()
    
    var lockedLevelBadge: LevelFrame?
    var isLocked: Bool = false
    
    init(frame: CGRect, theme: AppTheme, isSelected: Bool, parentView: SettingsThemeView) {
        self.parentView = parentView
        self.theme = theme
        super.init(frame: frame)
        
        let previewWidth = 100.0
        let previewHeight = 70.0
        previewBackground.frame = CGRect(x: 0.5*(frame.width-previewWidth), y: 0, width: previewWidth, height: previewHeight)
        previewBackground.layer.cornerRadius = 16
        previewBackground.clipsToBounds = true
        
        let sidemenuWidth = previewWidth*0.2
        sidemenuPreview.frame = CGRect(x: 0, y: 0, width: previewWidth*0.2, height: previewHeight)
        
        previewHeader.frame = CGRect(x: sidemenuWidth, y: 0, width: previewWidth-sidemenuWidth, height: previewHeight * 0.3)
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 1.3, y: -0.3)
        gradientLayer.frame = previewHeader.bounds
        previewHeader.layer.insertSublayer(gradientLayer, at:0)
        
        let blurEffect = UIView(frame: CGRect(x: 0, y: 0, width: previewHeader.frame.width, height: previewHeader.frame.height))
        blurEffect.backgroundColor = theme.interface == .Light ? .black : .white
        blurEffect.alpha = 0.1
        previewHeader.addSubview(blurEffect)
        
        let sliderHeight = (previewHeight - previewHeader.frame.height)*0.2
        let spacing = ((previewHeight - previewHeader.frame.height) - sliderHeight*2.5)/3
        
        let upcomingSlider = UIView(frame: CGRect(x: sidemenuWidth + padding*0.75, y: previewHeader.frame.maxY + spacing, width: previewWidth-padding*1.5 - sidemenuWidth, height: sliderHeight))
        upcomingSlider.layer.cornerRadius = 4
        upcomingSlider.backgroundColor = theme.interface == .Light ? UIColor(hex: "F2F2F7") : UIColor(hex: "1C1C1E")
        
        let upcomingSliderHandle = UIView(frame: CGRect(x: 0, y: 0, width: upcomingSlider.frame.width*0.15, height: sliderHeight))
        upcomingSliderHandle.layer.cornerRadius = 4
        upcomingSliderHandle.backgroundColor = .defaultColor
        
        upcomingSlider.addSubview(upcomingSliderHandle)
        
        let actionButtonSize = sliderHeight*1.5
        actionButton.frame = CGRect(x: previewBackground.frame.width-padding*0.75-actionButtonSize, y: previewBackground.frame.height-spacing-actionButtonSize, width: actionButtonSize, height: actionButtonSize)
        actionButton.layer.cornerRadius = actionButtonSize * 0.5
        
        let label = UILabel(frame: CGRect(x: 0, y: previewBackground.frame.maxY + padding*0.5, width: frame.width, height: 12))
        label.text = theme.name
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12)
        
        previewBackground.addSubview(previewHeader)
        previewBackground.addSubview(sidemenuPreview)
        previewBackground.addSubview(upcomingSlider)
        previewBackground.addSubview(actionButton)
        previewBackground.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Tap)))
        
        self.addSubview(previewBackground)
        self.addSubview(label)
        
        if theme.name == "True Black" || theme.name == "Grayscale" {
            if !StatsManager.getLevelPerk(type: .GrayscaleAndTrueBlackThemes).isUnlocked {
                lockedLevelBadge = AddLockedLevelBadge(level: StatsManager.getLevelPerk(type: .GrayscaleAndTrueBlackThemes).unlockLevel)
                self.addSubview(lockedLevelBadge!)
                isLocked = true
            }
        }
        
        self.isSelected = isSelected
        
        SetColors(theme: theme)
    }
    
    func SetColors(theme: AppTheme) {
        gradientLayer.colors = [theme.tasklistHeaderColor(tasklistColor: .defaultColor).cgColor, theme.tasklistHeaderGradientSecondaryColor(tasklistColor: .defaultColor).cgColor]
        
        previewBackground.backgroundColor = theme.tasklistBackgroundColor
        sidemenuPreview.backgroundColor = theme.sidemenuBackgroundColor
        actionButton.backgroundColor = theme.primaryElementColor(tasklistColor: .defaultColor)
    }
    
    @objc func Tap () {
        if isLocked {
            let level = "Level \(StatsManager.getLevelPerk(type: .GrayscaleAndTrueBlackThemes).unlockLevel)"
            let vc = LockedPerkPopupViewController(warningText: "Reach \(level) to unlock \(theme.name) theme", coloredSubstring: [level, theme.name], parentVC: parentView.parentViewController)
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            parentView.parentViewController!.present(vc, animated: true)
            return
        }
        
        parentView.SelectTheme(theme: theme)
    }
    
    func SelectVisuals() {
        UIView.animate(withDuration: 0.25) { [self] in
            previewBackground.layer.borderWidth = 3
            previewBackground.layer.borderColor = ThemeManager.currentTheme.primaryElementColor(tasklistColor: UIColor.defaultColor).cgColor
        }
    }
    
    func DeselectVisuals() {
        UIView.animate(withDuration: 0.25) { [self] in
            previewBackground.layer.borderWidth = 1
            previewBackground.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
    func ReloadThemeColors() {
        isSelected = isSelected
        UIView.animate(withDuration: 0.25) { [self] in
            lockedLevelBadge?.UpdateColor(color: ThemeManager.currentTheme.primaryColor)
        }
    }
    
    func AddLockedLevelBadge(level: Int) -> LevelFrame {
        let badgeSize = previewBackground.frame.height*0.4
        let badge = LevelFrame(frame: CGRect(x: previewBackground.frame.maxX-badgeSize*0.6, y: previewBackground.frame.minY-badgeSize*0.4, width: badgeSize, height: badgeSize))
        badge.UpdateLevel(level: level)
        return badge
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


class SettingsAppIconView: UIView {
    
    static let height: CGFloat = 122.0
    
    let padding = 16.0
    let cellWidth = 100.0
    let cellHeight = 90.0
    
    var rowWidth: CGFloat!
    var rowHeight: CGFloat!
    
    var allIcons = [AppIconView]()
    var scrollView = UIScrollView()
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        self.addSubview(scrollView)
        
        for i in 0..<AppIcon.allCases.count {
            let cell = AppIconView(
                frame: CGRect(x: Double(i)*cellWidth, y: padding, width: cellWidth, height: cellHeight),
                icon: AppIcon.allCases[i],
                isSelected:  App.settingsConfig.selectedIcon == AppIcon.allCases[i],
                parentView: self
            )
            allIcons.append(cell)
            scrollView.addSubview(cell)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rowHeight = SettingsAppBadgeCountView.height
        rowWidth = superview!.frame.width
        self.frame.size = CGSize(width: rowWidth, height: rowHeight)
        
        
        scrollView.frame = CGRect(x: 0, y: 0, width: rowWidth, height: cellHeight + padding*2)
        scrollView.contentSize = CGSize(width: cellWidth * Double(AppIcon.allCases.count), height: scrollView.frame.height)
    }
    
    func SelectIcon(icon: AppIcon) {
        AppIconManager.setIcon(icon)
        App.settingsConfig.selectedIcon = icon
        SaveManager.instance.SaveSettings()
        
        for iconCell in allIcons {
            if iconCell.icon == icon { iconCell.isSelected = true }
            else { iconCell.isSelected = false }
        }
        
        AnalyticsHelper.LogChangedAppIcon()
    }
}

class AppIconView: UIView, UIDynamicTheme  {
    
    let icon: AppIcon
    
    let padding = 16.0
    
    var _isSelected: Bool = false
    var isSelected: Bool {
        get {
            return _isSelected
        }
        set {
            _isSelected = newValue
            if _isSelected { SelectVisuals() }
            else { DeselectVisuals() }
        }
    }
    
    let imageView = UIImageView()
    let parentView: SettingsAppIconView
    
    var lockedLevelBadge: LevelFrame?
    var isLocked: Bool = false
    
    init(frame: CGRect, icon: AppIcon, isSelected: Bool, parentView: SettingsAppIconView) {
        self.icon = icon
        self.parentView = parentView
        super.init(frame: frame)
        
        let imageSize = 70.0
        imageView.frame = CGRect(x: 0.5*(frame.width-imageSize), y: 0, width: imageSize, height: imageSize)
        imageView.image = icon.preview
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Tap)))
        imageView.isUserInteractionEnabled = true
        
        let label = UILabel(frame: CGRect(x: 0, y: imageView.frame.maxY + padding*0.5, width: frame.width, height: 12))
        label.text = icon.displayName
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12)
        
        self.addSubview(imageView)
        self.addSubview(label)
        self.isSelected = isSelected
        
        if icon == .orange || icon == .orangeFilled || icon == .red || icon == .redFilled || icon == .purple || icon == .purpleFilled || icon == .black || icon == .blackFilled {
            if !StatsManager.getLevelPerk(type: .ColoredAppIcons).isUnlocked {
                lockedLevelBadge = AddLockedLevelBadge(level: StatsManager.getLevelPerk(type: .ColoredAppIcons).unlockLevel)
                self.addSubview(lockedLevelBadge!)
                isLocked = true
            }
        }
    }
    
    @objc func Tap () {
        if isLocked {
            let level = "Level \(StatsManager.getLevelPerk(type: .ColoredAppIcons).unlockLevel)"
            let vc = LockedPerkPopupViewController(warningText: "Reach \(level) to unlock colored icons", coloredSubstring: [level, "colored icons"], parentVC: parentView.parentViewController)
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            parentView.parentViewController!.present(vc, animated: true)
            return
        }
        
        parentView.SelectIcon(icon: icon)
    }
    
    func SelectVisuals() {
        UIView.animate(withDuration: 0.25) { [self] in
            imageView.layer.borderWidth = 3
            imageView.layer.borderColor = ThemeManager.currentTheme.primaryElementColor(tasklistColor: UIColor.defaultColor).cgColor
        }
    }
    
    func DeselectVisuals() {
        UIView.animate(withDuration: 0.25) { [self] in
            imageView.layer.borderWidth = 1
            imageView.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
    func ReloadThemeColors() {
        isSelected = isSelected
        UIView.animate(withDuration: 0.25) { [self] in
            lockedLevelBadge?.UpdateColor(color: ThemeManager.currentTheme.primaryColor)
        }
    }
    
    func AddLockedLevelBadge(level: Int) -> LevelFrame {
        let badgeSize = imageView.frame.height*0.4
        let badge = LevelFrame(frame: CGRect(x: imageView.frame.maxX-badgeSize*0.6, y: imageView.frame.minY-badgeSize*0.4, width: badgeSize, height: badgeSize))
        badge.UpdateLevel(level: level)
        return badge
    }
    
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

