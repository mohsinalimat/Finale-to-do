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
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: viewWidth, height: rowHeight*30), style: .insetGrouped)
        tableView.rowHeight = rowHeight
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SettingsTableCell.self, forCellReuseIdentifier: SettingsTableCell.identifier)
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TapOutside)))
        
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
        return  settingsSections[section].title
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return  settingsSections[section].footer
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
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            let prevPage = navigationController?.topViewController as! SettingsPageViewController
            prevPage.ReloadSettings()
            prevPage.tableView.reloadData()
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
