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
        
        overrideUserInterfaceStyle = App.settingsConfig.interface == .System ? .unspecified : App.settingsConfig.interface == .Light ? .light : .dark
        self.navigationBar.tintColor = ThemeManager.currentTheme.primaryElementColor()
        
        self.setViewControllers([SettingsMainPage()], animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        SaveManager.instance.SaveSettings()
    }
    
    func SetAllViewControllerColors() {
        self.navigationBar.tintColor = ThemeManager.currentTheme.primaryElementColor()
        for viewController in self.viewControllers {
            if let dynamicTheme = viewController as? UIDynamicTheme { dynamicTheme.ReloadThemeColors() }
            for subview in viewController.view.subviews {
                SetSubviewColors(of: subview)
            }
        }
    }
    
    func SetSubviewColors(of view: UIView) {
        if let dynamicThemeView = view as? UIDynamicTheme  {
            dynamicThemeView.ReloadThemeColors()
        }
        
        for subview in view.subviews {
            SetSubviewColors(of: subview)
        }
    }
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
//MARK: Main Page
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
            SettingsSection(title: "Personal", options: [
                .navigationCell(model: SettingsNavigationOption(title: "Personal", icon: UIImage(systemName: "person.text.rectangle.fill"), iconBackgroundColor: .systemGreen, nextPage: SettingsPersonalPage(), SetPreview: {return App.settingsConfig.userFullName;} ))
            ]),
            
            SettingsSection(title: "Preferences", footer: "", options: [
                .navigationCell(model: SettingsNavigationOption(title: "Lists", icon: UIImage(systemName: "folder.fill"), iconBackgroundColor: .systemBlue, nextPage: SettingsListsPage())),
                .navigationCell(model: SettingsNavigationOption(title: "Notifications", icon: UIImage(systemName: "bell.badge.fill"), iconBackgroundColor: .systemRed, nextPage: SettingsNotificationsPage())),
                .navigationCell(model: SettingsNavigationOption(title: "Widgets", icon: UIImage(systemName: "list.bullet.rectangle.fill"), iconBackgroundColor: .systemIndigo, nextPage: SettingsWidgetPage())),
                .navigationCell(model: SettingsNavigationOption(title: "Appearance", icon: UIImage(systemName: "circle.hexagongrid.circle"), iconBackgroundColor: .systemPurple, nextPage: SettingsAppearancePage()))
            ]),
            
            SettingsSection(title: "Integrations", options: [
                .navigationCell(model: SettingsNavigationOption(title: "Import", icon: UIImage(systemName: "square.and.arrow.down.fill"), iconBackgroundColor: .systemBrown, nextPage: SettingsIntegrationsPage())),
            ]),

            SettingsSection(title: "More", options: [
                .navigationCell(model: SettingsNavigationOption(title: "Guide", icon: UIImage(systemName: "doc.text.image.fill"), iconBackgroundColor: .systemOrange, nextPage: SettingsGuidePage())),
                .navigationCell(model: SettingsNavigationOption(title: "About", icon: UIImage(systemName: "bookmark.fill"), iconBackgroundColor: .systemTeal, nextPage: SettingsAboutPage(), SetPreview: {return self.appVersion })),
                .navigationCell(model: SettingsNavigationOption(title: "Share", icon: UIImage(systemName: "square.and.arrow.up.fill"), iconBackgroundColor: .systemYellow, OnTap: {
                    let items = [URL(string: "https://apps.apple.com/us/app/finale-to-do/id1622931101")]
                    let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                    self.present(ac, animated: true)
                }))
            ])
        ]
    }
    
    override var PageTitle: String {
        return "Settings"
    }
    
    var appVersion: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return "v\(version)"
        }
        return ""
    }
    
}


//MARK: Enums & Structs
enum SettingsOptionType {
    case inputFieldCell(model: SettingsInputFieldOption)
    case switchCell(model: SettingsSwitchOption)
    case selectionCell(model: SettingsSelectionOption)
    case navigationCell(model: SettingsNavigationOption)
    case segmentedControlCell(model: SettingsSegmentedControlOption)
    case staticCell(model: SettingsStaticOption)
    
    case customViewCell(model: UIView)
}

struct SettingsInputFieldOption {
    let title: String
    var inputFieldText: String
}

struct SettingsSwitchOption {
    let title: String
    var isOn: Bool
    var OnChange: ( (_ sender: UISwitch) -> Void )
    
    init (title: String, isOn: Bool, OnChange: @escaping ( (_ sender: UISwitch)->Void )) {
        self.title = title
        self.isOn = isOn
        self.OnChange = OnChange
    }
}

struct SettingsSelectionOption {
    let title: String
    var selectionID: Int
    var isSelected: Bool
    let OnSelect: ( ()->Void )
    
    init (title: String, selectionID: Int, isSelected: Bool, OnSelect: @escaping ( ()->Void )) {
        self.title = title
        self.selectionID = selectionID
        self.isSelected = isSelected
        self.OnSelect = OnSelect
    }
}

struct SettingsNavigationOption {
    let title: String
    var icon: UIImage? = nil
    var iconBackgroundColor: UIColor? = nil
    var iconBorderWidth: CGFloat? = nil
    var nextPage: UIViewController? = nil
    var url: URL? = nil
    var OnTap: (()->Void)?
    var SetPreview: (() -> String) = { return "" }
}

struct SettingsSegmentedControlOption {
    let title: String
    let items: [String]
    var selectedItem: Int
    let OnValueChange: ((_ sender: UISegmentedControl)->Void)
    
    init (title: String, items: [String], selectedItem: Int, OnValueChange: @escaping ((_ sender: UISegmentedControl)->Void)) {
        self.title = title
        self.items = items
        self.selectedItem = selectedItem
        self.OnValueChange = OnValueChange
    }
}

struct SettingsStaticOption {
    let title: String
    var icon: UIImage? = nil
    var iconBackgroundColor: UIColor? = nil
    var SetPreview: (() -> String) = { return "" }
}

struct SettingsSection {
    var title: String? = nil
    var footer: String? = nil
    var options: [SettingsOptionType]
    var customHeight: CGFloat? = nil
}
