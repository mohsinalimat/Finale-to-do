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
        subtitleLabel.frame = CGRect(x: padding, y: titleLabel.frame.maxY+padding*0.25, width: paddedRowWidth, height: 16)
        
        let iconSize = 60.0
        let badgeSize = iconSize*0.37
        appIconView.frame = CGRect(x: padding, y: subtitleLabel.frame.maxY+padding*1.5-4, width: iconSize, height: iconSize)
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
            AnalyticsHelper.LogAppBadgeNumberSelection(type: AppBadgeNumberType(rawValue: index)!)
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
    var accentColor: UIColor
    
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
            imageView.tintColor = isSelected ? ThemeManager.currentTheme.primaryElementColor(tasklistColor: accentColor) : .systemGray
        }
    }
    
    var imageView: UIImageView!
    
    let isNone: Bool
    let padding = 16.0
    
    init(frame: CGRect, title: String, accentColor: UIColor = .defaultColor, index: Int, isSelected: Bool, isNone: Bool, onSelect: @escaping (_ index: Int)->Void, onDeselect: @escaping (_ index: Int)->Void) {
        self.isNone = isNone
        self.accentColor = accentColor
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
            imageView.tintColor = isSelected ? ThemeManager.currentTheme.primaryElementColor(tasklistColor: accentColor) : .systemGray
        }
    }
    
    func SetAccentColor (color: UIColor) {
        accentColor = color
        ReloadThemeColors()
    }
    
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//MARK: Widget Lists View
class SettingsWidgetListsView: UIView {
    static var height: CGFloat {
        return CGFloat(68 + 50*(App.userTaskLists.count+2))
    }
    let selectionRowHeight = 50.0
    
    let padding = 16.0
    var rowWidth: CGFloat!
    let rowHeight: CGFloat
    
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let rowsContainer = UIView()
    
    var selectionRows = [SettingsSelectionRow]()
    
