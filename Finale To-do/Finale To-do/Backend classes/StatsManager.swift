//
//  StatsManager.swift
//  Finale To-do
//
//  Created by Grant Oganan on 5/4/22.
//

import Foundation
import UIKit


class StatsManager {
    
    static var stats = StatsConfig()
    
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
    
    static func EarnPointsForTask(task: Task) {
        var earnedPoints = getPointsForTask(task: task)
        let delta = dailyPointsCap - stats.pointsCapContainer.dailyPoints
        if delta == 0 { return }
        else if delta < earnedPoints { earnedPoints = delta }
        
        stats.pointsCapContainer.AddPoints(points: earnedPoints)
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
    
    static func UnlockBadge(badgeGroup: AchievementBadgeGroup, badgeIndex: Int) {
        stats.badges[badgeGroup.groupID] = badgeIndex

        App.instance.ShowBadgeNotification(badgeGroup: badgeGroup)
    }
    
    static let pointsPerTask = 10
    static let dailyPointsCap = 500
}


struct StatsConfig: Codable {
    var _level: Int = 1
    var _points: Int = 0
    var badges: [Int:Int] = [0:-1, 1:2, 2:-1] //[groudpID : lastUnlockedIndex]
    
    var totalCompletedTasks: Int = 0
    var totalCompletedHighPriorityTasks: Int = 0
    var totalDaysActive: Int = 0
    var consecutiveDaysActive: Int = 0
    var consecutiveDaysWithoutOverdueTasks: Int = 0
    var timesSharedProgress: Int = 0
    
    var dateJoinedApp: Date = Date()
    
    var pointsCapContainer: PointsCapContainer = PointsCapContainer()
    
    var level: Int {
        get { return _level }
        set {
            if newValue > _level { App.instance.ShowLevelUpNotification(level: newValue) }
            _level = newValue
        }
    }
    
    var points: Int {
        get { return _points }
        set {
            _points = newValue
            if _points >= StatsManager.getPointsNeededLevelUp(currentLevel: level) {
                _points -= StatsManager.getPointsNeededLevelUp(currentLevel: level)
                level += 1
            } else if _points < 0 {
                _points += StatsManager.getPointsNeededLevelUp(currentLevel: level-1)
                level -= 1
            }
        }
    }
    
    func lastUnlockedBadgeIndex (badgeGroupID: Int) -> Int {
        return badges[badgeGroupID] ?? -1
    }
}

class PointsCapContainer: Codable {
    var dailyPoints: Int = 0
    var todaysDate: Date = Date()
    
    func AddPoints(points: Int) {
        if !Calendar.current.isDateInToday(todaysDate) { dailyPoints = 0 }
        dailyPoints += points
        todaysDate = Date.now
    }
}

struct AchievementBadgeGroup {
    let groupID: Int
    
    let name: String
    let description: String
    var relatedStat: Int
    var unlockStatValue: [Int]
    
    func getIcon(index: Int) -> UIImage {
        return UIImage(named: "Connoisseur I")!
    }
    
    func getPlaceholder(index: Int) -> UIImage {
        return UIImage(named: "Connoisseur I Placeholder")!
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






extension StatsManager {
    




    
    
    static let allBadgeGroups: [AchievementBadgeGroup] = [
        AchievementBadgeGroup(
            groupID: 0,
            name: "Companion (x)",
            description: "Join Finale (x) days ago",
            relatedStat: { return Calendar.current.daysBetween(Date.now, and: stats.dateJoinedApp) }(),
            unlockStatValue: [10, 30, 180, 360, 1000]),
        
        AchievementBadgeGroup(
            groupID: 1,
            name: "Connoisseur (x)",
            description: "Use Finale for (x) days",
            relatedStat: { return stats.totalDaysActive }(),
            unlockStatValue: [3, 10, 30, 180, 500]),
        
        AchievementBadgeGroup(
            groupID: 2,
            name: "Patron (x)",
            description: "Use Finale for (x) consecutive days",
            relatedStat: { return stats.consecutiveDaysActive }(),
            unlockStatValue: [3, 7, 21, 60, 180]),
        
        
        
        AchievementBadgeGroup(
            groupID: 2,
            name: "Workaholic (x)",
            description: "Complete (x) tasks",
            relatedStat: { return stats.totalCompletedTasks }(),
            unlockStatValue: [20, 50, 100, 500, 1000]),
        
        AchievementBadgeGroup(
            groupID: 2,
            name: "Principal (x)",
            description: "Complete (x) high priority tasks",
            relatedStat: { return stats.totalCompletedHighPriorityTasks }(),
            unlockStatValue: [10, 30, 100, 300, 500]),
        
        AchievementBadgeGroup(
            groupID: 2,
            name: "Surgeon (x)",
            description: "Last (x) days without overdue tasks",
            relatedStat: { return stats.consecutiveDaysWithoutOverdueTasks }(),
            unlockStatValue: [7, 21, 30, 90, 365]),
        
        
        
        AchievementBadgeGroup(
            groupID: 2,
            name: "Protagonist (x)",
            description: "Reach (x) level",
            relatedStat: { return stats.level }(),
            unlockStatValue: [10, 30, 100, 300, 500]),
        
        AchievementBadgeGroup(
            groupID: 2,
            name: "Extravert (x)",
            description: "Share your progress (x) times",
            relatedStat: { return stats.timesSharedProgress }(),
            unlockStatValue: [2, 5, 10, 20, 30]),
    ]
    
}
