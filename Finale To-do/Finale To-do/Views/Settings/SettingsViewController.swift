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
        super.init(rootViewController: SettingsViewController() )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let padding = 16.0
    let rowHeight = 46.0
    
    var tableView: UITableView!
    
    var SettingsSections: [SettingsSection]!
    
    
    init () {
        super.init(nibName: nil, bundle: nil)
        self.SettingsSections = GetSetting()
        self.view.backgroundColor = .systemGray6
        self.title = "Settings"
        
        let viewWidth = self.view.frame.width
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: viewWidth, height: rowHeight*30), style: .insetGrouped)
        tableView.rowHeight = rowHeight
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SettingsTableCell.self, forCellReuseIdentifier: SettingsTableCell.identifier)
        
        self.view.addSubview(tableView)
    }
    
    
    
    
//MARK: TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingsSections[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableCell.identifier, for: indexPath) as! SettingsTableCell
        
        cell.Setup(settingsOption: SettingsSections[indexPath.section].options[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return SettingsSections[section].title
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return SettingsSections[section].footer
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = SettingsSections[indexPath.section].options[indexPath.row]
        switch model {
        case .inputFieldCell(let model):
            model.OnPress()
            break
        case .pickerCell(let model):
            model.OnPress()
            break
        case .switchCell(let model):
            model.OnPress()
            break
        case .staitcCell(let model):
            model.OnPress()
            break
        case .timePickerCell(let model):
            model.OnPress()
        case .closeButton(let onTap):
            onTap()
        }
    }
    
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 3 || indexPath.section == 4  { return true }
        return false
    }
    
    var defaultFolderMenu: UIMenu {
        var items = [UIAction]()
        
        let mainTask = UIAction(title: App.mainTaskList.name, state: .off) { [self] _ in  }
        items.append(mainTask)
        for taskList in App.userTaskLists {
            let item = UIAction(title: taskList.name, state: .off) { [self] _ in }
            items.append(item)
        }
        return UIMenu(title: "", children: items.reversed())
    }
    
    
