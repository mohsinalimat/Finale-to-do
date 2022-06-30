//
//  NotificationsPage.swift
//  Finale To Do
//
//  Created by Grant Oganan on 6/30/22.
//

import Foundation
import UIKit

class SettingsNotificationsPage: SettingsPageViewController {
    
    override init() {
        super.init()
        
        if App.settingsConfig.isNotificationsAllowed { ShowAllNotificationSettings() }
    }
    
    override func GetSettings() -> [SettingsSection] {
        return [
            SettingsSection(footer: "Finale To Do will never send you unnecessary alerts, and will only send notifications that you set yourself.", options: [
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
        tableView.insertSections(IndexSet(1..<settingsSections.count), with: .fade)
    }
    
    func HideAllNotificationSettings () {
        if settingsSections.count == 1 { return }
        
        let totalSections = settingsSections.count
        for _ in 1..<totalSections {
            settingsSections.removeLast()
        }
        tableView.deleteSections(IndexSet(1..<totalSections), with: .fade)
    }
    
    func GetAllNotificationSettings () -> [SettingsSection] {
        return [
            SettingsSection(footer: "Finale To Do will send you up to 5 notifications every two minutes until you open the app.", options: [.switchCell(model: SettingsSwitchOption(title: "Nagging Mode", isOn: App.settingsConfig.isNaggingModeOn, OnChange: { sender in
                App.settingsConfig.isNaggingModeOn = sender.isOn
            }))]),
            SettingsSection(options: [
                .navigationCell(model: SettingsNavigationOption(title: "Default Notifications", nextPage: SettingsNotificationsDefaultNotificationsPage()))
            ]),
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

class SettingsNotificationsDefaultNotificationsPage: SettingsPageViewController {
    
    override func GetSettings() -> [SettingsSection] {
        return [
            SettingsSection(options: [.customViewCell(model: SettingsDefaultNotificationTypeView(isWithDueTime: true))], customHeight: SettingsDefaultNotificationTypeView.height),
            SettingsSection(options: [.customViewCell(model: SettingsDefaultNotificationTypeView(isWithDueTime: false))], customHeight: SettingsDefaultNotificationTypeView.height)
        ]
    }
    
    
    
    override var PageTitle: String {
        return "Default Notifications"
    }
    
}

