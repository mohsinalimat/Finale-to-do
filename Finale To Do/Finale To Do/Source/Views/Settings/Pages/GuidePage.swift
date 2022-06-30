//
//  GuidePage.swift
//  Finale To Do
//
//  Created by Grant Oganan on 6/30/22.
//

import Foundation
import UIKit

class SettingsGuidePage: SettingsPageViewController {
    override func GetSettings() -> [SettingsSection] {
        return [
        
            SettingsSection(title: "Tasks", options: [
                .navigationCell(model: SettingsNavigationOption(title: "Create", nextPage: GuidePageViewController(
                    titleText: "Create Task",
                    descriptionText: "Tap the + button to create a new task. New tasks will be added to the list that is currently open."))),
                .navigationCell(model: SettingsNavigationOption(title: "Edit", nextPage: GuidePageViewController(
                    titleText: "Edit Task",
                    descriptionText: "Double tap on the task to quickly change its name and date. Tap anowhere on the screen to stop editing the task."))),
                .navigationCell(model: SettingsNavigationOption(title: "Change details", nextPage: GuidePageViewController(
                    titleText: "Change Task Details",
                    descriptionText: "Long press on the task to peak its details. Tap inside to expand the view and edit the task."))),
                .navigationCell(model: SettingsNavigationOption(title: "Task Priority", nextPage: GuidePageViewController(
                    titleText: "Change Task Priority",
                    descriptionText: "Tasks that contain an exclamation mark in their title are considered \"high priority\". Alternatively, you can set priority from the detailed task view."))),
                .navigationCell(model: SettingsNavigationOption(title: "Complete", nextPage: GuidePageViewController(
                    titleText: "Complete Task",
                    descriptionText: "Tap on the colored handle to complete the task. Alternatively, you can slide the handle all the way to the right."))),
                .navigationCell(model: SettingsNavigationOption(title: "Reorder", nextPage: GuidePageViewController(
                    titleText: "Reorder Tasks",
                    descriptionText: "Drag and drop tasks to reorder them within the list. The 'Overview' page will respect each list's order."))),
            ]),
            
            SettingsSection(title: "Lists", options: [
                .navigationCell(model: SettingsNavigationOption(title: "Create", nextPage: GuidePageViewController(
                    titleText: "Create List",
                    descriptionText: "Tap the '+ Create List' button to create a new list. You can change the list's style by tapping on its icon."))),
                .navigationCell(model: SettingsNavigationOption(title: "Edit", nextPage: GuidePageViewController(
                    titleText: "Edit List",
                    descriptionText: "Long press on the list and tap 'Edit' to change the list's name a style."))),
                .navigationCell(model: SettingsNavigationOption(title: "Reorder", nextPage: GuidePageViewController(
                    titleText: "Reorder Lists",
                    descriptionText: "Drag and drop lists to reorder them within the side menu."))),
                .navigationCell(model: SettingsNavigationOption(title: "Sort Tasks", nextPage: GuidePageViewController(
                    titleText: "Sort Tasks",
                    descriptionText: "Tap the 'Sort' button in the top right corner to select sorting preference for the specific list."))),
            ]),
            
            SettingsSection(title: "Personal", options: [
                .navigationCell(model: SettingsNavigationOption(title: "Level", nextPage: GuidePageViewController(
                    titleText: "Level",
                    descriptionText: "By completing tasks you gain points that are used to increase your level. You get more points for tasks completed on time, and less points for overdue tasks. Reaching certain levels will grant you rewards, so don't forget to check in on your profile page every once in a while.\n\nYou can earn up to \(StatsManager.dailyPointsCap) points per day."))),
                .navigationCell(model: SettingsNavigationOption(title: "Badges", nextPage: GuidePageViewController(
                    titleText: "Badges",
                    descriptionText: "You can recieve honor badges when reaching certain milestones within Finale. You can check each badge progress and your collection on your profile page.")))
            ])
        
        ]
    }
    
    override var PageTitle: String {
        return "Guide"
    }
}
