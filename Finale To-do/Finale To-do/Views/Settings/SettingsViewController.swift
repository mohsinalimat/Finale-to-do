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
        
        self.setViewControllers([SettingsMainPage()], animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if App.selectedTaskListIndex == 0 { App.instance.SelectTaskList(index: 0, closeMenu: false)}
        DispatchQueue.main.async {
            App.instance.SaveSettings()
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
                .navigationCell(model: SettingsNavigationOption(title: "Name", preview: App.settingsConfig.userFullName, icon: UIImage(systemName: "person.text.rectangle.fill"), iconBackgroundColor: .systemGreen, nextPage: SettingsPersonalPage()))
            ]),
            SettingsSection(title: "Preferences", footer: "", options: [
                .navigationCell(model: SettingsNavigationOption(title: "Default list", preview: defaultFolderPreview, icon: UIImage(systemName: "folder.fill"), iconBackgroundColor: .systemBlue, nextPage: SettingsDefaultListPage())),
                .navigationCell(model: SettingsNavigationOption(title: "Notifications", preview: "", icon: UIImage(systemName: "bell.badge.fill"), iconBackgroundColor: .systemRed, nextPage: SettingsNotificationsPage())),
                .navigationCell(model: SettingsNavigationOption(title: "Appearance", preview: "", icon: UIImage(systemName: "circle.hexagongrid.circle"), iconBackgroundColor: .systemPurple, nextPage: SettingsPersonalPage()))
            ]),
            
            SettingsSection(title: "Help", options: [
                .navigationCell(model: SettingsNavigationOption(title: "Guide", preview: "", icon: UIImage(systemName: "doc.text.image.fill"), iconBackgroundColor: .systemOrange, nextPage: SettingsPersonalPage())),
                .navigationCell(model: SettingsNavigationOption(title: "About", preview: "Version 1.0.2", icon: UIImage(systemName: "bookmark.fill"), iconBackgroundColor: .systemTeal, nextPage: SettingsPersonalPage())),
                .navigationCell(model: SettingsNavigationOption(title: "Share", preview: "", icon: UIImage(systemName: "square.and.arrow.up.fill"), iconBackgroundColor: .systemYellow, nextPage: SettingsPersonalPage()))
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
    
}
//MARK: Personal Page
class SettingsPersonalPage: SettingsPageViewController {
    
    override func GetSettings() -> [SettingsSection] {
        return [
            SettingsSection(footer: "Finale uses your name to personalize your experience.", options: [
                .inputFieldCell(model: SettingsInputFieldOption(title: "First name", inputFieldText: App.settingsConfig.userFirstName, icon: nil, iconBackgroundColor: .systemGreen) ),
                .inputFieldCell(model: SettingsInputFieldOption(title: "Last name", inputFieldText: App.settingsConfig.userLastName, icon: nil, iconBackgroundColor: .systemGreen) )
            ]),
        ]
    }
    
    override var PageTitle: String {
        return "Name"
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
        return "Default list"
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
                .switchCell(model: SettingsSwitchOption(title: "Allow notifications", isOn: App.settingsConfig.isNotificationsAllowed) { sender in
                    if sender.isOn {
                        NotificationHelper.RequestNotificationAccess(uiSwitch: sender, settingsNotificationsPage: self)
                    } else {
                        self.HideAllNotificationSettings()
                        App.settingsConfig.isNotificationsAllowed = false
                        App.instance.CancellAllTaskNotifications()
                    }
                })
            ])
        ]
    }
    
    func AllowNotificationSuccess () {
        App.instance.ScheduleAllTaskNotifications()
    }
    
    func ShowAllNotificationSettings () {
        if settingsSections.count > 1 { return }
        
        settingsSections.append(contentsOf: GetAllNotificationSettings())
        tableView.insertSections(IndexSet(1..<3), with: .fade)
        
        if App.settingsConfig.isDailyUpdateOn { ShowDailyUpdateTime() }
        
        tableView.layoutSubviews()
    }
    
    func HideAllNotificationSettings () {
        if settingsSections.count == 1 { return }
        
        settingsSections.removeLast()
        settingsSections.removeLast()
        tableView.deleteSections(IndexSet(1..<3), with: .fade)
    }
    
    func GetAllNotificationSettings () -> [SettingsSection] {
        return [
                SettingsSection(footer: "Finale will send you an overview of your tasks for the day", options: [
                    .switchCell(model: SettingsSwitchOption(title: "Daily overview", isOn: App.settingsConfig.isDailyUpdateOn) { sender in
                        App.settingsConfig.isDailyUpdateOn = sender.isOn
                        if App.settingsConfig.isDailyUpdateOn {
                            self.ShowDailyUpdateTime()
                        } else {
                            self.HideDailyUpdateTime()
                        }
                    })
                ]),
                
                SettingsSection(options: [
                    .appBadgeCount(model: SettingsAppBadgeCountView())
                ], customHeight: SettingsAppBadgeCountView.height)
        ]
    }
    
    func ShowDailyUpdateTime () {
        if settingsSections.count == 1 { return}
        if settingsSections[1].options.count == 2 { return }
        
        settingsSections[1].options.append(.timePickerCell(model: SettingsTimePickerOption(title: "Time", currentDate: App.settingsConfig.dailyUpdateTime)))
        tableView.insertRows(at: [IndexPath(row: 1, section: 1)], with: .fade)
    }
    
    func HideDailyUpdateTime() {
        if settingsSections.count == 1 { return}
        if settingsSections[1].options.count == 1 { return }
        
        settingsSections[1].options.removeLast()
        tableView.deleteRows(at: [IndexPath(row: 1, section: 1)], with: .fade)
    }
    
    @objc func AppBecameActive() {
        ReloadSettings()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}




//MARK: Enums & Structs
enum SettingsOptionType {
    case inputFieldCell(model: SettingsInputFieldOption)
    case pickerCell(model: SettingsPickerOption)
    case timePickerCell(model: SettingsTimePickerOption)
    case switchCell(model: SettingsSwitchOption)
    case selectionCell(model: SettingsSelectionOption)
    case navigationCell(model: SettingsNavigationOption)
    
    case appBadgeCount(model: SettingsAppBadgeCountView)
}

struct SettingsInputFieldOption {
    let title: String
    var inputFieldText: String
    let icon: UIImage?
    let iconBackgroundColor: UIColor?
}

struct SettingsPickerOption {
    let title: String
    var currentSelection: Int
    var menu: UIMenu
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
    let preview: String
    let icon: UIImage?
    let iconBackgroundColor: UIColor
    let nextPage: SettingsPageViewController
}

struct SettingsSection {
    var title: String? = nil
    var footer: String? = nil
    var options: [SettingsOptionType]
    var customHeight: CGFloat? = nil
}