    init() {
        self.rowHeight = SettingsAppBadgeCountView.height
        super.init(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 0, height: rowHeight)))
        
        titleLabel.text = "Widget Lists"
        titleLabel.textColor = .label
        
        subtitleLabel.text = "Lists shown on the home-screen widget."
        subtitleLabel.textColor = .systemGray
        subtitleLabel.font = .preferredFont(forTextStyle: .footnote)
        
        self.addSubview(titleLabel)
        self.addSubview(subtitleLabel)
        self.addSubview(rowsContainer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        rowWidth = superview!.frame.width
        let paddedRowWidth = rowWidth - padding*2
        self.frame.size.width = rowWidth
        
        titleLabel.frame = CGRect(x: padding, y: padding, width: paddedRowWidth, height: 20)
        subtitleLabel.frame = CGRect(x: padding, y: titleLabel.frame.maxY+padding*0.25, width: paddedRowWidth, height: 16)
        
        SetupRows()
        for row in selectionRows { rowsContainer.addSubview(row) }
        rowsContainer.frame = CGRect(x: 0, y: subtitleLabel.frame.maxY + padding*0.5-4, width: rowWidth, height: Double(selectionRows.count)*50.0)
    }
    
    func SetupRows () {
        if selectionRows.count != 0 { return }
        
        selectionRows.append(
            SettingsSelectionRow(frame: CGRect(x: 0, y: Double(0)*selectionRowHeight, width: rowWidth, height: selectionRowHeight),
                              title: "All",
                              index: 0,
                              isSelected: App.settingsConfig.widgetLists.count == 0,
                              isNone: true,
                              onSelect: SelectOption,
                              onDeselect: DeselectOption))
        
        selectionRows.append(
            SettingsSelectionRow(frame: CGRect(x: 0, y: Double(1)*selectionRowHeight, width: rowWidth, height: selectionRowHeight),
                                 title: App.mainTaskList.name,
                                  index: 1,
                                  isSelected: App.settingsConfig.widgetLists.contains(App.mainTaskList.id),
                                  isNone: false,
                                  onSelect: SelectOption,
                                  onDeselect: DeselectOption))
        
        for i in 2..<App.userTaskLists.count+2 {
            selectionRows.append(
                SettingsSelectionRow(frame: CGRect(x: 0, y: Double(i)*selectionRowHeight, width: rowWidth, height: selectionRowHeight),
                                     title: App.userTaskLists[i-2].name,
                                     index: i,
                                     isSelected: App.settingsConfig.widgetLists.contains(App.userTaskLists[i-2].id),
                                     isNone: i == 0,
                                     onSelect: SelectOption,
                                     onDeselect: DeselectOption)
            )
        }
    }
    
    func SelectOption(index: Int) {
        selectionRows.first?.isSelected = false
        
        if index == 0 {
            for selectionRow in selectionRows {
                selectionRow.isSelected = false
            }
            App.settingsConfig.widgetLists.removeAll()
        } else {
            let tasklistID = index == 1 ? App.mainTaskList.id : App.userTaskLists[index-2].id
            if !App.settingsConfig.widgetLists.contains(tasklistID) {
                App.settingsConfig.widgetLists.append(tasklistID)
                //Log Analytics
            }
        }
        selectionRows[index].isSelected = true
        
        if App.settingsConfig.widgetLists.count >= App.userTaskLists.count + 1 {
            SelectOption(index: 0)
        }
        
        AnalyticsHelper.LogWidgetListsSelection()
    }
    
    func DeselectOption (index: Int) {
        if index == 0 { return }
        var nSelected = 0
        for row in selectionRows { nSelected += row.isSelected ? 1 : 0}
        if nSelected == 1 { return }
        selectionRows[index].isSelected = false
        
        let tasklistID = index == 1 ? App.mainTaskList.id : App.userTaskLists[index-2].id
        if App.settingsConfig.widgetLists.contains(tasklistID) {
            App.settingsConfig.widgetLists.remove(at: App.settingsConfig.widgetLists.firstIndex(of: tasklistID)!)
        }
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
        
        
        let debugTaps = UITapGestureRecognizer(target: self, action: #selector(RevealDebug))
        debugTaps.numberOfTapsRequired = 40
        debugTaps.cancelsTouchesInView = false
        appIcon.isUserInteractionEnabled = true
        appIcon.addGestureRecognizer(debugTaps)
        
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
    
    @objc func RevealDebug () {
        parentViewController?.navigationController?.show(SettingsDebugPage(), sender: parentViewController!.navigationController!)
    }
    
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}



//MARK: Default Notifications Type View
class SettingsDefaultNotificationTypeView: UIView {
    static var height: CGFloat {
        return CGFloat(88 + 45.0*6)
    }
    let selectionRowHeight = 45.0
    
    let padding = 16.0
    var rowWidth: CGFloat!
    let rowHeight: CGFloat
    
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let rowsContainer = UIView()
    
    var selectionRows = [SettingsSelectionRow]()
    
    let isWithDueTime: Bool
    
    init(isWithDueTime: Bool) {
        self.isWithDueTime = isWithDueTime
        self.rowHeight = SettingsAppBadgeCountView.height
        super.init(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 0, height: rowHeight)))
        
        titleLabel.text = !isWithDueTime ? "Tasks Without Due Time" : "Tasks With Due Time"
        titleLabel.textColor = .label
        
        subtitleLabel.numberOfLines = 2
        subtitleLabel.text = !isWithDueTime ? "New tasks without a specific due time will automatically have these notifications enabled." : "New tasks with a specific due time will automatically have these notifications enabled."
        subtitleLabel.textColor = .systemGray
        subtitleLabel.font = .preferredFont(forTextStyle: .footnote)
        subtitleLabel.adjustsFontSizeToFitWidth = true
        
        self.addSubview(titleLabel)
        self.addSubview(subtitleLabel)
        self.addSubview(rowsContainer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        rowWidth = superview!.frame.width
        let paddedRowWidth = rowWidth - padding*2
        self.frame.size.width = rowWidth
        
        titleLabel.frame = CGRect(x: padding, y: padding, width: paddedRowWidth, height: 20)
        subtitleLabel.frame = CGRect(x: padding, y: titleLabel.frame.maxY+padding*0.25, width: paddedRowWidth, height: 40.0)
        
        SetupRows()
        for row in selectionRows { rowsContainer.addSubview(row) }
        rowsContainer.frame = CGRect(x: 0, y: subtitleLabel.frame.maxY + padding*0.5-4, width: rowWidth, height: Double(selectionRows.count)*selectionRowHeight)
    }
    
    func SetupRows () {
        if selectionRows.count != 0 { return }
        
        selectionRows.append(
            SettingsSelectionRow(frame: CGRect(x: 0, y: 0, width: rowWidth, height: selectionRowHeight),
                title: "None",
                index: -1,
                isSelected: isWithDueTime ? App.settingsConfig.defaultDueTimeNotificationTypes.count == 0 : App.settingsConfig.defaultNoTimeNotificationTypes.count == 0,
                isNone: true,
                onSelect: SelectOption,
                onDeselect: DeselectOption))
        
        let start = isWithDueTime ? 0 : 5
        let end = isWithDueTime ? 5 : 10
        for i in start..<end {
            selectionRows.append(
                SettingsSelectionRow(frame: CGRect(x: 0, y: selectionRowHeight + Double(isWithDueTime ? i : i-5)*selectionRowHeight, width: rowWidth, height: selectionRowHeight),
                    title: NotificationType(rawValue: i)!.str,
                    index: i,
                    isSelected: isWithDueTime ? App.settingsConfig.defaultDueTimeNotificationTypes.contains(NotificationType(rawValue: i)!) : App.settingsConfig.defaultNoTimeNotificationTypes.contains(NotificationType(rawValue: i)!),
                    isNone: false,
                    onSelect: SelectOption,
                    onDeselect: DeselectOption)
            )
        }
    }
    
    func SelectOption(index: Int) {
        if isWithDueTime {
            if index == -1 {
                for selectionRow in selectionRows {
                    selectionRow.isSelected = false
                }
                App.settingsConfig.defaultDueTimeNotificationTypes.removeAll()
                selectionRows.first?.isSelected = true
                return
            }
            
            let notifPerk = StatsManager.getLevelPerk(type: .UnlimitedNotifications)
            if App.settingsConfig.defaultDueTimeNotificationTypes.count >= 2 && !notifPerk.isUnlocked {
                let level = "Level \(notifPerk.unlockLevel)"
                let vc = LockedPerkPopupViewController(warningText: "Reach \(level) to set more than 2 notifications per task", coloredSubstring: [level], parentVC: self.parentViewController)
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve
                self.parentViewController!.present(vc, animated: true)
                return
            }
            
            App.settingsConfig.defaultDueTimeNotificationTypes.append(NotificationType(rawValue: index)!)
            selectionRows.first?.isSelected = false
            for selectionRow in selectionRows {
                if selectionRow.index == index {
                    selectionRow.isSelected = true
                    break
                }
            }
        } else {
            if index == -1 {
                for selectionRow in selectionRows {
                    selectionRow.isSelected = false
                }
                App.settingsConfig.defaultNoTimeNotificationTypes.removeAll()
                selectionRows.first?.isSelected = true
                return
            }
            
            let notifPerk = StatsManager.getLevelPerk(type: .UnlimitedNotifications)
            if App.settingsConfig.defaultNoTimeNotificationTypes.count >= 2 && !notifPerk.isUnlocked {
                let level = "Level \(notifPerk.unlockLevel)"
                let vc = LockedPerkPopupViewController(warningText: "Reach \(level) to set more than 2 notifications per task", coloredSubstring: [level], parentVC: self.parentViewController)
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve
                self.parentViewController!.present(vc, animated: true)
                return
            }
            
            App.settingsConfig.defaultNoTimeNotificationTypes.append(NotificationType(rawValue: index)!)
            selectionRows.first?.isSelected = false
            for selectionRow in selectionRows {
                if selectionRow.index == index {
                    selectionRow.isSelected = true
                    break
                }
            }
        }
    }
    
    func DeselectOption (index: Int) {
        if isWithDueTime {
            if index == -1 { return }
            
            if App.settingsConfig.defaultDueTimeNotificationTypes.contains(NotificationType(rawValue: index)!) {
                App.settingsConfig.defaultDueTimeNotificationTypes.remove(at: App.settingsConfig.defaultDueTimeNotificationTypes.firstIndex(of: NotificationType(rawValue: index)!)!)
            }
            
            if App.settingsConfig.defaultDueTimeNotificationTypes.count == 0 { selectionRows.first?.isSelected = true }
            for selectionRow in selectionRows {
                if selectionRow.index == index {
                    selectionRow.isSelected = false
                    break
                }
            }
        } else {
            if index == -1 { return }
            
            if App.settingsConfig.defaultNoTimeNotificationTypes.contains(NotificationType(rawValue: index)!) {
                App.settingsConfig.defaultNoTimeNotificationTypes.remove(at: App.settingsConfig.defaultNoTimeNotificationTypes.firstIndex(of: NotificationType(rawValue: index)!)!)
            }
            
            if App.settingsConfig.defaultNoTimeNotificationTypes.count == 0 { selectionRows.first?.isSelected = true }
            for selectionRow in selectionRows {
                if selectionRow.index == index {
                    selectionRow.isSelected = false
                    break
                }
            }
        }
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
