//
//  StatsManager.swift
//  Finale To-do
//
//  Created by Grant Oganan on 5/4/22.
//

import Foundation
import UIKit
import StoreKit


class StatsManager {
    
    static var stats = StatsConfig()
    
    static let pointsPerTask = 10
    static let dailyPointsCap = 500
    
    static func getBadgeGroup(id: Int) -> AchievementBadgeGroup? {
        for group in allBadgeGroups { if group.groupID == id { return group }}
        
        return nil
    }
    
    static func getPointsNeededLevelUp(currentLevel: Int) -> Int {
        let beg = 5
        let coef = 1
        return ((currentLevel-1)*coef + beg) * pointsPerTask
    }
    static var pointsLeftToNextLevel: Int {
        return getPointsNeededLevelUp(currentLevel: StatsManager.stats.level) - stats.points
    }
    static var levelProgress: CGFloat {
        return Double(stats.points) / Double(getPointsNeededLevelUp(currentLevel: StatsManager.stats.level))
    }
    
    static func EarnPoints(points: Int, ignoreDailyLimit: Bool = false) {
        var earnedPoints = points
        if !ignoreDailyLimit {
            let delta = dailyPointsCap - stats.pointsEarnedToday
            if delta <= 0 { return }
            else if delta < earnedPoints { earnedPoints = delta }
        }
        
        stats.pointsEarnedToday += earnedPoints
        stats.points += earnedPoints
        App.instance.sideMenuView.userPanel.ReloadPanel()
    }
    
    static func DeductPointsForTask(task: Task) {
        stats.points -= getPointsForTask(task: task)
        App.instance.sideMenuView.userPanel.ReloadPanel()
    }
    
    static func getPointsForTask(task: Task) -> Int {
        if !task.isCompleted { return 0 }
        
        if !task.isDateAssigned { return pointsPerTask }
        
        let delta = Calendar.current.daysBetween(task.dateCompleted, and: task.dateAssigned)
        
        return max(0, min(pointsPerTask, pointsPerTask+delta*2))
    }
    
    static func UnlockBadge(badgeGroup: AchievementBadgeGroup, badgeIndex: Int, earnPoints: Bool = true) {
        stats.badges[badgeGroup.groupID] = badgeIndex

        App.instance.ShowBadgeNotification(badgeGroup: badgeGroup)
        
        if badgeGroup.groupID != 6 && earnPoints {
            EarnPoints(points: getPointsForBadge(stage: badgeIndex), ignoreDailyLimit: true)
        }
    }
    
    static func getPointsForBadge(stage: Int) -> Int {
        if stage == 0 { return 50 }
        else if stage == 1 { return 100 }
        else if stage == 2 { return 300 }
        else if stage == 3 { return 500 }
        else if stage == 4 { return 1000 }
        return 0
    }
    
    static func DetectNewDay () {
        if !Calendar.current.isDateInToday(stats.lastDayActive) {
            OnNewDay()
            stats.lastDayActive = Date()
        }
    }
    
    static func OnNewDay () {
        stats.totalDaysActive += 1
        stats.pointsEarnedToday = 0
        if Calendar.current.isDateInYesterday(stats.lastDayActive) {
            stats.consecutiveDaysActive += 1
            stats.consecutiveDaysWithoutOverdueTasks += 1
            
            CheckUnlockedBadge(groupID: 2)
            CheckUnlockedBadge(groupID: 5)
        }
        else {
            stats.consecutiveDaysActive = 1
            stats.consecutiveDaysWithoutOverdueTasks = 1
        }
        CheckUnlockedBadge(groupID: 0)
        CheckUnlockedBadge(groupID: 1)
    }
    
    static func CheckUnlockedBadge (groupID: Int) {
        for i in (0..<allBadgeGroups[groupID].unlockStatValue.count).reversed() {
            if allBadgeGroups[groupID].relatedStat() >= allBadgeGroups[groupID].unlockStatValue[i] {
                if stats.badges[groupID] != i {
                    UnlockBadge(badgeGroup: allBadgeGroups[groupID], badgeIndex: i)
                }
                return
            }
        }
    }
    
    static func OnTaskComplete (task: Task) {
        EarnPoints(points: getPointsForTask(task: task))
        stats.totalCompletedTasks += 1
        stats.totalCompletedHighPriorityTasks += task.priority == .High ? 1 : 0
        if stats.totalCompletedTasks < 0 { StatsManager.stats.totalCompletedTasks = 0}
        if stats.totalCompletedHighPriorityTasks < 0 { StatsManager.stats.totalCompletedHighPriorityTasks = 0}
        CheckUnlockedBadge(groupID: 3)
        CheckUnlockedBadge(groupID: 4)
        
        if stats.daysAgoJoined >= 2 && stats.totalCompletedTasks >= 5 {
            SKStoreReviewController.requestReviewInCurrentScene()
        }
    }
}


struct StatsConfig: Codable {
    var _level: Int = 1
    var _points: Int = 0
    var badges: [Int:Int] = [0:-1, 1:-1, 2:-1, 3:-1, 4:-1, 5:-1, 6:-1, 7:-1] //[groudpID : lastUnlockedIndex]
    
    var totalCompletedTasks: Int = 0
    var totalCompletedHighPriorityTasks: Int = 0
    var totalDaysActive: Int = 0
    var consecutiveDaysActive: Int = 0
    var consecutiveDaysWithoutOverdueTasks: Int = 0
    var timesSharedProgress: Int = 0
    
    var dateJoinedApp: Date = Date()
    var lastDayActive: Date = Date()
    
    var pointsEarnedToday: Int = 0
    
    var purchasedUnlockAllPerks = false
    
    var level: Int {
        get { return _level }
        set {
            if newValue > _level {
                App.instance.ReachLevel(level: newValue)
            }
            _level = newValue
        }
    }
    
