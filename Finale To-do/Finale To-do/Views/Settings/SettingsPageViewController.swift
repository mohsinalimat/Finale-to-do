//
//  SettingsPersonalViewController.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/28/22.
//

import Foundation
import UIKit

class SettingsPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    let padding = 16.0
    let rowHeight = 46.0
    
    var tableView: UITableView!
    
    var settingsSections: [SettingsSection]!
    
    init () {
        super.init(nibName: nil, bundle: nil)
        ReloadSettings()
        self.view.backgroundColor = .systemGray6
        self.title = PageTitle
        
        let viewWidth = self.view.frame.width
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: viewWidth, height: self.view.frame.height), style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SettingsTableCell.self, forCellReuseIdentifier: SettingsTableCell.identifier)
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TapOutside)))
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: .leastNonzeroMagnitude))
        
        self.view.addSubview(tableView)
    }
    
    func GetSettings () -> [SettingsSection] {
        return [SettingsSection]()
    }
    var PageTitle: String {
        return ""
    }
    
    func ReloadSettings () {
        settingsSections = GetSettings()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingsSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  settingsSections[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableCell.identifier, for: indexPath) as! SettingsTableCell
        
        cell.Setup(settingsOption:  settingsSections[indexPath.section].options[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settingsSections[section].title
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return settingsSections[section].footer
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return settingsSections[indexPath.section].customHeight ?? rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model =  settingsSections[indexPath.section].options[indexPath.row]
        switch model {
        case .inputFieldCell(let model):
            let cell = tableView.cellForRow(at: indexPath) as! SettingsTableCell
            cell.inputField.becomeFirstResponder()
            break
        case .pickerCell(let model):
            break
        case .switchCell(let model):
            break
        case .navigationCell(let model):
            show(model.nextPage, sender: self)
            break
        case .timePickerCell(let model):
            break
        case .selectionCell(let model):
            model.OnSelect()
            for cell in tableView.visibleCells {
                let x = cell as! SettingsTableCell
                x.selectionImageView.image = UIImage(systemName: "")
            }
            let selectedCell = tableView.cellForRow(at: indexPath) as! SettingsTableCell
            selectedCell.selectionImageView.image = UIImage(systemName: "checkmark")
            navigationController?.popViewController(animated: true)
            break
        case .appBadgeCount(let model):
            break
        }
    }
    
    @objc func TapOutside(sender: UITapGestureRecognizer) {
        sender.cancelsTouchesInView = false
        tableView.endEditing(false)
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
    let customViewContainer: UIView = {
        let view = UIView()
        view.alpha = 0
        return view
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
        self.contentView.addSubview(customViewContainer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let rowWidth = self.contentView.frame.width
        let rowHeight = self.contentView.frame.height

        let iconContainerSize = iconView.image == nil ? 0 : contentView.frame.height-padding*0.9
        iconContainer.frame = CGRect(x: padding, y: 0.5*(rowHeight-iconContainerSize), width: iconContainerSize, height: iconContainerSize)
        iconView.frame.size = CGSize(width: iconContainerSize*0.7, height: iconContainerSize*0.7)
        iconView.frame.origin = CGPoint(x: 0.5*(iconContainerSize-iconView.frame.width), y: 0.5*(iconContainerSize-iconView.frame.height))

        let titleWidth = titleLabel.text == nil ? 0 : titleLabel.text!.size(withAttributes:[.font: UIFont.preferredFont(forTextStyle: .body)]).width
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
        
        customViewContainer.frame = CGRect(x: 0, y: 0, width: rowWidth, height: rowHeight)
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
        case .appBadgeCount(let model):
            customViewContainer.addSubview(model)
            customViewContainer.alpha = 1
            selectionStyle = .none
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
        customViewContainer.alpha = 0
        self.selectionStyle = .default
        for subview in customViewContainer.subviews { subview.removeFromSuperview() }
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