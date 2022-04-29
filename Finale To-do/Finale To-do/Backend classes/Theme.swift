//
//  ThemeColors.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/18/22.
//

import Foundation
import UIKit

class AppColors {
    
//MARK: Overall colors
    
    static var tintedBackgroundColor: UIColor {
        return AppColors.currentTheme == .Light ? UIColor.systemGray4: UIColor.defaultColor.dark3
    }
   
    
//MARK: Sidemenu colors
    
    static var sidemenuBackgroundColor: UIColor {
        return AppColors.currentTheme == .Light ? .defaultColor.dark2 : .defaultColor.dark3
    }
    
    static var sidemenuSelectedItemColor: UIColor {
        return .defaultColor.dark
    }
    
//MARK: Tasklist colors
    
    static func tasklistHeaderColor (taskListColor: UIColor) -> UIColor {
        return AppColors.currentTheme == .Light ? taskListColor : taskListColor.dark
    }
    
    static func tasklistHeaderGradientSecondaryColor (taskListColor: UIColor) -> UIColor {
        return AppColors.currentTheme == .Light ? taskListColor.light : taskListColor
    }
    
    static func tasklistPlaceholderPrimaryColor (color: UIColor) -> UIColor {
        return color
    }
    
    static func tasklistPlaceholderSecondaryColor (color: UIColor) -> UIColor {
        return AppColors.currentTheme == .Light ? color.light : color.dark
    }
    
//MARK: Slider Colors
    
    static func sliderMainColor (taskListColor: UIColor) -> UIColor {
        return taskListColor
    }
    
    static func sliderMainHandleColor (taskListColor: UIColor) -> UIColor {
        return taskListColor.dark
    }
    
    static func sliderHighPriorityBackgroundColor (taskListColor: UIColor) -> UIColor {
        return taskListColor.lerp(second: AppColors.currentTheme == .Light ? .white : .black, percentage: 0.75)
    }
    
    static var sliderIncompletedBackgroundColor: UIColor {
        return UIColor.systemGray6
    }
    
    static func sliderCompletedBackgroundColor (taskListColor: UIColor) -> UIColor  {
        return taskListColor.lerp(second: AppColors.currentTheme == .Light ? .white : .black, percentage: 0.85)
    }

    static var sliderOverdueLabelColor: UIColor {
        return UIColor.red.lerp(second: .black, percentage: 0.2)
    }
    
//MARK: Element colors
    
    static var actionButtonPrimaryColor: UIColor {
        return .defaultColor
    }
    
    static var actionButtonDestructiveColor: UIColor {
        return .red.lerp(second: .black, percentage: 0.1)
    }
    
    static func actionButtonTaskListColor (taskListColor: UIColor) -> UIColor {
        return taskListColor
    }
    
//MARK: Misc
    
    static var currentTheme: Theme {
        get {
            return UITraitCollection.current.userInterfaceStyle == .light ? .Light : .Dark
        }
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

enum Theme {
    case Light
    case Dark
}
