//
//  AnalyticsHelper.swift
//  Finale To Do
//
//  Created by Grant Oganan on 5/14/22.
//

import Foundation
import FirebaseAnalytics

class AnalyticsHelper {
    
//MARK: Task list
    
    static func LogTaskListCreated(taskList: TaskList) {
        Analytics.logEvent("tasklist_created", parameters:
                            ["tasklist_icon" : taskList.systemIcon,
                             "tasklist_color" : taskList.primaryColor.hexStringFromColor])
    }
    
    static func LogTaskListEdited(taskList: TaskList) {
        Analytics.logEvent("tasklist_edited", parameters:
                            ["tasklist_icon" : taskList.systemIcon,
                             "tasklist_color" : taskList.primaryColor.hexStringFromColor])
    }
    
//MARK: Task
    static func LogTaskCreated() {
        Analytics.logEvent("task_created", parameters: nil)
    }
    static func LogTaskAssignedDate() {
        Analytics.logEvent("task_assigned_date", parameters: nil)
    }
    static func LogTaskAddedNotification(notifCount: Int) {
        Analytics.logEvent("task_notification_added", parameters: ["notification_count" : notifCount])
    }
    static func LogTaskSetHighPriority() {
        Analytics.logEvent("task_set_high_priority", parameters: nil)
    }
    static func LogTaskCompleted() {
        Analytics.logEvent("task_completed", parameters: nil)
    }
    
//MARK: General
    static func LogGeneralStats() {
        Analytics.logEvent("app_in_background", parameters:
                            ["user_level" : StatsManager.stats.level,
                             "user_total_badges" : StatsManager.stats.numberOfUnlockedBadges,
                             "total_completed_tasks" : StatsManager.stats.totalCompletedTasks,
                             "total_days_active" : StatsManager.stats.totalDaysActive,
                             "total_user_lists" : App.userTaskLists.count,
                             "days_ago_installed_app" : StatsManager.stats.daysAgoJoined])
    }
    
    static func LogWelcomeScreenCompleted(tutorialAccepted: Bool) {
        Analytics.logEvent("welcome_screen_completed", parameters:
                            ["username" : App.settingsConfig.userFullName == " " ? "empty" : "added",
                             "notifications" : App.settingsConfig.isNotificationsAllowed ? "allowed" : "skipped",
                             "icloud_sync" : App.settingsConfig.isICloudSyncOn ? "enabled" : "skipped",
                             "tutorial" : tutorialAccepted ? "accepted" : "declined",
        ])
    }
    
    static func RecordUserProperties() {
        Analytics.setUserProperty(GetUserLevelCategory(level: StatsManager.stats.level), forName: "level_range")
        Analytics.setUserProperty(GetUserTotalDaysActiveCategory(totalDaysActive: StatsManager.stats.totalDaysActive), forName: "total_days_active_range")
    }
    
    static func GetUserLevelCategory(level: Int) -> String {
        if level <= 10 {
            return "1 - 10"
        } else if level <= 20 {
            return "11 - 20"
        } else if level <= 30 {
            return "21 - 30"
        } else if level <= 40 {
            return "31 - 40"
        } else if level <= 50 {
            return "41 - 50"
        } else if level <= 60 {
            return "51 - 60"
        } else if level <= 70 {
            return "61 - 70"
        } else if level <= 80 {
            return "71 - 80"
        } else if level <= 90 {
            return "81 - 90"
        } else if level <= 100 {
            return "91 - 100"
        } else {
            return "100+"
        }
    }
    static func GetUserTotalDaysActiveCategory(totalDaysActive: Int) -> String {
        if totalDaysActive <= 30 {
            return "1 - 30"
        } else if totalDaysActive <= 60 {
            return "31 - 60"
        } else if totalDaysActive <= 90 {
            return "61 - 90"
        } else if totalDaysActive <= 120 {
            return "91 - 120"
        } else if totalDaysActive <= 150 {
            return "121 - 150"
        } else if totalDaysActive <= 180 {
            return "151 - 180"
        } else if totalDaysActive <= 210 {
            return "181 - 210"
        } else if totalDaysActive <= 240 {
            return "211 - 240"
        } else if totalDaysActive <= 270 {
            return "241 - 270"
        } else if totalDaysActive <= 300 {
            return "271 - 300"
        } else if totalDaysActive <= 330 {
            return "301 - 330"
        } else if totalDaysActive <= 360 {
            return "331 - 360"
        } else {
            return "360+"
        }
    }
    
    static func LogPressedShareButton() {
        Analytics.logEvent("pressed_share_progress", parameters: nil)
    }
    
    
//MARK: Settings
    
    static func LogNotificationsToggled() {
        Analytics.logEvent("settings_notifications_toggle", parameters:
                            ["notifications" : App.settingsConfig.isNotificationsAllowed ? "allowed" : "declined"])
    }
    
    static func LogICloudSyncToggled() {
        Analytics.logEvent("settings_icloud_toggle", parameters:
                            ["icloud_sync" : App.settingsConfig.isICloudSyncOn ? "allowed" : "declined"])
    }
    
    static func LogAppBadgeNumberSelection(type: AppBadgeNumberType) {
        Analytics.logEvent("settings_app_badge_select", parameters:
                            ["app_badge_type" : type.str])
    }
    
    static func LogChangedDefaultList() {
        Analytics.logEvent("settings_default_list_changed", parameters: ["is_main_list_default" : App.settingsConfig.defaultListID == App.mainTaskList.id ? "true" : "false"])
    }
    
    static func LogSelectedTheme (theme: AppTheme) {
        Analytics.logEvent("settings_theme_selected", parameters: ["theme" : "\(theme.name) \(theme.interface.str)"])
    }
    
    static func LogChangedInterface () {
        Analytics.logEvent("settings_interface_changed", parameters: ["interface" : App.settingsConfig.interface.str])
    }
    
    static func LogChangedAppIcon () {
        Analytics.logEvent("settings_app_icon_changed", parameters: ["app_icon" : App.settingsConfig.selectedIcon.name!])
    }
    
    static func LogChangedName() {
        Analytics.logEvent("settings_name_changed", parameters:
                            ["username" : App.settingsConfig.userFullName == " " ? "empty" : "added"])
    }
}
