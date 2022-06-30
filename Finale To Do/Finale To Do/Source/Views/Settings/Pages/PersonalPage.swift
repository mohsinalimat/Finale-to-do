//
//  PersonalPage.swift
//  Finale To Do
//
//  Created by Grant Oganyan on 6/30/22.
//

import Foundation
import UIKit

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
            
            if let lastSyncDate = keyStore.object(forKey: SaveManager.instance.lastICloudSyncKey) as? Date {
                let deviceName = keyStore.string(forKey: SaveManager.instance.deviceNameKey) ?? "Unknown device"
                let confirmationVC = ICloudSyncConfirmationViewController(
                    lastICloudSync: lastSyncDate,
                    deviceName: deviceName,
                 OnCancelled: {
                     sender.setOn(false, animated: true)
                }, OnConfirm: {
                    App.settingsConfig.isICloudSyncOn = true
                    SaveManager.instance.LoadICloudData(iCloudKey: NSUbiquitousKeyValueStore())
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
                    SaveManager.instance.SaveSettings()
                    SaveManager.instance.SaveData()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.ReloadSettings()
                        self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
                    }
                })
                if #available(iOS 15.0, *) {
                    if let sheet = confirmationVC.sheetPresentationController {
                        sheet.detents = [.medium()]
                    }
                }
                self.present(confirmationVC, animated: true)
            } else {
                App.settingsConfig.isICloudSyncOn = true
                self.ReloadSettings()
                self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
            }
        } else {
            SaveManager.instance.RemoveICloudSaveFiles()
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
