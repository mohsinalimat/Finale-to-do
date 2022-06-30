//
//  WidgetsPage.swift
//  Finale To Do
//
//  Created by Grant Oganan on 6/30/22.
//

import Foundation
import UIKit

class SettingsWidgetPage: SettingsPageViewController {
    
    override func GetSettings() -> [SettingsSection] {
        return [
        
            SettingsSection(options: [.customViewCell(model: SettingsWidgetListsView())], customHeight: SettingsWidgetListsView.height),
        
        ]
    }
    
    override var PageTitle: String {
        return "Widgets"
    }
    
}
