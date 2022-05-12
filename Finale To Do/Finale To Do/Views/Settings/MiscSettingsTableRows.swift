//
//  MiscSettingsTableRows.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/29/22.
//

import Foundation
import UIKit

//MARK: App Badge Count View

class SettingsAppBadgeCountView: UIView {
    
    static let height: CGFloat = 406
    let selectionRowHeight = 50.0
    
    let padding = 16.0
    var rowWidth: CGFloat!
    let rowHeight: CGFloat
    
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let appIconView = UIImageView()
    let iconBadgeView = UIView()
    let badgeNumberLabel = UILabel()
    let rowsContainer = UIView()
    
    var selectionRows = [SettingsSelectionRow]()
    
    init() {
        self.rowHeight = SettingsAppBadgeCountView.height
        super.init(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 0, height: rowHeight)))
        
        titleLabel.text = "App Badge Number"
        titleLabel.textColor = .label
        
        subtitleLabel.text = "The number shown on the app's icon."
        subtitleLabel.textColor = .systemGray
        subtitleLabel.font = .preferredFont(forTextStyle: .footnote)
        
        appIconView.image = App.settingsConfig.selectedIcon.preview
        appIconView.clipsToBounds = true
        appIconView.layer.cornerRadius = 12
        appIconView.layer.borderColor = UIColor.systemGray4.cgColor
        appIconView.layer.borderWidth = 1
        
        iconBadgeView.backgroundColor = .systemRed
        badgeNumberLabel.textColor = .white
        badgeNumberLabel.text = NotificationHelper.GetAppBadgeNumber().description
        badgeNumberLabel.textAlignment = .center
        badgeNumberLabel.font = .systemFont(ofSize: 15)
        badgeNumberLabel.adjustsFontSizeToFitWidth = true
        
        SetBadgeNumber()
        
        self.addSubview(titleLabel)
        self.addSubview(subtitleLabel)
        self.addSubview(appIconView)
        self.addSubview(iconBadgeView)
        iconBadgeView.addSubview(badgeNumberLabel)
        self.addSubview(rowsContainer)
    }
    
    func SetBadgeNumber () {
        UIView.animate(withDuration: 0.25) { [self] in
            let number = NotificationHelper.GetAppBadgeNumber()
            badgeNumberLabel.text = number == 0 ? "" : number.description
            iconBadgeView.alpha = badgeNumberLabel.text == "" ? 0 : 1
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        rowWidth = superview!.frame.width
        let paddedRowWidth = rowWidth - padding*2
        self.frame.size.width = rowWidth
        
        titleLabel.frame = CGRect(x: padding, y: padding, width: paddedRowWidth, height: 20)
        subtitleLabel.frame = CGRect(x: padding, y: titleLabel.frame.maxY+padding*0.25, width: paddedRowWidth, height: 12)
        
        let iconSize = 60.0
        let badgeSize = iconSize*0.37
        appIconView.frame = CGRect(x: padding, y: subtitleLabel.frame.maxY+padding*1.5, width: iconSize, height: iconSize)
        iconBadgeView.frame = CGRect(x: appIconView.frame.maxX - 0.6*badgeSize, y: appIconView.frame.origin.y-badgeSize*0.4, width: badgeSize, height: badgeSize)
        iconBadgeView.layer.cornerRadius = badgeSize*0.5
        badgeNumberLabel.frame = CGRect(x: 0, y: 0, width: badgeSize, height: badgeSize)
        
        SetupRows()
        for row in selectionRows { rowsContainer.addSubview(row) }
        rowsContainer.frame = CGRect(x: 0, y: appIconView.frame.maxY + padding*0.5, width: rowWidth, height: Double(selectionRows.count)*50.0)
    }
    
    func SetupRows () {
        if selectionRows.count != 0 { return }
        
        for i in 0..<5 {
            selectionRows.append(
                SettingsSelectionRow(frame: CGRect(x: 0, y: Double(i)*selectionRowHeight, width: rowWidth, height: selectionRowHeight), title: AppBadgeNumberType(rawValue: i)!.str, index: i, isSelected: App.settingsConfig.appBadgeNumberTypes.contains(AppBadgeNumberType(rawValue: i)!), isNone: i == 0, onSelect: SelectOption, onDeselect: DeselectOption)
            )
        }
    }
    
    func SelectOption(index: Int) {
        selectionRows.first?.isSelected = false
        if App.settingsConfig.appBadgeNumberTypes.contains(.None) {
            App.settingsConfig.appBadgeNumberTypes.remove(at: App.settingsConfig.appBadgeNumberTypes.firstIndex(of: .None)!)
        }
        if index == 0 {
            for selectionRow in selectionRows {
                selectionRow.isSelected = false
            }
            App.settingsConfig.appBadgeNumberTypes.removeAll()
        }
        selectionRows[index].isSelected = true
        
        if !App.settingsConfig.appBadgeNumberTypes.contains(AppBadgeNumberType(rawValue: index)!) {
            App.settingsConfig.appBadgeNumberTypes.append(AppBadgeNumberType(rawValue: index)!)
        }
        
        SetBadgeNumber()
    }
    
    func DeselectOption (index: Int) {
        if index == 0 { return }
        var nSelected = 0
        for row in selectionRows { nSelected += row.isSelected ? 1 : 0}
        if nSelected == 1 { return }
        selectionRows[index].isSelected = false
        if App.settingsConfig.appBadgeNumberTypes.contains(AppBadgeNumberType(rawValue: index)!) {
            App.settingsConfig.appBadgeNumberTypes.remove(at: App.settingsConfig.appBadgeNumberTypes.firstIndex(of: AppBadgeNumberType(rawValue: index)!)!)
        }
        
        SetBadgeNumber()
    }
    
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}


