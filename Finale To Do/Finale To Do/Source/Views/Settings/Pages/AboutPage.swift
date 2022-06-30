//
//  AboutPage.swift
//  Finale To Do
//
//  Created by Grant Oganan on 6/30/22.
//

import Foundation
import UIKit

class SettingsAboutPage: SettingsPageViewController {
    override func GetSettings() -> [SettingsSection] {
        return [
            
            SettingsSection(options: [.customViewCell(model: SettingsAppLogoAndVersionView())], customHeight: SettingsAppLogoAndVersionView.height),
            
            SettingsSection(title: "More", options: [
                .navigationCell(model: SettingsNavigationOption(title: "Visit FinaleToDo.com", icon: UIImage(systemName: "globe"), iconBackgroundColor: .systemBlue, url: URL(string: "https://finaletodo.com"))),
                .navigationCell(model: SettingsNavigationOption(title: "Rate App", icon: UIImage(systemName: "star.fill"), iconBackgroundColor: .systemGreen, url: URL(string: "itms-apps:itunes.apple.com/us/app/apple-store/id1622931101?mt=8&action=write-review"))),
                .navigationCell(model: SettingsNavigationOption(title: "Finale: Daily Habit Tracker", icon: UIImage(named: "Finale Daily Habit Tracker Icon"), iconBorderWidth: 1, url: URL(string: "https://apps.apple.com/us/app/finale-daily-habit-tracker/id1546661013")))
            ]),
            
            SettingsSection(title: "Follow Us", options: [
                .navigationCell(model: SettingsNavigationOption(title: "Twitter", icon: UIImage(named: "TwitterIcon"), nextPage: nil, url: URL(string: "https://twitter.com/FinaleToDo"))),
                .navigationCell(model: SettingsNavigationOption(title: "Reddit", icon: UIImage(named: "RedditIcon"), nextPage: nil, url: URL(string: "https://www.reddit.com/r/FinaleToDo/")))
            ]),
            
            SettingsSection(title: "Help", options: [
                .navigationCell(model: SettingsNavigationOption(title: "Lead Developer", icon: UIImage(systemName: "message.fill"), iconBackgroundColor: .systemTeal, nextPage: nil, url: URL(string: "https://twitter.com/GrantOgany"))),
                .navigationCell(model: SettingsNavigationOption(title: "Contact Support", icon: UIImage(systemName: "envelope.fill"), iconBackgroundColor: .systemBlue, nextPage: nil, url: URL(string: "https://www.finaletodo.com/help")))
            ]),
            
            SettingsSection(title: "Legal", options: [
                .navigationCell(model: SettingsNavigationOption(title: "Privacy Policy", url: URL(string: "https://finaletodo.com/privacy-policy")))
            ]),
            
        ]
    }
    
    override var PageTitle: String {
        return "About"
    }
    
}
