//
//  SettingsViewController.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/27/22.
//

import Foundation
import UIKit
import SwiftUI

class SettingsNavigationController: UINavigationController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        overrideUserInterfaceStyle = App.settingsConfig.interface == .System ? .unspecified : App.settingsConfig.interface == .Light ? .light : .dark
        
        self.setViewControllers([SettingsMainPage()], animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        App.instance.SaveSettings()
        
        self.popToRootViewController(animated: false)
        let settingsVC = topViewController as! SettingsPageViewController
        
        settingsVC.ReloadSettings()
        for cell in settingsVC.tableView.visibleCells {
            let x = cell as! SettingsTableCell
            x.ReloadPreview()
        }
    }
    
    func SetAllViewControllerColors() {
        for viewController in self.viewControllers {
            if let dynamicTheme = viewController as? UIDynamicTheme { dynamicTheme.ReloadThemeColors() }
            for subview in viewController.view.subviews {
                SetSubviewColors(of: subview)
            }
        }
    }
    
    func SetSubviewColors(of view: UIView) {
        if let dynamicThemeView = view as? UIDynamicTheme  {
            dynamicThemeView.ReloadThemeColors()
        }
        
        for subview in view.subviews {
            SetSubviewColors(of: subview)
        }
    }
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
//MARK: Main Page
class SettingsMainPage: SettingsPageViewController {
    
    override init() {
        super.init()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(Dismiss))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func Dismiss () {
        self.dismiss(animated: true)
    }
    
    override func GetSettings() -> [SettingsSection] {
        return [
            SettingsSection(title: "Personal", options: [
                .navigationCell(model: SettingsNavigationOption(title: "Name", icon: UIImage(systemName: "person.text.rectangle.fill"), iconBackgroundColor: .systemGreen, nextPage: SettingsPersonalPage(), SetPreview: {return App.settingsConfig.userFullName;} ))
            ]),
            SettingsSection(title: "Preferences", footer: "", options: [
                .navigationCell(model: SettingsNavigationOption(title: "Default List", icon: UIImage(systemName: "folder.fill"), iconBackgroundColor: .systemBlue, nextPage: SettingsDefaultListPage(), SetPreview: { return self.defaultFolderPreview } )),
                .navigationCell(model: SettingsNavigationOption(title: "Notifications", icon: UIImage(systemName: "bell.badge.fill"), iconBackgroundColor: .systemRed, nextPage: SettingsNotificationsPage())),
                .navigationCell(model: SettingsNavigationOption(title: "Appearance", icon: UIImage(systemName: "circle.hexagongrid.circle"), iconBackgroundColor: .systemPurple, nextPage: SettingsAppearancePage()))
            ]),
            
            SettingsSection(title: "Help", options: [
                .navigationCell(model: SettingsNavigationOption(title: "Guide", icon: UIImage(systemName: "doc.text.image.fill"), iconBackgroundColor: .systemOrange, nextPage: SettingsPersonalPage())),
                .navigationCell(model: SettingsNavigationOption(title: "Statistics", icon: UIImage(systemName: "chart.bar.fill"), iconBackgroundColor: .systemBlue, nextPage: SettingsStatisticsPage())),
                .navigationCell(model: SettingsNavigationOption(title: "About", icon: UIImage(systemName: "bookmark.fill"), iconBackgroundColor: .systemTeal, nextPage: SettingsAboutPage(), SetPreview: {return self.appVersion })),
                .navigationCell(model: SettingsNavigationOption(title: "Share", icon: UIImage(systemName: "square.and.arrow.up.fill"), iconBackgroundColor: .systemYellow, OnTap: {
                    let items = [AppIcon.classic.preview] as [UIImage]
                    let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                    self.present(ac, animated: true)
                }))
            ])
        ]
    }
    
    override var PageTitle: String {
        return "Settings"
    }
    
    var defaultFolderPreview: String {
        for taskList in App.userTaskLists {
            if App.settingsConfig.defaultFolderID == taskList.id {
                return taskList.name
            }
        }
        
        return App.mainTaskList.name
    }
    
    var appVersion: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return "v\(version)"
        }
        return ""
    }
    
}
//MARK: Personal Page
class SettingsPersonalPage: SettingsPageViewController {
    
