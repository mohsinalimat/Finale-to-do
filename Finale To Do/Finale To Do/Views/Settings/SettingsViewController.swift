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
                .navigationCell(model: SettingsNavigationOption(title: "Personal", icon: UIImage(systemName: "person.text.rectangle.fill"), iconBackgroundColor: .systemGreen, nextPage: SettingsPersonalPage(), SetPreview: {return App.settingsConfig.userFullName;} ))
            ]),
            
            SettingsSection(title: "Preferences", footer: "", options: [
                .navigationCell(model: SettingsNavigationOption(title: "Default List", icon: UIImage(systemName: "folder.fill"), iconBackgroundColor: .systemBlue, nextPage: SettingsDefaultListPage(), SetPreview: { return self.defaultFolderPreview } )),
                .navigationCell(model: SettingsNavigationOption(title: "Notifications", icon: UIImage(systemName: "bell.badge.fill"), iconBackgroundColor: .systemRed, nextPage: SettingsNotificationsPage())),
                .navigationCell(model: SettingsNavigationOption(title: "Widget", icon: UIImage(systemName: "list.bullet.rectangle.fill"), iconBackgroundColor: .systemIndigo, nextPage: SettingsWidgetPage())),
                .navigationCell(model: SettingsNavigationOption(title: "Appearance", icon: UIImage(systemName: "circle.hexagongrid.circle"), iconBackgroundColor: .systemPurple, nextPage: SettingsAppearancePage()))
            ]),

            SettingsSection(title: "More", options: [
                .navigationCell(model: SettingsNavigationOption(title: "Guide", icon: UIImage(systemName: "doc.text.image.fill"), iconBackgroundColor: .systemOrange, nextPage: SettingsGuidePage())),
                .navigationCell(model: SettingsNavigationOption(title: "About", icon: UIImage(systemName: "bookmark.fill"), iconBackgroundColor: .systemTeal, nextPage: SettingsAboutPage(), SetPreview: {return self.appVersion })),
                .navigationCell(model: SettingsNavigationOption(title: "Share", icon: UIImage(systemName: "square.and.arrow.up.fill"), iconBackgroundColor: .systemYellow, OnTap: {
                    let items = [URL(string: "https://apps.apple.com/us/app/finale-to-do/id1622931101")]
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
            if App.settingsConfig.defaultListID == taskList.id {
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
                .inputFieldCell(model: SettingsInputFieldOption(title: "First Name", inputFieldText: App.settingsConfig.userFirstName)),
                .inputFieldCell(model: SettingsInputFieldOption(title: "Last Name", inputFieldText: App.settingsConfig.userLastName))
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
                    App.instance.sideMenuView.userPanel.ReloadPanel()
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
        AnalyticsHelper.LogICloudSyncToggled()
    }
    
    
    override var PageTitle: String {
        return "Personal"
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
        options.append(.selectionCell(model: SettingsSelectionOption(title: App.mainTaskList.name, selectionID: 0, isSelected: App.settingsConfig.defaultListID == App.mainTaskList.id) {
            self.SetDefaultFolder(index: 0)
        }))
        
        for i in 0..<App.userTaskLists.count {
            options.append(.selectionCell(model: SettingsSelectionOption(title: App.userTaskLists[i].name, selectionID: i, isSelected: App.settingsConfig.defaultListID == App.userTaskLists[i].id) {
                self.SetDefaultFolder(index: i+1)
            }))
        }
        
        return [ SettingsSection(footer: "New tasks from the 'overview' page will be added to this list.", options: options) ]
    }
    
    override var PageTitle: String {
        return "Default List"
    }
    
    func SetDefaultFolder(index: Int) {
        App.settingsConfig.defaultListID = index == 0 ? App.mainTaskList.id : App.userTaskLists[index-1].id
        
        AnalyticsHelper.LogChangedDefaultList()
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
                        AnalyticsHelper.LogNotificationsToggled()
                    }
                })
            ])
        ]
    }
    
    func AllowNotificationSuccess () {
        NotificationHelper.ScheduleAllTaskNotifications()
        AnalyticsHelper.LogNotificationsToggled()
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
    
    override var PageTitle: String {
        return "Notifications"
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//MARK: Widget

class SettingsWidgetPage: SettingsPageViewController {
    
    override func GetSettings() -> [SettingsSection] {
        return [
        
            SettingsSection(options: [.customViewCell(model: SettingsWidgetListsView())], customHeight: SettingsWidgetListsView.height),
        
        ]
    }
    
    override var PageTitle: String {
        return "Widget"
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
        
        let navController = navigationController as? SettingsNavigationController
        navController?.SetAllViewControllerColors()
        
        AnalyticsHelper.LogChangedInterface()
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
//                .navigationCell(model: SettingsNavigationOption(title: "Visit FinaleToDo.com", icon: UIImage(systemName: "globe"), iconBackgroundColor: .systemBlue, url: URL(string: "https://finaletodo.com"))),
                .navigationCell(model: SettingsNavigationOption(title: "Rate App", icon: UIImage(systemName: "star.fill"), iconBackgroundColor: .systemGreen, url: URL(string: "itms-apps:itunes.apple.com/us/app/apple-store/id1622931101?mt=8&action=write-review"))),
                .navigationCell(model: SettingsNavigationOption(title: "Finale: Daily Habit Tracker", icon: UIImage(named: "Finale: Daily Habit Tracker Icon"), iconBorderWidth: 1, url: URL(string: "https://apps.apple.com/us/app/finale-daily-habit-tracker/id1546661013")))
            ]),
            
            SettingsSection(title: "Help", options: [
                .navigationCell(model: SettingsNavigationOption(title: "Developer", icon: UIImage(systemName: "message.fill"), iconBackgroundColor: .systemCyan, nextPage: nil, url: URL(string: "https://twitter.com/GrantOgany"))),
                .navigationCell(model: SettingsNavigationOption(title: "Contact Support", icon: UIImage(systemName: "envelope.fill"), iconBackgroundColor: .systemBlue, nextPage: nil, url: URL(string: "mailto:info@finaletodo.com")))
            ]),
            
            SettingsSection(title: "Legal", options: [
                .navigationCell(model: SettingsNavigationOption(title: "Privacy Policy", url: URL(string: "https://finaletodo.com/privacy-policy")))
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

//MARK: Guide page
class SettingsGuidePage: SettingsPageViewController {
    override func GetSettings() -> [SettingsSection] {
        return [
        
            SettingsSection(title: "Tasks", options: [
                .navigationCell(model: SettingsNavigationOption(title: "Create", nextPage: GuidePageViewController(
                    titleText: "Create Task",
                    descriptionText: "Tap the + button to create a new task. New tasks will be added to the list that is currently open."))),
                .navigationCell(model: SettingsNavigationOption(title: "Edit", nextPage: GuidePageViewController(
                    titleText: "Edit Task",
                    descriptionText: "Double tap on the task to quickly change its name and date. Tap anowhere on the screen to stop editing the task."))),
                .navigationCell(model: SettingsNavigationOption(title: "Change details", nextPage: GuidePageViewController(
                    titleText: "Change Task Details",
                    descriptionText: "Long press on the task to peak its details. Tap inside to expand the view and edit the task."))),
                .navigationCell(model: SettingsNavigationOption(title: "Task Priority", nextPage: GuidePageViewController(
                    titleText: "Change Task Priority",
                    descriptionText: "Tasks that contain an exclamation mark in their title are considered \"high priority\". Alternatively, you can set priority from the detailed task view."))),
                .navigationCell(model: SettingsNavigationOption(title: "Complete", nextPage: GuidePageViewController(
                    titleText: "Complete Task",
                    descriptionText: "Tap on the colored handle to complete the task. Alternatively, you can slide the handle all the way to the right."))),
                .navigationCell(model: SettingsNavigationOption(title: "Reorder", nextPage: GuidePageViewController(
                    titleText: "Reorder Tasks",
                    descriptionText: "Drag and drop tasks to reorder them within the list. The 'Overview' page will respect each list's order."))),
            ]),
            
            SettingsSection(title: "Lists", options: [
                .navigationCell(model: SettingsNavigationOption(title: "Create", nextPage: GuidePageViewController(
                    titleText: "Create List",
                    descriptionText: "Tap the '+ Create List' button to create a new list. You can change the list's style by tapping on its icon."))),
                .navigationCell(model: SettingsNavigationOption(title: "Edit", nextPage: GuidePageViewController(
                    titleText: "Edit List",
                    descriptionText: "Long press on the list and tap 'Edit' to change the list's name a style."))),
                .navigationCell(model: SettingsNavigationOption(title: "Reorder", nextPage: GuidePageViewController(
                    titleText: "Reorder Lists",
                    descriptionText: "Drag and drop lists to reorder them within the side menu."))),
                .navigationCell(model: SettingsNavigationOption(title: "Sort Tasks", nextPage: GuidePageViewController(
                    titleText: "Sort Tasks",
                    descriptionText: "Tap the 'Sort' button in the top right corner to select sorting preference for the specific list."))),
            ]),
            
            SettingsSection(title: "Personal", options: [
                .navigationCell(model: SettingsNavigationOption(title: "Level", nextPage: GuidePageViewController(
                    titleText: "Level",
                    descriptionText: "By completing tasks you gain points that are used to increase your level. You get more points for tasks completed on time, and less points for overdue tasks. Reaching certain levels will grant you rewards, so don't forget to check in on your profile page every once in a while.\n\nYou can earn up to \(StatsManager.dailyPointsCap) points per day."))),
                .navigationCell(model: SettingsNavigationOption(title: "Badges", nextPage: GuidePageViewController(
                    titleText: "Badges",
                    descriptionText: "You can recieve honor badges when reaching certain milestones within Finale. You can check each badge progress and your collection on your profile page.")))
            ])
        
        ]
    }
    
    override var PageTitle: String {
        return "Guide"
    }
}

//MARK: Debug page
class SettingsDebugPage: SettingsPageViewController {
    override var PageTitle: String {
        return "Debug"
    }
    
    override func GetSettings() -> [SettingsSection] {
        return [
        
            SettingsSection(options: [
                .navigationCell(model: SettingsNavigationOption(title: "Set level", OnTap: {
                    let alert = UIAlertController(title: "Set Level", message: "Enter new level", preferredStyle: .alert)
                    alert.addTextField { (textField) in
                        textField.keyboardType = .numbersAndPunctuation
                        textField.text = StatsManager.stats.level.description
                    }
                    alert.addAction(UIAlertAction(title: "Set", style: .default, handler: { [weak alert] (_) in
                        let textField = alert?.textFields![0]
                        StatsManager.stats.level = Int(textField!.text!) ?? StatsManager.stats.level
                        App.instance.sideMenuView.userPanel.ReloadPanel()
                    }))
                    self.present(alert, animated: true, completion: nil)
                }))
            ]),
            
            SettingsSection(options: [
                .navigationCell(model: SettingsNavigationOption(title: "Force check all badges", OnTap: {
                    for group in StatsManager.allBadgeGroups {
                        StatsManager.CheckUnlockedBadge(groupID: group.groupID)
                    }
                })),
                .navigationCell(model: SettingsNavigationOption(title: "Unlock all badges", OnTap: {
                    for group in StatsManager.allBadgeGroups {
                        StatsManager.UnlockBadge(badgeGroup: group, badgeIndex: group.numberOfBadges-1, earnPoints: false)
                    }
                })),
                .navigationCell(model: SettingsNavigationOption(title: "Lock all badges", OnTap: {
                    for (groupID, _) in StatsManager.stats.badges {
                        StatsManager.stats.badges[groupID] = -1
                    }
                })),
                .navigationCell(model: SettingsNavigationOption(title: "Unlock badge", OnTap: {
                    let alert = UIAlertController(title: "Set Badge", message: "Enter badge group ID and badge index to unlock", preferredStyle: .alert)
                    alert.addTextField { (textField) in
                        textField.keyboardType = .numbersAndPunctuation
                        textField.placeholder = "Badge group index"
                    }
                    alert.addTextField { (textField) in
                        textField.keyboardType = .numbersAndPunctuation
                        textField.placeholder = "Badge index"
                    }
                    alert.addAction(UIAlertAction(title: "Set", style: .default, handler: { [weak alert] (_) in
                        let badgeGroup = Int((alert?.textFields![0].text)!)!
                        let badgeIndex = Int((alert?.textFields![1].text)!)!
                        if badgeIndex == -1 {
                            StatsManager.stats.badges[badgeGroup] = badgeIndex
                        } else {
                            StatsManager.UnlockBadge(badgeGroup: StatsManager.getBadgeGroup(id: badgeGroup)!, badgeIndex: badgeIndex, earnPoints: false)
                        }
                        
                    }))
                    self.present(alert, animated: true, completion: nil)
                }))])
        ]
    }
}


//MARK: Enums & Structs
enum SettingsOptionType {
    case inputFieldCell(model: SettingsInputFieldOption)
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
}

struct SettingsSwitchOption {
    let title: String
    var isOn: Bool
    var OnChange: ( (_ sender: UISwitch) -> Void )
    
    init (title: String, isOn: Bool, OnChange: @escaping ( (_ sender: UISwitch)->Void )) {
        self.title = title
        self.isOn = isOn
        self.OnChange = OnChange
    }
}

struct SettingsSelectionOption {
    let title: String
    var selectionID: Int
    var isSelected: Bool
    let OnSelect: ( ()->Void )
    
    init (title: String, selectionID: Int, isSelected: Bool, OnSelect: @escaping ( ()->Void )) {
        self.title = title
        self.selectionID = selectionID
        self.isSelected = isSelected
        self.OnSelect = OnSelect
    }
}

struct SettingsNavigationOption {
    let title: String
    var icon: UIImage? = nil
    var iconBackgroundColor: UIColor? = nil
    var iconBorderWidth: CGFloat? = nil
    var nextPage: UIViewController? = nil
    var url: URL? = nil
    var OnTap: (()->Void)?
    var SetPreview: (() -> String) = { return "" }
}

struct SettingsSegmentedControlOption {
    let title: String
    let items: [String]
    var selectedItem: Int
    let OnValueChange: ((_ sender: UISegmentedControl)->Void)
    
    init (title: String, items: [String], selectedItem: Int, OnValueChange: @escaping ((_ sender: UISegmentedControl)->Void)) {
        self.title = title
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