//MARK: Settings options setup
    
    func GetSetting() -> [SettingsSection] {
        return [
            SettingsSection(title: "Personal", footer: "Finale uses your name to personalize your experience.", options: [
                .inputFieldCell(model:
                    SettingsInputFieldOption(title: "First name", inputFieldText: App.settingsConfig.userFirstName, icon: UIImage(systemName: "person.text.rectangle"), iconBackgroundColor: .systemGreen, OnPress: {})),
                .inputFieldCell(model:
                    SettingsInputFieldOption(title: "Last name", inputFieldText: App.settingsConfig.userLastName, icon: UIImage(systemName: "person.text.rectangle"), iconBackgroundColor: .systemRed, OnPress: {}))
            ]),
            
            SettingsSection(title: "", footer: "Tasks created from the 'overview' page will be added to this folder.", options: [
                .pickerCell(model:
                    SettingsPickerOption(title: "Default folder", currentSelection: 0, menu: defaultFolderMenu, icon: UIImage(systemName: "folder.fill"), iconBackgroundColor: .systemBlue, OnPress: {}))
            ]),
            
            SettingsSection(title: "", footer: "Finale will send you a notification in the morning with your outlook for the day.", options: [
                .switchCell(model:
                    SettingsSwitchOption(title: "Morning update", isOn: App.settingsConfig.isMorningUpdateOn, icon: UIImage(systemName: "sun.max.fill"), iconBackgroundColor: .systemOrange, OnPress: {})),
                .timePickerCell(model:
                    SettingsTimePickerOption(title: "Update time", currentDate: App.settingsConfig.morningUpdateTime, icon: UIImage(systemName: "deskclock.fill"), iconBackgroundColor: .systemCyan, OnPress: {}))
            ]),
            
            SettingsSection(title: "", footer: "", options: [
                .staitcCell(model: SettingsStaticOption(title: "Appearance", preview: "", icon: UIImage(systemName: "circle.hexagongrid.circle"), iconBackgroundColor: .systemPurple) {
                    self.show(SettingsAppearanceViewController(), sender: nil)
                })
            ]),
            
            SettingsSection(title: "", footer: "", options: [
                .closeButton(onTap: { self.dismiss(animated: true) } )
            ])
        ]
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


class SettingsTableCell: UITableViewCell, UITextFieldDelegate {
    
    static let identifier: String = "SettingsCell"
    
    let padding = 12.0
    
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: reuseIdentifier)
        
        iconContainer.addSubview(iconView)
        self.contentView.addSubview(iconContainer)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(switchView)
        self.contentView.addSubview(inputField)
        self.contentView.addSubview(pickerButton)
        self.contentView.addSubview(timePicker)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let rowWidth = self.contentView.frame.width
        let rowHeight = self.contentView.frame.height

        let iconContainerSize = contentView.frame.height-padding
        iconContainer.frame = CGRect(x: padding, y: padding*0.5, width: iconContainerSize, height: iconContainerSize)
        iconView.frame.size = CGSize(width: iconContainerSize*0.7, height: iconContainerSize*0.7)
        iconView.frame.origin = CGPoint(x: 0.5*(iconContainerSize-iconView.frame.width), y: 0.5*(iconContainerSize-iconView.frame.height))

        let titleWidth = titleLabel.text!.size(withAttributes:[.font: UIFont.preferredFont(forTextStyle: .body)]).width
        titleLabel.frame = CGRect(x: iconContainer.frame.maxX + padding, y: 0, width: min(titleWidth, rowWidth-padding-iconContainerSize), height: rowHeight)
        
        let functionItemWidth = rowWidth-titleLabel.frame.maxX-padding*2
        switchView.frame.origin = CGPoint(x: rowWidth-switchView.frame.width-padding, y: 0.5*(rowHeight-switchView.frame.height))
        inputField.frame = CGRect(x: titleLabel.frame.maxX + padding, y: 0, width: functionItemWidth, height: rowHeight)
        inputField.delegate = self
        pickerButton.frame.size = CGSize(width: functionItemWidth*0.7, height: rowHeight-padding*1.1)
        pickerButton.frame.origin = CGPoint(x: rowWidth-pickerButton.frame.width-padding, y: 0.5*(rowHeight-pickerButton.frame.height))
        timePicker.frame.size = CGSize(width: functionItemWidth+padding*0.7, height: timePicker.frame.height)
        timePicker.frame.origin = CGPoint(x: titleLabel.frame.maxX + padding, y: 0.5*(rowHeight-timePicker.frame.height))
        
        
        if titleLabel.alpha == 0 && iconContainer.alpha == 0 {
            let closeLabel = UILabel(frame: contentView.frame)
            closeLabel.text = "Close"
            closeLabel.textColor = .white
            closeLabel.textAlignment = .center
            
            contentView.addSubview(closeLabel)
        }
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
            self.accessoryType = .none
            break
        case .staitcCell(let model):
            titleLabel.text = model.title
            iconView.image = model.icon
            iconContainer.backgroundColor = model.iconBackgroundColor
            self.accessoryType = .disclosureIndicator
            break
        case .timePickerCell(model: let model):
            titleLabel.text = model.title
            iconView.image = model.icon
            iconContainer.backgroundColor = model.iconBackgroundColor
            timePicker.date = model.currentDate
            timePicker.alpha = 1
            self.accessoryType = .none
        case .closeButton:
            iconContainer.alpha = 0
            titleLabel.alpha = 0
            titleLabel.text = ""
            self.backgroundColor = .defaultColor
            break
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if titleLabel.text == "First name" {
            App.settingsConfig.userFirstName = textField.text!
        } else {
            App.settingsConfig.userLastName = textField.text!
        }
        App.instance.SaveSettings()
        
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
    case staitcCell(model: SettingsStaticOption)
    case closeButton(onTap: (()->Void))
}

struct SettingsInputFieldOption {
    let title: String
    var inputFieldText: String
    let icon: UIImage?
    let iconBackgroundColor: UIColor
    let OnPress: ( () -> Void )
}

struct SettingsPickerOption {
    let title: String
    var currentSelection: Int
    var menu: UIMenu
    let icon: UIImage?
    let iconBackgroundColor: UIColor
    let OnPress: ( () -> Void )
}

struct SettingsTimePickerOption {
    let title: String
    var currentDate: Date
    let icon: UIImage?
    let iconBackgroundColor: UIColor
    let OnPress: ( () -> Void )
}

struct SettingsSwitchOption {
    let title: String
    var isOn: Bool
    let icon: UIImage?
    let iconBackgroundColor: UIColor
    let OnPress: ( () -> Void )
}

struct SettingsStaticOption {
    let title: String
    let preview: String
    let icon: UIImage?
    let iconBackgroundColor: UIColor
    let OnPress: ( () -> Void )
}

struct SettingsSection {
    let title: String
    let footer: String?
    let options: [SettingsOptionType]
}
