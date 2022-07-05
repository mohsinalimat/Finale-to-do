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
            SettingsSection(footer: "Disable to only show up to five recently completed tasks.", options: [
                .switchCell(model: SettingsSwitchOption(title: "Show Completed Tasks", isOn: !App.settingsConfig.hideCompletedTasks, OnChange: { sender in
                    App.settingsConfig.hideCompletedTasks = !sender.isOn
                    App.instance.SelectTaskList(index: App.selectedTaskListIndex, closeMenu: false)
                }))
            ]),
            SettingsSection(title: "Smart lists", footer: "Smart lists compile and present your tasks in a special way.", options: smartListsSwitchOptions),
            SettingsSection(footer: "Select personal lists whose tasks will be included in Smart Lists.", options: [ .navigationCell(model: SettingsNavigationOption(title: "Show in Smart Lists", nextPage: SettingsIncludedInSmartListsPage())) ]),
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

class SettingsIncludedInSmartListsPage: SettingsPageViewController{
    override func GetSettings() -> [SettingsSection] {
        return [ SettingsSection(options: [.customViewCell(model: SettingsIncludedInSmartListsView())], customHeight: SettingsIncludedInSmartListsView.height) ]
    }
    
    override var PageTitle: String {
        return "Show in Smart List"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        App.instance.SelectTaskList(index: App.selectedTaskListIndex, closeMenu: false)
        App.instance.sideMenuView.UpdateSmartListTasksCount()
    }
}


//MARK: Default Notifications Type View
class SettingsIncludedInSmartListsView: UIView {
    static var height: CGFloat {
        return CGFloat(16 + 45*(App.userTaskLists.count+2))
    }
    let selectionRowHeight = 45.0
    
    let padding = 16.0
    var rowWidth: CGFloat!
    let rowHeight: CGFloat
    let rowsContainer = UIView()
    
    var selectionRows = [SettingsSelectionRow]()
    
    init() {
        self.rowHeight = SettingsAppBadgeCountView.height
        super.init(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 0, height: rowHeight)))
        
        self.addSubview(rowsContainer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        rowWidth = superview!.frame.width
        let paddedRowWidth = rowWidth - padding*2
        self.frame.size.width = rowWidth
        
        SetupRows()
        for row in selectionRows { rowsContainer.addSubview(row) }
        rowsContainer.frame = CGRect(x: 0, y: padding*0.5, width: rowWidth, height: Double(selectionRows.count)*selectionRowHeight)
    }
    
    func SetupRows () {
        if selectionRows.count != 0 { return }
        
        selectionRows.append(
            SettingsSelectionRow(frame: CGRect(x: 0, y: Double(0)*selectionRowHeight, width: rowWidth, height: selectionRowHeight),
                              title: "All",
                              index: 0,
                              isSelected: App.settingsConfig.listsShownInSmartLists.count == 0,
                              isNone: true,
                              onSelect: SelectOption,
                              onDeselect: DeselectOption))
        
        selectionRows.append(
            SettingsSelectionRow(frame: CGRect(x: 0, y: Double(1)*selectionRowHeight, width: rowWidth, height: selectionRowHeight),
                                 title: App.mainTaskList.name,
                                  index: 1,
                                  isSelected: App.settingsConfig.listsShownInSmartLists.contains(App.mainTaskList.id),
                                  isNone: false,
                                  onSelect: SelectOption,
                                  onDeselect: DeselectOption))
        
        for i in 2..<App.userTaskLists.count+2 {
            selectionRows.append(
                SettingsSelectionRow(frame: CGRect(x: 0, y: Double(i)*selectionRowHeight, width: rowWidth, height: selectionRowHeight),
                                     title: App.userTaskLists[i-2].name,
                                     index: i,
                                     isSelected: App.settingsConfig.listsShownInSmartLists.contains(App.userTaskLists[i-2].id),
                                     isNone: false,
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
            App.settingsConfig.listsShownInSmartLists.removeAll()
        } else {
            let tasklistID = index == 1 ? App.mainTaskList.id : App.userTaskLists[index-2].id
            if !App.settingsConfig.listsShownInSmartLists.contains(tasklistID) {
                App.settingsConfig.listsShownInSmartLists.append(tasklistID)
                //Log Analytics
            }
        }
        selectionRows[index].isSelected = true
        
        if App.settingsConfig.listsShownInSmartLists.count >= App.userTaskLists.count + 1 {
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
        if App.settingsConfig.listsShownInSmartLists.contains(tasklistID) {
            App.settingsConfig.listsShownInSmartLists.remove(at: App.settingsConfig.listsShownInSmartLists.firstIndex(of: tasklistID)!)
        }
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
