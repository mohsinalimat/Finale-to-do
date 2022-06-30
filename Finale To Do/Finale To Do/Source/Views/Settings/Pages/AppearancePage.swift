//
//  AppearancePage.swift
//  Finale To Do
//
//  Created by Grant Oganan on 6/30/22.
//

import Foundation
import UIKit

class SettingsAppearancePage: SettingsPageViewController {
    override func GetSettings() -> [SettingsSection] {
        return [
            
            SettingsSection(options: [.segmentedControlCell(model: SettingsSegmentedControlOption(title: "Interface", items: [InterfaceMode(rawValue: 0)!.str, InterfaceMode(rawValue: 1)!.str, InterfaceMode(rawValue: 2)!.str], selectedItem: App.settingsConfig.interface.rawValue) { sender in
                
                self.SwitchInterface(mode: InterfaceMode(rawValue: sender.selectedSegmentIndex)!)
                
            })]),
            
            SettingsSection(title: "Light Theme", options: [.customViewCell(model: SettingsThemeView(type: .Light))], customHeight: SettingsThemeView.height),
            SettingsSection(title: "Dark Theme", options: [.customViewCell(model: SettingsThemeView(type: .Dark))], customHeight: SettingsThemeView.height),
            
            SettingsSection(title: "App Icon", options: [.customViewCell(model: SettingsAppIconView())], customHeight: SettingsAppIconView.height)
            
        ]
    }
    
    func SwitchInterface(mode: InterfaceMode) {
        App.settingsConfig.interface = mode
        
        App.instance.overrideUserInterfaceStyle = mode == .System ? .unspecified : mode == .Light ? .light : .dark
        navigationController?.overrideUserInterfaceStyle = App.instance.overrideUserInterfaceStyle
        
        let navController = navigationController as? SettingsNavigationController
        navController?.SetAllViewControllerColors()
        
        AnalyticsHelper.LogChangedInterface()
    }
    
    override var PageTitle: String {
        return "Appearance"
    }
    
}
