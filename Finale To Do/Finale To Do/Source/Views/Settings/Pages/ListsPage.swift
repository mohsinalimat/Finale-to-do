//
//  ListsPage.swift
//  Finale To Do
//
//  Created by Grant Oganyan on 6/30/22.
//

import Foundation
import UIKit

class SettingsListsPage: SettingsPageViewController {
    
    override func GetSettings() -> [SettingsSection] {
        var smartListsSwitchOptions = [SettingsOptionType]()
        
        for smartList in SmartList.allCases {
            smartListsSwitchOptions.append(
                .switchCell(model: SettingsSwitchOption(title: smartList.title, isOn: App.settingsConfig.smartLists.contains(smartList), OnChange: { sender in
                    self.SwitchSmartList(sender: sender, smartList: smartList)
                }))
            )
        }
        
        return [
            SettingsSection(footer: "New tasks created from Smart Lists will be added to this list.", options: [
                .navigationCell(model: SettingsNavigationOption(title: "Default List", nextPage: SettingsDefaultListPage(), SetPreview: { return self.defaultFolderPreview } ))
            ]),
            SettingsSection(title: "Smart lists", footer: "Smart lists compile and present your tasks in a special way.", options: smartListsSwitchOptions),
            SettingsSection(footer: "Only show up to five recently completed tasks.", options: [
                .switchCell(model: SettingsSwitchOption(title: "Hide Completed Tasks", isOn: App.settingsConfig.hideCompletedTasks, OnChange: { sender in
                    App.settingsConfig.hideCompletedTasks = sender.isOn
                }))
            ])
        ]
    }
    
    var defaultFolderPreview: String {
        for taskList in App.userTaskLists {
            if App.settingsConfig.defaultListID == taskList.id {
                return taskList.name
            }
        }
        
        return App.mainTaskList.name
    }
    
    override var PageTitle: String {
        return "Lists"
    }
    
    func SwitchSmartList (sender: UISwitch, smartList: SmartList) {
        if sender.isOn {
            if !App.settingsConfig.smartLists.contains(smartList) { App.settingsConfig.smartLists.append(smartList) }
        } else {
            if App.settingsConfig.smartLists.contains(smartList) { App.settingsConfig.smartLists.remove(at: App.settingsConfig.smartLists.firstIndex(of: smartList)!) }
        }
        App.settingsConfig.smartLists = App.settingsConfig.smartLists.sorted { $0.rawValue < $1.rawValue }
        App.instance.sideMenuView.DrawSmartLists()
        App.instance.SelectTaskList(index: 0, closeMenu: false)
    }
    
}

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
        
        return [ SettingsSection(options: options) ]
    }
    
    override var PageTitle: String {
        return "Default List"
    }
    
    func SetDefaultFolder(index: Int) {
        App.settingsConfig.defaultListID = index == 0 ? App.mainTaskList.id : App.userTaskLists[index-1].id
        
        AnalyticsHelper.LogChangedDefaultList()
    }
    
}
