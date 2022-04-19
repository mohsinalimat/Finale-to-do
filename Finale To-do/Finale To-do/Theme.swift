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
    
    var tintedBackgroundColor: UIColor {
        return currentTheme == .Light ? .defaultColor.light4 : UIColor.defaultColor.dark3
    }
   
    
//MARK: Sidemenu colors
    
    var sidemenuBackgroundColor: UIColor {
        return currentTheme == .Light ? .defaultColor.dark2 : .defaultColor.dark3
    }
    
    var sidemenuSelectedItemColor: UIColor {
        return .defaultColor.dark
    }
    
//MARK: Slider Colors
    
    func getCompletedSliderColor (taskListColor: UIColor) -> UIColor  {
        return taskListColor.withAlphaComponent(0.15)
    }

    
    
    
    
    var currentTheme: Theme {
        get {
            return UITraitCollection.current.userInterfaceStyle == .light ? .Light : .Dark
        }
    }
}

enum Theme {
    case Light
    case Dark
}
