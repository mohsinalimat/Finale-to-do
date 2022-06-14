//
//  Widget.swift
//  Widget
//
//  Created by Grant Oganan on 5/14/22.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(date: Date.now)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date.now)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        var entries = [SimpleEntry]()
        
        let currentDate = Date()
        
        for minutesOffset in 0..<10 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minutesOffset*30, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    
    let title: String
    let upcomingTasks: [WidgetTask]
    let completedTasks: [WidgetTask]
    let taskNumber: Int
    
    init (date: Date) {
        self.date = date
        self.title = WidgetSync.userDefaults.value(forKey: WidgetSync.widgetTitleSyncKey) as? String ?? "Tasks"
        
        if let data = WidgetSync.userDefaults.data(forKey: WidgetSync.widgetUpcomingTasksSyncKey) {
            if let decoded = try? JSONDecoder().decode([WidgetTask].self, from: data) {
                self.upcomingTasks = decoded
            } else { self.upcomingTasks = [WidgetTask]() }
        } else { self.upcomingTasks = [WidgetTask]() }
        if let data = WidgetSync.userDefaults.data(forKey: WidgetSync.widgetCompletedTasksSyncKey) {
            if let decoded = try? JSONDecoder().decode([WidgetTask].self, from: data) {
                self.completedTasks = decoded
            } else { self.completedTasks = [WidgetTask]() }
        } else { self.completedTasks = [WidgetTask]() }
        
        self.taskNumber = WidgetSync.userDefaults.value(forKey: WidgetSync.widgetTasksNumberKey) as? Int ?? 0
    }
}


@main
struct AllWidgets: WidgetBundle {
    var body: some Widget {
        OverviewWidget()
        UpcomingWidget()
        CalendargWidget()
    }
}
