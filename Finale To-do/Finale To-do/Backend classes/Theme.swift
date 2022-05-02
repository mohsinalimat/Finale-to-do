//
//  ThemeColors.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/18/22.
//

import Foundation
import UIKit

class AppColors {

    
//MARK: Slider Colors
    
    static func sliderHighPriorityBackgroundColor (taskListColor: UIColor) -> UIColor {
        return taskListColor.lerp(second: ThemeManager.currentTheme.interface == .Light ? .white : .black, percentage: 0.75)
    }
    
    static func sliderCompletedBackgroundColor (taskListColor: UIColor) -> UIColor  {
        return taskListColor.lerp(second: ThemeManager.currentTheme.interface == .Light ? .white : .black, percentage: 0.85)
    }

    static var sliderOverdueLabelColor: UIColor {
        return UIColor.red.lerp(second: .black, percentage: 0.2)
    }
    
//MARK: Element colors
    
    static var actionButtonDestructiveColor: UIColor {
        return .red.lerp(second: .black, percentage: 0.1)
    }
    
}

class AppConfiguration {
    
    static var slideoverCornerRadius: CGFloat = 20.0
    
    static func AddStandardShadow(view: UIView) {
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 7
        view.layer.shadowOpacity = 0.5
    }
    
}

struct AppTheme: Equatable {
    let name: String
    let interface: InterfaceMode
    
    let primaryColor: UIColor
    var usesDynamicColors: Bool = false
    
    //Task list colors
    var tasklistBackgroundColor: UIColor { return overrideTasklistBackgroundColor ?? (self.interface == .Light ? .white : .black) }
    func tasklistHeaderColor(tasklistColor: UIColor) -> UIColor {
        if usesDynamicColors { return self.interface == .Light ? tasklistColor : tasklistColor.dark}
        return overrideTasklistHeaderColor ?? (self.interface == .Light ? self.primaryColor : self.primaryColor.dark)
    }
    func tasklistHeaderGradientSecondaryColor(tasklistColor: UIColor) -> UIColor {
        if usesDynamicColors { return self.interface == .Light ? tasklistColor.light : tasklistColor }
        return overrideTasklistHeaderGradientSecondaryColor ?? (self.interface == .Light ? self.primaryColor.light : self.primaryColor)
    }
    
    //Sidemenu colors
    var sidemenuBackgroundColor: UIColor { return overrideSidemenuBackgroundColor ?? (self.interface == .Light ? self.primaryColor.dark2 : self.primaryColor.dark3) }
    var sidemenuSelectionColor: UIColor { return overrideSidemenuSelectionColor ?? (self.primaryColor.dark) }
    
    //Element colors
    func primaryElementColor(tasklistColor: UIColor) -> UIColor {
        if usesDynamicColors { return tasklistColor }
        return overridePrimaryElementColor ?? (self.primaryColor)
    }
    
    //Background colors
    var tintedBackgroundColor: UIColor { return overrideTintedBackgroundColor ?? (self.interface == .Light ? self.primaryColor.light : self.primaryColor.dark3) }
    
    //Override Task list colors
    var overrideTasklistBackgroundColor: UIColor? = nil
    var overrideTasklistHeaderColor: UIColor? = nil
    var overrideTasklistHeaderGradientSecondaryColor: UIColor? = nil
    
    //Override Sidemenu colors
    var overrideSidemenuBackgroundColor: UIColor? = nil
    var overrideSidemenuSelectionColor: UIColor? = nil
    
    //Override Element colors
    var overridePrimaryElementColor: UIColor? = nil
    
    //Override Background colors
    var overrideTintedBackgroundColor: UIColor? = nil
    
    static func == (lhs: AppTheme, rhs: AppTheme) -> Bool {
        return lhs.name == rhs.name
    }
}

class ThemeManager {
    
    static var currentTheme: AppTheme!
    
    static let lightThemes: [AppTheme] = [
        
        AppTheme(name: "Dynamic", interface: .Light, primaryColor: .defaultColor, usesDynamicColors: true),
        
        AppTheme(name: "Violet", interface: .Light, primaryColor: UIColor(hex: "8453AC"), overrideTasklistHeaderColor: .defaultColor.lerp(second: .white, percentage: 0.1), overrideTasklistHeaderGradientSecondaryColor: UIColor(hex: "FD5E53")),
        
        AppTheme(name: "Aqua", interface: .Light, primaryColor: UIColor(hex: "22A0ED"), overrideTasklistHeaderColor: .defaultColor.lerp(second: .white, percentage: 0.1), overrideTasklistHeaderGradientSecondaryColor: UIColor(hex: "47FCF9")),
    
    ]
    
    static let darkThemes: [AppTheme] = [
        
        AppTheme(name: "Dynamic", interface: .Dark, primaryColor: .defaultColor, usesDynamicColors: true),
        
        AppTheme(name: "Violet", interface: .Dark, primaryColor: UIColor(hex: "664C7C"), overrideTasklistHeaderColor: .defaultColor.dark, overrideTasklistHeaderGradientSecondaryColor: UIColor(hex: "FD5E53")),
        
        AppTheme(name: "Aqua", interface: .Dark, primaryColor: UIColor(hex: "227DB5"), overrideTasklistHeaderColor: .defaultColor.lerp(second: .black, percentage: 0.1), overrideTasklistHeaderGradientSecondaryColor: UIColor(hex: "47FCF9")),
        
        AppTheme(name: "True Black", interface: .Dark, primaryColor: UIColor(hex: "262626"), overrideTasklistHeaderColor: UIColor(hex: "000000"), overrideTasklistHeaderGradientSecondaryColor: UIColor(hex: "000000"), overridePrimaryElementColor: UIColor(hex: "262626").dark2)
    
    ]
    
    static func SetTheme (theme: AppTheme) {
        if theme.interface == .Light {
            App.settingsConfig.selectedLightThemeIndex = ThemeManager.lightThemes.firstIndex(of: theme)!
        } else if theme.interface == .Dark {
            App.settingsConfig.selectedDarkThemeIndex = ThemeManager.darkThemes.firstIndex(of: theme)!
        }
        App.instance.SaveSettings()
        ThemeManager.currentTheme = App.settingsConfig.GetCurrentTheme()
        App.instance.SetSubviewColors(of: App.instance.view)
    }
    
}
