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
            SettingsSection(title: "Personal", footer: "", options: [
                .navigationCell(model: SettingsNavigationOption(title: "Name", preview: App.settingsConfig.userFullName, icon: UIImage(systemName: "person.text.rectangle.fill"), iconBackgroundColor: .systemGreen, nextPage: SettingsPersonalPage()))
            ]),
            SettingsSection(title: "Preferences", footer: "", options: [
                .navigationCell(model: SettingsNavigationOption(title: "Default list", preview: defaultFolderPreview, icon: UIImage(systemName: "folder.fill"), iconBackgroundColor: .systemBlue, nextPage: SettingsDefaultListPage())),
                .navigationCell(model: SettingsNavigationOption(title: "Notifications", preview: "", icon: UIImage(systemName: "bell.badge.fill"), iconBackgroundColor: .systemRed, nextPage: SettingsNotificationsPage())),
                .navigationCell(model: SettingsNavigationOption(title: "Appearance", preview: "", icon: UIImage(systemName: "circle.hexagongrid.circle"), iconBackgroundColor: .systemPurple, nextPage: SettingsPersonalPage()))
            ]),
            
            SettingsSection(title: "Help", footer: "", options: [
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

class SettingsPersonalPage: SettingsPageViewController {
    
    override func GetSettings() -> [SettingsSection] {
        return [
            SettingsSection(title: "", footer: "Finale uses your name to personalize your experience.", options: [
                .inputFieldCell(model: SettingsInputFieldOption(title: "First name", inputFieldText: App.settingsConfig.userFirstName, icon: nil, iconBackgroundColor: .systemGreen) ),
                .inputFieldCell(model: SettingsInputFieldOption(title: "Last name", inputFieldText: App.settingsConfig.userLastName, icon: nil, iconBackgroundColor: .systemGreen) )
            ]),
        ]
    }
    
    override var PageTitle: String {
        return "Name"
    }
    
}

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
        
        return [ SettingsSection(title: "", footer: "New tasks from the 'overview' page will be added to this list.", options: options) ]
    }
    
    override var PageTitle: String {
        return "Default list"
    }
    
    func SetDefaultFolder(index: Int) {
        App.settingsConfig.defaultFolderID = index == 0 ? App.mainTaskList.id : App.userTaskLists[index-1].id
    }
    
}

class SettingsNotificationsPage: SettingsPageViewController {
    
    override init() {
        super.init()
        
        if App.settingsConfig.isNotificationsAllowed { ShowDailyUpdateSettings() }
    }
    
    override func GetSettings() -> [SettingsSection] {
        return [
            SettingsSection(title: "", footer: "Finale will never send you unnecessary alerts, and will only send notifications that you set yourself.", options: [
                .switchCell(model: SettingsSwitchOption(title: "Allow notifications", isOn: App.settingsConfig.isNotificationsAllowed) { sender in
                    if sender.isOn {
                        NotificationHelper.RequestNotificationAccess(uiSwitch: sender, settingsNotificationsPage: self)
                    } else {
                        self.HideDailyUpdateSettings()
                        App.settingsConfig.isNotificationsAllowed = false
                        App.instance.CancellAllTaskNotifications()
                    }
                })
            ])
        ]
    }
    
    func ShowDailyUpdateSettings () {
        if settingsSections.count > 1 { return }
        
        settingsSections.append(GetDailyUpdateSettings())
        tableView.insertSections(IndexSet(integer: 1), with: .fade)
        
        if App.settingsConfig.isDailyUpdateOn { ShowDailyUpdateTime() }
    }
    
    func AllowNotificationSuccess () {
        App.instance.ScheduleAllTaskNotifications()
    }
    
    func HideDailyUpdateSettings () {
        if settingsSections.count == 1 { return }
        
        settingsSections.removeLast()
        tableView.deleteSections(IndexSet(integer: 1), with: .fade)
    }
    