//MARK: Settings Selection Row

class SettingsSelectionRow: UIView, UIDynamicTheme {
    
    
    let index: Int
    
    var OnSelect: (_ index: Int)->Void
    var OnDeselect: (_ index: Int)->Void
    
    var _isSelected: Bool!
    var isSelected: Bool  {
        get {
            return _isSelected
        }
        set {
            _isSelected = newValue
            imageView.image = UIImage(systemName: _isSelected ? isNone ? "circle.inset.filled" : "checkmark.circle.fill" :  "circle")
            imageView.tintColor = isSelected ? ThemeManager.currentTheme.primaryElementColor(tasklistColor: .defaultColor) : .systemGray
        }
    }
    
    var imageView: UIImageView!
    
    let isNone: Bool
    let padding = 16.0
    
    init(frame: CGRect, title: String, index: Int, isSelected: Bool, isNone: Bool, onSelect: @escaping (_ index: Int)->Void, onDeselect: @escaping (_ index: Int)->Void) {
        self.isNone = isNone
        self.OnSelect = onSelect
        self.OnDeselect = onDeselect
        self.index = index
        super.init(frame: frame)
        
        let rowSize = frame.size
        
        let imageSize = rowSize.width*0.07
        imageView = UIImageView(frame: CGRect(x: padding, y: 0.5*(rowSize.height-imageSize), width: imageSize, height: imageSize))
        imageView.contentMode = .scaleAspectFit

        let label = UILabel (frame: CGRect(x: imageView.frame.maxX + padding*0.5, y: 0, width: rowSize.width-padding*2.5-imageView.frame.width, height: rowSize.height))
        label.text = title
        label.textAlignment = .left

        self.addSubview(imageView)
        self.addSubview(label)

        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Tap)))
        
        self.isSelected = isSelected
    }
    
    @objc func Tap () {
        if isSelected && !isNone { Deselect() } else { Select() }
        
        self.backgroundColor = .systemGray3.withAlphaComponent(0.5)
        UIView.animate(withDuration: 0.25) {
            self.backgroundColor = .clear
        }
    }
    
    func Select() {
        OnSelect(index)
    }
    
    func Deselect() {
        OnDeselect(index)
    }
    
    func ReloadThemeColors() {
        UIView.animate(withDuration: 0.25) { [self] in
            imageView.tintColor = isSelected ? ThemeManager.currentTheme.primaryElementColor(tasklistColor: .defaultColor) : .systemGray
        }
    }
    
    
    
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


//MARK: App Icon View

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
        App.instance.SaveSettings()
        
        for iconCell in allIcons {
            if iconCell.icon == icon { iconCell.isSelected = true }
            else { iconCell.isSelected = false }
        }
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
            let unlockLevel = StatsManager.getLevePerk(type: .ColoredAppIcons).unlockLevel
            if StatsManager.stats.level < unlockLevel {
                lockedLevelBadge = AddLockedLevelBadge(level: unlockLevel)
                self.addSubview(lockedLevelBadge!)
                isLocked = true
            }
        }
    }
    
    @objc func Tap () {
        if isLocked {
            let vc = LockedPerkPopupViewController(warningText: "Colored icons are unlocked when you reach level \(StatsManager.getLevePerk(type: .ColoredAppIcons).unlockLevel)", parentVC: parentView.parentViewController)
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

//MARK: Theme selection

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
        
        let navController = self.parentViewController?.navigationController as! SettingsNavigationController
        navController.SetAllViewControllerColors()
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
        
        if theme.name == "True Black" {
            let unlockLevel = StatsManager.getLevePerk(type: .TrueBlackTheme).unlockLevel
            if StatsManager.stats.level < unlockLevel {
                lockedLevelBadge = AddLockedLevelBadge(level: unlockLevel)
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
            let vc = LockedPerkPopupViewController(warningText: "\(theme.name) theme is unlocked when you reach level \(StatsManager.getLevePerk(type: .TrueBlackTheme).unlockLevel)", parentVC: parentView.parentViewController)
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



//MARK: App Logo & Version row

class SettingsAppLogoAndVersionView: UIView, UIDynamicTheme {
    
    static var height = 136.0
    
    let padding = 16.0
    
    let appIcon = UIImageView()
    let versionLabel = UILabel()
    
    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = .red
        
        self.addSubview(appIcon)
        self.addSubview(versionLabel)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        let rowWidth = superview!.frame.width
        self.frame.size = CGSize(width: rowWidth, height: SettingsAppLogoAndVersionView.height)
        
        let iconSize = 80.0
        appIcon.frame = CGRect(x: 0.5*(rowWidth-iconSize), y: 20, width: iconSize, height: iconSize)
        appIcon.image = AppIcon.classic.preview
        appIcon.layer.cornerRadius = 16
        appIcon.clipsToBounds = true
        
        versionLabel.frame = CGRect(x: 0, y: appIcon.frame.maxY + padding, width: rowWidth, height: 20)
        versionLabel.textAlignment = .center
        versionLabel.textColor = .systemGray
        versionLabel.text = appVersion
        
        self.backgroundColor = ThemeManager.currentTheme.interface == .Light ? .systemGray6 : .black
    }
    
    func ReloadThemeColors() {
        backgroundColor = ThemeManager.currentTheme.interface == .Light ? .systemGray6 : .black
    }
    
    var appVersion: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return "Version: \(version)"
        }
        return ""
    }
    
    
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