    override func GetSettings() -> [SettingsSection] {
        return [
            SettingsSection(footer: "Finale uses your name to personalize your experience.", options: [
                .inputFieldCell(model: SettingsInputFieldOption(title: "First Name", inputFieldText: App.settingsConfig.userFirstName, icon: nil, iconBackgroundColor: .systemGreen) ),
                .inputFieldCell(model: SettingsInputFieldOption(title: "Last Name", inputFieldText: App.settingsConfig.userLastName, icon: nil, iconBackgroundColor: .systemGreen) )
            ]),
            
            SettingsSection(footer: icloudSyncFooter, options: [
                .switchCell(model: SettingsSwitchOption(title: "iCloud Sync", isOn: App.settingsConfig.isICloudSyncOn, OnChange: { sender in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        self.CheckExistingIcloudSaveFiles(sender: sender)
                    }
                }))
            ]),
            
        ]
    }
    
    func CheckExistingIcloudSaveFiles (sender: UISwitch) {
        if sender.isOn {
            let keyStore = NSUbiquitousKeyValueStore()
            
            if let lastSyncDate = keyStore.object(forKey: App.instance.lastICloudSyncKey) as? Date {
                let deviceName = keyStore.string(forKey: App.instance.deviceNameKey) ?? "Unknown device"
                let confirmationVC = ICloudSyncConfirmationViewController(
                    lastICloudSync: lastSyncDate,
                    deviceName: deviceName,
                 OnCancelled: {
                     sender.setOn(false, animated: true)
                }, OnConfirm: {
                    App.settingsConfig.isICloudSyncOn = true
                    App.instance.LoadICloudData(iCloudKey: NSUbiquitousKeyValueStore())
                    App.instance.sideMenuView.tableView.reloadData()
                    App.instance.SelectTaskList(index: 0, closeMenu: false)
                    ThemeManager.SetTheme(theme: App.settingsConfig.GetCurrentTheme())
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        App.instance.overrideUserInterfaceStyle = App.settingsConfig.interface == .System ? .unspecified : App.settingsConfig.interface == .Light ? .light : .dark
                        
                        let nc = self.navigationController as! SettingsNavigationController
                        nc.SetAllViewControllerColors()
                        nc.overrideUserInterfaceStyle = App.instance.overrideUserInterfaceStyle
                        
                        self.ReloadSettings()
                        self.tableView.reloadData()
                    }
                }, OnDecline: {
                    App.settingsConfig.isICloudSyncOn = true
                    App.instance.SaveSettings()
                    App.instance.SaveData()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.ReloadSettings()
                        self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
                    }
                })
                if let sheet = confirmationVC.sheetPresentationController {
                    sheet.detents = [.medium()]
                }
                self.present(confirmationVC, animated: true)
            } else {
                App.settingsConfig.isICloudSyncOn = true
                self.ReloadSettings()
                self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
            }
        } else {
            App.instance.RemoveICloudSaveFiles()
            App.settingsConfig.isICloudSyncOn = false
            self.ReloadSettings()
            self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
        }
    }
    
    
    override var PageTitle: String {
        return "Name"
    }
    
    var icloudSyncFooter: String {
        return App.settingsConfig.isICloudSyncOn ?
        "Turn off to stop Finale from synchronizing tasks across your different iOS devices." :
        "Turn on for Finale to synchronize tasks across your different iOS devices."
    }
    
}

//MARK: Default list Page
class SettingsDefaultListPage: SettingsPageViewController {
    
    override func GetSettings() -> [SettingsSection] {
        var options = [SettingsOptionType]()
        options.append(.selectionCell(model: SettingsSelectionOption(title: App.mainTaskList.name, selectionID: 0, isSelected: App.settingsConfig.defaultFolderID == App.mainTaskList.id) {
            self.SetDefaultFolder(index: 0)
        }))
        
        for i in 0..<App.userTaskLists.count {
            options.append(.selectionCell(model: SettingsSelectionOption(title: App.userTaskLists[i].name, selectionID: i, isSelected: App.settingsConfig.defaultFolderID == App.userTaskLists[i].id) {
                self.SetDefaultFolder(index: i+1)
            }))
        }
        
        return [ SettingsSection(footer: "New tasks from the 'overview' page will be added to this list.", options: options) ]
    }
    
    override var PageTitle: String {
        return "Default List"
    }
    
    func SetDefaultFolder(index: Int) {
        App.settingsConfig.defaultFolderID = index == 0 ? App.mainTaskList.id : App.userTaskLists[index-1].id
    }
    
}

//MARK: Notifications Page
class SettingsNotificationsPage: SettingsPageViewController {
    
    override init() {
        super.init()
        
        if App.settingsConfig.isNotificationsAllowed { ShowAllNotificationSettings() }
    }
    