    func GetDailyUpdateSettings () -> SettingsSection {
        return SettingsSection(title: "", footer: "Finale will send you an overview of your tasks for the day", options: [
            .switchCell(model: SettingsSwitchOption(title: "Daily overview", isOn: App.settingsConfig.isDailyUpdateOn) { sender in
                App.settingsConfig.isDailyUpdateOn = sender.isOn
                if App.settingsConfig.isDailyUpdateOn {
                    self.ShowDailyUpdateTime()
                } else {
                    self.HideDailyUpdateTime()
                }
            })
        ])
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



class SettingsTableCell: UITableViewCell, UITextFieldDelegate {
    
    static let identifier: String = "SettingsCell"
    
    let padding = 16.0
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .left
        label.textColor = .label
        return label
    }()
    let iconContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        return view
    }()
    let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    let switchView: UISwitch = {
        let s = UISwitch()
        s.onTintColor = .defaultColor
        s.alpha = 0
        return s
    }()
    let inputField: UITextField = {
        let textField = UITextField()
        textField.textColor = .label
        textField.textColor = .systemGray
        textField.textAlignment = .right
        textField.alpha = 0
        return textField
    }()
    let pickerButton: UIButton = {
        let pickerButton = UIButton()
        pickerButton.showsMenuAsPrimaryAction = true
        pickerButton.layer.cornerRadius = 8
        pickerButton.backgroundColor = AppColors.currentTheme == .Light ? .systemGray5 : .systemGray3
        pickerButton.setTitleColor(UIColor.label, for: .normal)
        pickerButton.alpha = 0
        pickerButton.titleLabel?.font = .preferredFont(forTextStyle: .subheadline)
        return pickerButton
    }()
    let timePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .inline
        datePicker.datePickerMode = .time
        datePicker.alpha = 0
        return datePicker
    }()
    let previewLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .right
        label.textColor = .systemGray
        label.alpha = 0
        return label
    }()
    let selectionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .defaultColor
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: reuseIdentifier)
        
        iconContainer.addSubview(iconView)
        self.contentView.addSubview(iconContainer)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(switchView)
        self.contentView.addSubview(inputField)
        self.contentView.addSubview(pickerButton)
        self.contentView.addSubview(timePicker)
        self.contentView.addSubview(previewLabel)
        self.contentView.addSubview(selectionImageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let rowWidth = self.contentView.frame.width
        let rowHeight = self.contentView.frame.height

        let iconContainerSize = iconView.image == nil ? 0 : contentView.frame.height-padding*0.9
        iconContainer.frame = CGRect(x: padding, y: 0.5*(rowHeight-iconContainerSize), width: iconContainerSize, height: iconContainerSize)
        iconView.frame.size = CGSize(width: iconContainerSize*0.7, height: iconContainerSize*0.7)
        iconView.frame.origin = CGPoint(x: 0.5*(iconContainerSize-iconView.frame.width), y: 0.5*(iconContainerSize-iconView.frame.height))

        let titleWidth = titleLabel.text!.size(withAttributes:[.font: UIFont.preferredFont(forTextStyle: .body)]).width
        titleLabel.frame = CGRect(x: iconContainerSize == 0 ? padding : iconContainer.frame.maxX + padding, y: 0, width: min(titleWidth, rowWidth-padding-iconContainerSize), height: rowHeight)
        
        let functionItemWidth = rowWidth-titleLabel.frame.maxX-padding*(self.accessoryType == .none ? 2 : 1.3)
        switchView.frame.origin = CGPoint(x: rowWidth-switchView.frame.width-padding, y: 0.5*(rowHeight-switchView.frame.height))
        inputField.frame = CGRect(x: titleLabel.frame.maxX + padding, y: 0, width: functionItemWidth, height: rowHeight)
        inputField.delegate = self
        pickerButton.frame.size = CGSize(width: functionItemWidth*0.7, height: rowHeight-padding*1.1)
        pickerButton.frame.origin = CGPoint(x: rowWidth-pickerButton.frame.width-padding, y: 0.5*(rowHeight-pickerButton.frame.height))
        timePicker.frame.size = CGSize(width: functionItemWidth+padding*0.7, height: timePicker.frame.height)
        timePicker.frame.origin = CGPoint(x: titleLabel.frame.maxX + padding, y: 0.5*(rowHeight-timePicker.frame.height))
        previewLabel.frame = CGRect(x: titleLabel.frame.maxX + padding, y: 0, width: functionItemWidth, height: rowHeight)
        
        let selectionImageSize = contentView.frame.height-padding*1.5
        selectionImageView.frame = CGRect(x: rowWidth-selectionImageSize-padding, y: 0.5*(rowHeight-selectionImageSize), width: selectionImageSize, height: selectionImageSize)
    }
    
    func Setup(settingsOption: SettingsOptionType) {
        switch settingsOption {
        case .inputFieldCell(let model):
            titleLabel.text = model.title
            iconView.image = model.icon
            iconContainer.backgroundColor = model.iconBackgroundColor
            inputField.text = model.inputFieldText
            inputField.alpha = 1
            self.accessoryType = .none
            break
        case .pickerCell(let model):
            titleLabel.text = model.title
            iconView.image = model.icon
            iconContainer.backgroundColor = model.iconBackgroundColor
            pickerButton.setTitle(model.menu.children[model.currentSelection].title, for: .normal)
            pickerButton.menu = model.menu
            pickerButton.alpha = 1
            self.accessoryType = .none
            break
        case .switchCell(let model):
            titleLabel.text = model.title
            iconView.image = model.icon
            iconContainer.backgroundColor = model.iconBackgroundColor
            switchView.isOn = model.isOn
            switchView.alpha = 1
            OnSwitchChange = model.OnChange
            switchView.addTarget(self, action: #selector(OnSwitchChageValueChange), for: .valueChanged)
            self.accessoryType = .none
            break
        case .navigationCell(let model):
            titleLabel.text = model.title
            iconView.image = model.icon
            iconContainer.backgroundColor = model.iconBackgroundColor
            previewLabel.text = model.preview
            previewLabel.alpha = 1
            self.accessoryType = .disclosureIndicator
            break
        case .timePickerCell(let model):
            titleLabel.text = model.title
            iconView.image = model.icon
            iconContainer.backgroundColor = model.iconBackgroundColor
            timePicker.date = model.currentDate
            timePicker.alpha = 1
            self.accessoryType = .none
        case .selectionCell(let model):
            titleLabel.text = model.title
            iconView.image = model.icon
            iconContainer.backgroundColor = model.iconBackgroundColor
            selectionImageView.image = UIImage(systemName: model.isSelected ? "checkmark" : "")
            selectionImageView.alpha = 1
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconView.image = nil
        titleLabel.text = ""
        switchView.alpha = 0
        inputField.alpha = 0
        pickerButton.alpha = 0
        timePicker.alpha = 0
        previewLabel.alpha = 0
        selectionImageView.alpha = 0
    }
    
    var OnSwitchChange: ((_ sender: UISwitch) -> Void)!
    @objc func OnSwitchChageValueChange (sender: UISwitch) {
        OnSwitchChange(sender)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if titleLabel.text == "First name" {
            App.settingsConfig.userFirstName = textField.text!
        } else {
            App.settingsConfig.userLastName = textField.text!
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        DispatchQueue.main.async {
            textField.selectedTextRange = textField.textRange(from: textField.endOfDocument, to: textField.endOfDocument)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.isEmpty ?? true { return }
        
        if textField.text?.first == " " {
            textField.text?.removeFirst()
        }
    }
    
    
    func SetThemeColors() {
        UIView.animate(withDuration: 0.25) {
            self.pickerButton.backgroundColor = AppColors.currentTheme == .Light ? .systemGray5 : .systemGray3
        }
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        SetThemeColors()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

enum SettingsOptionType {
    case inputFieldCell(model: SettingsInputFieldOption)
    case pickerCell(model: SettingsPickerOption)
    case timePickerCell(model: SettingsTimePickerOption)
    case switchCell(model: SettingsSwitchOption)
    case selectionCell(model: SettingsSelectionOption)
    case navigationCell(model: SettingsNavigationOption)
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
    let title: String
    let footer: String?
    var options: [SettingsOptionType]
}