    var points: Int {
        get { return _points }
        set {
            _points = newValue
            while _points >= StatsManager.getPointsNeededLevelUp(currentLevel: level) {
                _points -= StatsManager.getPointsNeededLevelUp(currentLevel: level)
                level += 1
            }
            while _points < 0 {
                _points += StatsManager.getPointsNeededLevelUp(currentLevel: level-1)
                level -= 1
            }
        }
    }
    
    func lastUnlockedBadgeIndex (badgeGroupID: Int) -> Int {
        return badges[badgeGroupID] ?? -1
    }
    
    var numberOfUnlockedBadges: Int {
        var total = 0
        for (_, lastUnlockedIndex) in badges {
            total += lastUnlockedIndex == -1 ? 0 : lastUnlockedIndex + 1
        }
        return total
    }
    
    var daysAgoJoined: Int {
        return Calendar.current.daysBetween(dateJoinedApp, and: Date())
    }
}

struct AchievementBadgeGroup {
    let groupID: Int
    
    let name: String
    let description: String
    var relatedStat: ()->Int
    var unlockStatValue: [Int]
    
    func getIcon(index: Int) -> UIImage {
        return UIImage(named: getName(index: index))!
    }
    
    func getPlaceholder(index: Int) -> UIImage {
        return UIImage(named: "\(getName(index: index)) Placeholder")!
    }
    
    func getName(index: Int) -> String {
        let arabNumber: String
        if index == 0 { arabNumber = "I" }
        else if index == 1 { arabNumber = "II" }
        else if index == 2 { arabNumber = "III" }
        else if index == 3 { arabNumber = "IV" }
        else if index == 4 { arabNumber = "V" }
        else { arabNumber = "VI" }
        return name.replacingOccurrences(of: "(x)", with: arabNumber)
    }
    
    func getDescription (index: Int) -> String {
        return description.replacingOccurrences(of: "(x)", with: unlockStatValue[index].description)
    }
    
    var numberOfBadges: Int { return unlockStatValue.count }
}

enum LevelPerkType {
    case GrayscaleAndTrueBlackThemes
    case ColoredAppIcons
    case UnlimitedNotifications
    case UnlimitedLists
    case HigherTaskHistoryLimit
}

struct LevelPerk {
    let unlockLevel: Int
    let type: LevelPerkType
    let title: String
    let OnTap: ()->Void
    
    var isUnlocked: Bool {
        return StatsManager.stats.purchasedUnlockAllPerks || StatsManager.stats.level >= unlockLevel
    }
}




extension StatsManager {
    
    static let allBadgeGroups: [AchievementBadgeGroup] = [
        AchievementBadgeGroup(
            groupID: 0,
            name: "Companion (x)",
            description: "Join Finale (x) days ago",
            relatedStat: { return stats.daysAgoJoined },
            unlockStatValue: [10, 30, 180, 360, 1000]),
        
        AchievementBadgeGroup(
            groupID: 1,
            name: "Connoisseur (x)",
            description: "Use Finale for (x) days",
            relatedStat: { return stats.totalDaysActive },
            unlockStatValue: [3, 10, 30, 180, 500]),
        
        AchievementBadgeGroup(
            groupID: 2,
            name: "Patron (x)",
            description: "Use Finale for (x) consecutive days",
            relatedStat: { return stats.consecutiveDaysActive },
            unlockStatValue: [3, 7, 21, 60, 180]),
        
        
        
        AchievementBadgeGroup(
            groupID: 3,
            name: "Workaholic (x)",
            description: "Complete (x) tasks",
            relatedStat: { return stats.totalCompletedTasks },
            unlockStatValue: [20, 50, 200, 500, 1000]),
        
        AchievementBadgeGroup(
            groupID: 4,
            name: "Principal (x)",
            description: "Complete (x) high priority tasks",
            relatedStat: { return stats.totalCompletedHighPriorityTasks },
            unlockStatValue: [10, 30, 100, 300, 500]),
        
        AchievementBadgeGroup(
            groupID: 5,
            name: "Surgeon (x)",
            description: "Last (x) days without overdue tasks",
            relatedStat: { return stats.consecutiveDaysWithoutOverdueTasks },
            unlockStatValue: [7, 21, 30, 90, 365]),
        
        
        
        AchievementBadgeGroup(
            groupID: 6,
            name: "Protagonist (x)",
            description: "Reach (x) level",
            relatedStat: { return stats.level },
            unlockStatValue: [10, 20, 50, 100, 200]),
        
        AchievementBadgeGroup(
            groupID: 7,
            name: "Extravert (x)",
            description: "Share your progress (x) times",
            relatedStat: { return stats.timesSharedProgress },
            unlockStatValue: [2, 5, 10, 20, 30]),
        
    ]
    
    static let allLevelPerks: [LevelPerk] = [
        
        LevelPerk(unlockLevel: 5, type: .GrayscaleAndTrueBlackThemes, title: "Grayscale & True Black themes", OnTap: {}),
        LevelPerk(unlockLevel: 10, type: .UnlimitedNotifications, title: "Set unlimited notifications", OnTap: {}),
        LevelPerk(unlockLevel: 15, type: .ColoredAppIcons, title: "Colored app icons", OnTap: {}),
        LevelPerk(unlockLevel: 20, type: .UnlimitedLists, title: "Create unlimited lists", OnTap: {}),
        LevelPerk(unlockLevel: 25, type: .HigherTaskHistoryLimit, title: "Up to 100 tasks history", OnTap: {}),
    
    ]
    
    static func getLevelPerk(type: LevelPerkType) -> LevelPerk {
        for perk in allLevelPerks {
            if perk.type == type { return perk }
        }
        return allLevelPerks[0]
    }
    
}
