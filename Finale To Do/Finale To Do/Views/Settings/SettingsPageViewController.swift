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
//        tableView.register(SettingsTableCell.self, forCellReuseIdentifier: SettingsTableCell.identifier)
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
//        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableCell.identifier, for: indexPath) as! SettingsTableCell
        let cell = SettingsTableCell()
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
        let model = settingsSections[indexPath.section].options[indexPath.row]
        
        switch model {
        case .inputFieldCell(_):
            let cell = tableView.cellForRow(at: indexPath) as! SettingsTableCell
            cell.inputField!.becomeFirstResponder()
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
                x.selectionImageView!.image = UIImage(systemName: "")
            }
            let selectedCell = tableView.cellForRow(at: indexPath) as! SettingsTableCell
            selectedCell.selectionImageView!.image = UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))
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
            if let prevPage = navigationController?.topViewController as? SettingsPageViewController {
                if prevPage.indexPathToUpdate != nil {
                    let cell = prevPage.tableView.cellForRow(at: prevPage.indexPathToUpdate!) as! SettingsTableCell
                    cell.ReloadPreview()
                }
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
    
    var titleLabel: UILabel?
    var iconContainer: UIView?
    var iconView: UIImageView?
    var switchView: UISwitch?
    var inputField: UITextField?
    var previewLabel: UILabel?
    var selectionImageView: UIImageView?
    var segmentedControl: UISegmentedControl?
    var customViewContainer: UIView?
    
    func SetupTitleLabel() {
        titleLabel = UILabel()
        titleLabel!.numberOfLines = 1
        titleLabel!.textAlignment = .left
        titleLabel!.textColor = .label
        titleLabel!.font = .preferredFont(forTextStyle: .body)
        self.contentView.addSubview(titleLabel!)
    }
    func SetupIconContainer() {
        iconContainer = UIView()
        iconContainer!.layer.cornerRadius = 8
        iconContainer!.clipsToBounds = true
        self.contentView.addSubview(iconContainer!)
    }
    func SetupIconView() {
        iconView = UIImageView()
        iconView!.tintColor = .white
        iconView!.contentMode = .scaleAspectFit
        iconContainer!.addSubview(iconView!)
    }
    func SetupSwitchView() {
        switchView = UISwitch()
        switchView!.onTintColor = ThemeManager.currentTheme.primaryElementColor(tasklistColor: .defaultColor)
        self.contentView.addSubview(switchView!)
    }
    func SetupInputField() {
        inputField = UITextField()
        inputField!.textColor = .label
        inputField!.textColor = .systemGray
        inputField!.textAlignment = .right
        self.contentView.addSubview(inputField!)
    }
    func SetupPreviewLabel() {
        previewLabel = UILabel()
        previewLabel!.numberOfLines = 1
        previewLabel!.textAlignment = .right
        previewLabel!.textColor = .systemGray
        self.contentView.addSubview(previewLabel!)
    }
    func SetupSelectionImageView() {
        selectionImageView = UIImageView()
        selectionImageView!.tintColor = ThemeManager.currentTheme.primaryElementColor(tasklistColor: .defaultColor)
        selectionImageView!.contentMode = .scaleAspectFit
        self.contentView.addSubview(selectionImageView!)
    }
    
    func SetupCustomViewContainer() {
        customViewContainer = UIView()
        self.contentView.addSubview(customViewContainer!)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = ThemeManager.currentTheme.interface == .Light ? .white : .systemGray6
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let rowWidth = self.contentView.frame.width
        let rowHeight = self.contentView.frame.height
        
        let iconContainerSize = iconView == nil ? 0 : contentView.frame.height-padding*0.9
        if iconContainer != nil && iconView != nil {
            iconContainer?.frame = CGRect(x: padding, y: 0.5*(rowHeight-iconContainerSize), width: iconContainerSize, height: iconContainerSize)
            iconView?.frame.size = CGSize(width: iconContainer!.backgroundColor == nil ? iconContainerSize : iconContainerSize*0.7, height: iconContainer!.backgroundColor == nil ? iconContainerSize : iconContainerSize*0.7)
            iconView?.frame.origin = CGPoint(x: 0.5*(iconContainerSize-iconView!.frame.width), y: 0.5*(iconContainerSize-iconView!.frame.height))
        }

        let titleWidth = titleLabel == nil ? 0 : titleLabel!.text!.size(withAttributes:[.font: titleLabel!.font]).width
        titleLabel?.frame = CGRect(x: iconContainerSize == 0 ? padding : iconContainer!.frame.maxX + padding, y: 0, width: min(titleWidth, rowWidth-padding-iconContainerSize), height: rowHeight)
        
        if titleLabel != nil {
            let functionItemWidth = rowWidth-titleLabel!.frame.maxX-padding*(self.accessoryType == .none ? 2 : 1.3)
            switchView?.frame.origin = CGPoint(x: rowWidth-switchView!.frame.width-padding, y: 0.5*(rowHeight-switchView!.frame.height))
            inputField?.frame = CGRect(x: titleLabel!.frame.maxX + padding, y: 0, width: functionItemWidth, height: rowHeight)
            inputField?.delegate = self
            previewLabel?.frame = CGRect(x: titleLabel!.frame.maxX + padding, y: 0, width: functionItemWidth, height: rowHeight)
            let selectionImageSize = contentView.frame.height-padding*1.5
            selectionImageView?.frame = CGRect(x: rowWidth-selectionImageSize-padding, y: 0.5*(rowHeight-selectionImageSize), width: selectionImageSize, height: selectionImageSize)
            segmentedControl?.frame = CGRect(x: titleLabel!.frame.maxX + padding, y: 0.5*padding, width: functionItemWidth, height: rowHeight-padding)
        }
        
        customViewContainer?.frame = CGRect(x: 0, y: 0, width: rowWidth, height: rowHeight)
    }
    
    func Setup(settingsOption: SettingsOptionType) {
        switch settingsOption {
        case .inputFieldCell(let model):
            SetupTitleLabel()
            SetupInputField()
            titleLabel!.text = model.title
            inputField!.text = model.inputFieldText
            self.accessoryType = .none
            break
        case .switchCell(let model):
            SetupTitleLabel()
            SetupSwitchView()
            titleLabel!.text = model.title
            switchView!.isOn = model.isOn
            OnSwitchChange = model.OnChange
            switchView!.addTarget(self, action: #selector(OnSwitchChageValueChange), for: .valueChanged)
            self.accessoryType = .none
            self.selectionStyle = .none
            break
        case .navigationCell(let model):
            SetupTitleLabel()
            if model.icon != nil {
                SetupIconContainer()
                SetupIconView()
                iconView!.image = model.icon
                iconContainer!.backgroundColor = model.iconBackgroundColor
            }
            SetupPreviewLabel()
            titleLabel!.text = model.title
            previewLabel!.text = model.SetPreview()
            SetPreview = model.SetPreview
            if model.iconBorderWidth != nil { iconContainer!.layer.borderWidth = model.iconBorderWidth!; iconContainer!.layer.borderColor = UIColor.systemGray.cgColor; }
            self.accessoryType = .disclosureIndicator
            break
        case .selectionCell(let model):
            SetupTitleLabel()
            SetupSelectionImageView()
            titleLabel!.text = model.title
            selectionImageView!.image = UIImage(systemName: model.isSelected ? "checkmark" : "", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))
        case .customViewCell(let model):
            SetupCustomViewContainer()
            customViewContainer!.addSubview(model)
            self.accessoryType = .none
            self.selectionStyle = .none
        case .segmentedControlCell(let model):
            SetupTitleLabel()
            titleLabel!.text = model.title
            OnSegmentedControlChange = model.OnValueChange
            segmentedControl = UISegmentedControl(items: model.items)
            segmentedControl?.addTarget(self, action: #selector(OnSegmentedControlValueChange), for: .valueChanged)
            segmentedControl?.selectedSegmentIndex = model.selectedItem
            selectionStyle = .none
            self.contentView.addSubview(segmentedControl!)
        case .staticCell(let model):
            SetupTitleLabel()
            if model.icon != nil {
                SetupIconContainer()
                SetupIconView()
                iconView!.image = model.icon
                iconContainer!.backgroundColor = model.iconBackgroundColor
                
            }
            SetupPreviewLabel()
            titleLabel!.text = model.title
            previewLabel!.text = model.SetPreview()
            SetPreview = model.SetPreview
            selectionStyle = .none
            self.accessoryType = .none
        }
    }
    
    var SetPreview: (()->String)!
    
    func ReloadPreview () {
        previewLabel?.text = SetPreview()
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
        if textField.text?.first == " " {
            textField.text?.removeFirst()
        }
        
        if titleLabel!.text == "First Name" {
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
            switchView?.onTintColor = ThemeManager.currentTheme.primaryElementColor(tasklistColor: .defaultColor)
            selectionImageView?.tintColor = ThemeManager.currentTheme.primaryElementColor(tasklistColor: .defaultColor)
            self.backgroundColor = ThemeManager.currentTheme.interface == .Light ? .white : .systemGray6
        }
    }
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