    override func GetSettings() -> [SettingsSection] {
        return [
            SettingsSection(footer: "Finale will never send you unnecessary alerts, and will only send notifications that you set yourself.", options: [
                .switchCell(model: SettingsSwitchOption(title: "Allow Notifications", isOn: App.settingsConfig.isNotificationsAllowed) { sender in
                    if sender.isOn {
                        NotificationHelper.RequestNotificationAccess(uiSwitch: sender, settingsNotificationsPage: self)
                    } else {
                        self.HideAllNotificationSettings()
                        App.settingsConfig.isNotificationsAllowed = false
                        NotificationHelper.CancelAllScheduledNotifications()
                    }
                })
            ])
        ]
    }
    
    func AllowNotificationSuccess () {
        NotificationHelper.ScheduleAllTaskNotifications()
    }
    
    func ShowAllNotificationSettings () {
        if settingsSections.count > 1 { return }
        
        settingsSections.append(contentsOf: GetAllNotificationSettings())
        tableView.insertSections(IndexSet(integer: 1), with: .fade)
    }
    
    func HideAllNotificationSettings () {
        if settingsSections.count == 1 { return }
        
        settingsSections.removeLast()
        tableView.deleteSections(IndexSet(integer: 1), with: .fade)
    }
    
    func GetAllNotificationSettings () -> [SettingsSection] {
        return [
            SettingsSection(options: [.customViewCell(model: SettingsAppBadgeCountView())], customHeight: SettingsAppBadgeCountView.height)
        ]
    }
    
    @objc func AppBecameActive() {
        ReloadSettings()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//MARK: Appearance Page


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
        
        let navController = navigationController as! SettingsNavigationController
        navController.SetAllViewControllerColors()
    }
    
    override var PageTitle: String {
        return "Appearance"
    }
    
}

//MARK: About page

class SettingsAboutPage: SettingsPageViewController {
    override func GetSettings() -> [SettingsSection] {
        return [
            
            SettingsSection(options: [.customViewCell(model: SettingsAppLogoAndVersionView())], customHeight: SettingsAppLogoAndVersionView.height),
            
            SettingsSection(title: "More", options: [
                .navigationCell(model: SettingsNavigationOption(title: "Visit finale.com", icon: UIImage(systemName: "globe"), iconBackgroundColor: .systemBlue, url: URL(string: "https://app.finale.cc"))),
                .navigationCell(model: SettingsNavigationOption(title: "Rate App", icon: UIImage(systemName: "star.fill"), iconBackgroundColor: .systemGreen, url: URL(string: "itms-apps:itunes.apple.com/us/app/apple-store/id1546661013?mt=8&action=write-review"))),
                .navigationCell(model: SettingsNavigationOption(title: "Finale: Daily Habit Tracker", icon: UIImage(named: "Finale: Daily Habit Tracker Icon"), iconBorderWidth: 1, url: URL(string: "https://apps.apple.com/us/app/finale-daily-habit-tracker/id1546661013")))
            ]),
            
            SettingsSection(title: "Help", options: [
                .navigationCell(model: SettingsNavigationOption(title: "Contact Developer", icon: UIImage(systemName: "message.fill"), iconBackgroundColor: .systemBlue, nextPage: nil, url: URL(string: "https://twitter.com/GrantOgany")))
            ]),
            
            SettingsSection(title: "Legal", options: [
                .navigationCell(model: SettingsNavigationOption(title: "Privacy Policy", url: URL(string: "http://app.finale.cc/privacy-policy")))
            ]),
            
        ]
    }
    
    override var PageTitle: String {
        return "About"
    }
    
}


//MARK: Statistics mage
class SettingsStatisticsPage: SettingsPageViewController {
    override func GetSettings() -> [SettingsSection] {
        return [
            
            SettingsSection(options: [
                .staticCell(model: SettingsStaticOption(title: "Level", SetPreview: { return StatsManager.stats.level.description } )),
                .staticCell(model: SettingsStaticOption(title: "Points", SetPreview: { return StatsManager.stats.points.description } )),
                .staticCell(model: SettingsStaticOption(title: "Badges", SetPreview: { return StatsManager.stats.numberOfUnlockedBadges.description } ))
            ]),
            
            SettingsSection(options: [
                .staticCell(model: SettingsStaticOption(title: "Completed Tasks", SetPreview: { return StatsManager.stats.totalCompletedTasks.description } )),
                .staticCell(model: SettingsStaticOption(title: "Completed High Priority Tasks", SetPreview: { return StatsManager.stats.totalCompletedHighPriorityTasks.description } ))
            ]),
            
            SettingsSection(options: [
                .staticCell(model: SettingsStaticOption(title: "Total Days Active", SetPreview: { return StatsManager.stats.totalDaysActive.description } )),
                .staticCell(model: SettingsStaticOption(title: "Streak Days Active", SetPreview: { return StatsManager.stats.consecutiveDaysActive.description } )),
                .staticCell(model: SettingsStaticOption(title: "Streak Without Overdue Tasks", SetPreview: { return StatsManager.stats.consecutiveDaysWithoutOverdueTasks.description } ))
            ]),
            
            SettingsSection(options: [
                .staticCell(model: SettingsStaticOption(title: "Times Shared Finale", SetPreview: { return StatsManager.stats.timesSharedProgress.description } ))
            ]),
            
            SettingsSection(options: [
                .staticCell(model: SettingsStaticOption(title: "Joined Finale", SetPreview: { return StatsManager.stats.dateJoinedApp.formatted(date: .long, time: .omitted) } ))
            ])
            
        ]
    }
    
