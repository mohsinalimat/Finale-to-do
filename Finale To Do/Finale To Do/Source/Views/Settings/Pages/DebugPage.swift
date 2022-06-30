//
//  DebugPage.swift
//  Finale To Do
//
//  Created by Grant Oganan on 6/30/22.
//

import Foundation
import UIKit

class SettingsDebugPage: SettingsPageViewController {
    override var PageTitle: String {
        return "Debug"
    }
    
    override func GetSettings() -> [SettingsSection] {
        return [
        
            SettingsSection(options: [
                .navigationCell(model: SettingsNavigationOption(title: "Set level", OnTap: {
                    let alert = UIAlertController(title: "Set Level", message: "Enter new level", preferredStyle: .alert)
                    alert.addTextField { (textField) in
                        textField.keyboardType = .numbersAndPunctuation
                        textField.text = StatsManager.stats.level.description
                    }
                    alert.addAction(UIAlertAction(title: "Set", style: .default, handler: { [weak alert] (_) in
                        let textField = alert?.textFields![0]
                        StatsManager.stats.level = Int(textField!.text!) ?? StatsManager.stats.level
                        App.instance.sideMenuView.userPanel.ReloadPanel()
                    }))
                    self.present(alert, animated: true, completion: nil)
                }))
            ]),
            
            SettingsSection(options: [
                .navigationCell(model: SettingsNavigationOption(title: "Force check all badges", OnTap: {
                    for group in StatsManager.allBadgeGroups {
                        StatsManager.CheckUnlockedBadge(groupID: group.groupID)
                    }
                })),
                .navigationCell(model: SettingsNavigationOption(title: "Unlock all badges", OnTap: {
                    for group in StatsManager.allBadgeGroups {
                        StatsManager.UnlockBadge(badgeGroup: group, badgeIndex: group.numberOfBadges-1, earnPoints: false)
                    }
                })),
                .navigationCell(model: SettingsNavigationOption(title: "Lock all badges", OnTap: {
                    for (groupID, _) in StatsManager.stats.badges {
                        StatsManager.stats.badges[groupID] = -1
                    }
                })),
                .navigationCell(model: SettingsNavigationOption(title: "Unlock badge", OnTap: {
                    let alert = UIAlertController(title: "Set Badge", message: "Enter badge group ID and badge index to unlock", preferredStyle: .alert)
                    alert.addTextField { (textField) in
                        textField.keyboardType = .numbersAndPunctuation
                        textField.placeholder = "Badge group index"
                    }
                    alert.addTextField { (textField) in
                        textField.keyboardType = .numbersAndPunctuation
                        textField.placeholder = "Badge index"
                    }
                    alert.addAction(UIAlertAction(title: "Set", style: .default, handler: { [weak alert] (_) in
                        let badgeGroup = Int((alert?.textFields![0].text)!)!
                        let badgeIndex = Int((alert?.textFields![1].text)!)!
                        if badgeIndex == -1 {
                            StatsManager.stats.badges[badgeGroup] = badgeIndex
                        } else {
                            StatsManager.UnlockBadge(badgeGroup: StatsManager.getBadgeGroup(id: badgeGroup)!, badgeIndex: badgeIndex, earnPoints: false)
                        }
                        
                    }))
                    self.present(alert, animated: true, completion: nil)
                }))])
        ]
    }
}
