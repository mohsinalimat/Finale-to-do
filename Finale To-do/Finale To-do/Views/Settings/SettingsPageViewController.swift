//
//  SettingsPersonalViewController.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/28/22.
//

import Foundation
import UIKit

class SettingsPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIDynamicTheme {
    
    
    let padding = 16.0
    let rowHeight = 46.0
    
    var tableView: UITableView!
    
    var settingsSections: [SettingsSection]!
    
    var indexPathToUpdate: IndexPath?
    
    init () {
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = ThemeManager.currentTheme.settingsBackgroundColor
        overrideUserInterfaceStyle = App.settingsConfig.interface == .System ? .unspecified : App.settingsConfig.interface == .Light ? .light : .dark
        ReloadSettings()
        self.title = PageTitle
        
        let viewWidth = self.view.frame.width
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: viewWidth, height: self.view.frame.height), style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SettingsTableCell.self, forCellReuseIdentifier: SettingsTableCell.identifier)
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TapOutside)))
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: .leastNonzeroMagnitude))
        tableView.backgroundColor = ThemeManager.currentTheme.interface == .Light ? .systemGray6 : .black
        
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
        case .inputFieldCell(_):
            let cell = tableView.cellForRow(at: indexPath) as! SettingsTableCell
            cell.inputField.becomeFirstResponder()
            break
        case .navigationCell(let model):
            if model.nextPage != nil {
                show(model.nextPage!, sender: self)
                indexPathToUpdate = indexPath
            } else if model.url != nil {
                UIApplication.shared.open(model.url!)
            } else if model.OnTap != nil {
                model.OnTap!()
            }
            
            break
        case .selectionCell(let model):
            model.OnSelect()
            for cell in tableView.visibleCells {
                let x = cell as! SettingsTableCell
                x.selectionImageView.image = UIImage(systemName: "")
            }
            let selectedCell = tableView.cellForRow(at: indexPath) as! SettingsTableCell
            selectedCell.selectionImageView.image = UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))
            navigationController?.popViewController(animated: true)
            break
        default: break
        }
    }
    
    @objc func TapOutside(sender: UITapGestureRecognizer) {
        sender.cancelsTouchesInView = false
        tableView.endEditing(false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
        if self.isMovingFromParent {
            let prevPage = navigationController?.topViewController as! SettingsPageViewController
            if prevPage.indexPathToUpdate != nil {
                let cell = prevPage.tableView.cellForRow(at: prevPage.indexPathToUpdate!) as! SettingsTableCell
                cell.ReloadPreview()
            }
        }
        
    }
    
    func ReloadThemeColors() {
        overrideUserInterfaceStyle = App.settingsConfig.interface == .System ? .unspecified : App.settingsConfig.interface == .Light ? .light : .dark
        UIView.animate(withDuration: 0.25) { [self] in
            if tableView != nil {
                tableView.backgroundColor = ThemeManager.currentTheme.interface == .Light ? .systemGray6 : .black
                for cell in tableView.visibleCells {
                    let c = cell as! SettingsTableCell
                    c.ReloadThemeColors()
                }
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        ThemeManager.currentTheme = App.settingsConfig.GetCurrentTheme()
        App.instance.SetSubviewColors(of: self.view)
        ReloadThemeColors()
    }
    
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}





class SettingsTableCell: UITableViewCell, UITextFieldDelegate, UIDynamicTheme {
    
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
        view.clipsToBounds = true
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
        s.onTintColor = ThemeManager.currentTheme.primaryElementColor(tasklistColor: .defaultColor)
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
        imageView.tintColor = ThemeManager.currentTheme.primaryElementColor(tasklistColor: .defaultColor)
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0
        return imageView
    }()
    
    var segmentedControl: UISegmentedControl?
    
    let customViewContainer: UIView = {
        let view = UIView()
        view.alpha = 0
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = ThemeManager.currentTheme.interface == .Light ? .white : .systemGray6
        
        iconContainer.addSubview(iconView)
        self.contentView.addSubview(iconContainer)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(switchView)
        self.contentView.addSubview(inputField)
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
        iconView.frame.size = CGSize(width: iconContainer.backgroundColor == nil ? iconContainerSize : iconContainerSize*0.7, height: iconContainer.backgroundColor == nil ? iconContainerSize : iconContainerSize*0.7)
        iconView.frame.origin = CGPoint(x: 0.5*(iconContainerSize-iconView.frame.width), y: 0.5*(iconContainerSize-iconView.frame.height))

        let titleWidth = titleLabel.text == nil ? 0 : titleLabel.text!.size(withAttributes:[.font: UIFont.preferredFont(forTextStyle: .body)]).width
        titleLabel.frame = CGRect(x: iconContainerSize == 0 ? padding : iconContainer.frame.maxX + padding, y: 0, width: min(titleWidth, rowWidth-padding-iconContainerSize), height: rowHeight)
        
        let functionItemWidth = rowWidth-titleLabel.frame.maxX-padding*(self.accessoryType == .none ? 2 : 1.3)
        switchView.frame.origin = CGPoint(x: rowWidth-switchView.frame.width-padding, y: 0.5*(rowHeight-switchView.frame.height))
        inputField.frame = CGRect(x: titleLabel.frame.maxX + padding, y: 0, width: functionItemWidth, height: rowHeight)
        inputField.delegate = self
        timePicker.frame.size = CGSize(width: functionItemWidth+padding*0.7, height: timePicker.frame.height)
        timePicker.frame.origin = CGPoint(x: titleLabel.frame.maxX + padding, y: 0.5*(rowHeight-timePicker.frame.height))
        previewLabel.frame = CGRect(x: titleLabel.frame.maxX + padding, y: 0, width: functionItemWidth, height: rowHeight)
        
        let selectionImageSize = contentView.frame.height-padding*1.5
        selectionImageView.frame = CGRect(x: rowWidth-selectionImageSize-padding, y: 0.5*(rowHeight-selectionImageSize), width: selectionImageSize, height: selectionImageSize)
        
        customViewContainer.frame = CGRect(x: 0, y: 0, width: rowWidth, height: rowHeight)
        
        segmentedControl?.frame = CGRect(x: titleLabel.frame.maxX + padding, y: 0.5*padding, width: functionItemWidth, height: rowHeight-padding)
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
        case .switchCell(let model):
            titleLabel.text = model.title
            iconView.image = model.icon
            iconContainer.backgroundColor = model.iconBackgroundColor
            switchView.isOn = model.isOn
            switchView.alpha = 1
            OnSwitchChange = model.OnChange
            switchView.addTarget(self, action: #selector(OnSwitchChageValueChange), for: .valueChanged)
            self.accessoryType = .none
            self.selectionStyle = .none
            break
        case .navigationCell(let model):
            titleLabel.text = model.title
            iconView.image = model.icon
            iconContainer.backgroundColor = model.iconBackgroundColor
            previewLabel.text = model.SetPreview()
            previewLabel.alpha = 1
            SetPreview = model.SetPreview
            if model.iconBorderWidth != nil { iconContainer.layer.borderWidth = model.iconBorderWidth!; iconContainer.layer.borderColor = UIColor.systemGray.cgColor; }
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
            selectionImageView.image = UIImage(systemName: model.isSelected ? "checkmark" : "", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))
            selectionImageView.alpha = 1
        case .customViewCell(let model):
            customViewContainer.addSubview(model)
            customViewContainer.alpha = 1
            self.accessoryType = .none
            self.selectionStyle = .none
        case .segmentedControlCell(let model):
            titleLabel.text = model.title
            OnSegmentedControlChange = model.OnValueChange
            segmentedControl = UISegmentedControl(items: model.items)
            segmentedControl!.alpha = 1
            segmentedControl?.addTarget(self, action: #selector(OnSegmentedControlValueChange), for: .valueChanged)
            segmentedControl?.selectedSegmentIndex = model.selectedItem
            selectionStyle = .none
            self.contentView.addSubview(segmentedControl!)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconView.image = nil
        titleLabel.text = ""
        switchView.alpha = 0
        inputField.alpha = 0
        timePicker.alpha = 0
        previewLabel.alpha = 0
        selectionImageView.alpha = 0
        customViewContainer.alpha = 0
        segmentedControl?.alpha = 0
        self.selectionStyle = .default
        for subview in customViewContainer.subviews { subview.removeFromSuperview() }
    }
    
    var SetPreview: (()->String)!
    
    func ReloadPreview () {
        previewLabel.text = SetPreview()
    }
    
    var OnSwitchChange: ((_ sender: UISwitch) -> Void)!
    @objc func OnSwitchChageValueChange (sender: UISwitch) {
        OnSwitchChange(sender)
    }
    
    var OnSegmentedControlChange: ((_ sender: UISegmentedControl) -> Void)!
    @objc func OnSegmentedControlValueChange (sender: UISegmentedControl) {
        OnSegmentedControlChange(sender)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        DispatchQueue.main.async {
            textField.selectedTextRange = textField.textRange(from: textField.endOfDocument, to: textField.endOfDocument)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.isEmpty ?? true {
            textField.text = titleLabel.text == "First Name" ? App.settingsConfig.userFirstName : App.settingsConfig.userLastName
            return
        }
        
        if textField.text?.first == " " {
            textField.text?.removeFirst()
        }
        
        if titleLabel.text == "First Name" {
            App.settingsConfig.userFirstName = textField.text!
            if App.selectedTaskListIndex == 0 { App.instance.SelectTaskList(index: 0, closeMenu: false)}
            App.instance.sideMenuView.userPanel.ReloadName()
        } else {
            App.settingsConfig.userLastName = textField.text!
            if App.selectedTaskListIndex == 0 { App.instance.SelectTaskList(index: 0, closeMenu: false)}
            App.instance.sideMenuView.userPanel.ReloadName()
        }
    }
    
    func ReloadThemeColors() {
        UIView.animate(withDuration: 0.25) { [self] in
            switchView.onTintColor = ThemeManager.currentTheme.primaryElementColor(tasklistColor: .defaultColor)
            selectionImageView.tintColor = ThemeManager.currentTheme.primaryElementColor(tasklistColor: .defaultColor)
            self.backgroundColor = ThemeManager.currentTheme.interface == .Light ? .white : .systemGray6
        }
    }
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