    override var PageTitle: String {
        return "Statistics"
    }
}




//MARK: Enums & Structs
enum SettingsOptionType {
    case inputFieldCell(model: SettingsInputFieldOption)
    case timePickerCell(model: SettingsTimePickerOption)
    case switchCell(model: SettingsSwitchOption)
    case selectionCell(model: SettingsSelectionOption)
    case navigationCell(model: SettingsNavigationOption)
    case segmentedControlCell(model: SettingsSegmentedControlOption)
    case staticCell(model: SettingsStaticOption)
    
    case customViewCell(model: UIView)
}

struct SettingsInputFieldOption {
    let title: String
    var inputFieldText: String
    let icon: UIImage?
    let iconBackgroundColor: UIColor?
}

struct SettingsTimePickerOption {
    let title: String
    var currentDate: Date
    let icon: UIImage?
    let iconBackgroundColor: UIColor?
    
    init (title: String, currentDate: Date, icon: UIImage? = nil, iconBackground: UIColor? = nil) {
        self.title = title
        self.currentDate = currentDate
        self.icon = icon
        self.iconBackgroundColor = iconBackground
    }
}

struct SettingsSwitchOption {
    let title: String
    var isOn: Bool
    let icon: UIImage?
    let iconBackgroundColor: UIColor?
    var OnChange: ( (_ sender: UISwitch) -> Void )
    
    init (title: String, isOn: Bool, icon: UIImage? = nil, iconBackground: UIColor? = nil, OnChange: @escaping ( (_ sender: UISwitch)->Void )) {
        self.title = title
        self.isOn = isOn
        self.icon = icon
        self.iconBackgroundColor = iconBackground
        self.OnChange = OnChange
    }
}

struct SettingsSelectionOption {
    let title: String
    var selectionID: Int
    var isSelected: Bool
    let icon: UIImage?
    let iconBackgroundColor: UIColor?
    let OnSelect: ( ()->Void )
    
    init (title: String, selectionID: Int, isSelected: Bool, icon: UIImage? = nil, iconBackground: UIColor? = nil, OnSelect: @escaping ( ()->Void )) {
        self.title = title
        self.selectionID = selectionID
        self.isSelected = isSelected
        self.icon = icon
        self.iconBackgroundColor = iconBackground
        self.OnSelect = OnSelect
    }
}

struct SettingsNavigationOption {
    let title: String
    var icon: UIImage? = nil
    var iconBackgroundColor: UIColor? = nil
    var iconBorderWidth: CGFloat? = nil
    var nextPage: SettingsPageViewController? = nil
    var url: URL? = nil
    var OnTap: (()->Void)?
    var SetPreview: (() -> String) = { return "" }
}

struct SettingsSegmentedControlOption {
    let title: String
    let icon: UIImage?
    let iconBackgroundColor: UIColor?
    let items: [String]
    var selectedItem: Int
    let OnValueChange: ((_ sender: UISegmentedControl)->Void)
    
    init (title: String, icon: UIImage? = nil, iconBackgroundColor: UIColor? = nil, items: [String], selectedItem: Int, OnValueChange: @escaping ((_ sender: UISegmentedControl)->Void)) {
        self.title = title
        self.icon = icon
        self.iconBackgroundColor = iconBackgroundColor
        self.items = items
        self.selectedItem = selectedItem
        self.OnValueChange = OnValueChange
    }
}

struct SettingsStaticOption {
    let title: String
    var icon: UIImage? = nil
    var iconBackgroundColor: UIColor? = nil
    var SetPreview: (() -> String) = { return "" }
}

struct SettingsSection {
    var title: String? = nil
    var footer: String? = nil
    var options: [SettingsOptionType]
    var customHeight: CGFloat? = nil
}
