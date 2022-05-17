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

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
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

struct HomeScreenWidgetEntryView : View {
    var entry: Provider.Entry

    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall: SmallWidgetView(entry: entry)
        case .systemMedium: MediumWidgetView(entry: entry)
        case .systemLarge: LargeWidgetView(entry: entry)
        case .systemExtraLarge:
            EmptyView()
        @unknown default: EmptyView()
        }
    }
}

@main
struct HomeScreenWidget: Widget {
    let kind: String = "Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            HomeScreenWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Tasks")
        .description("Quick overview of your upcoming tasks.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}




struct SmallWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        WidgeTaskListView(entry: entry, maxNumberOfTasks: 6, showDate: false, taskNumber: entry.taskNumber)
    }
}


struct MediumWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        WidgeTaskListView(entry: entry, maxNumberOfTasks: 6, showDate: true, taskNumber: entry.taskNumber)
    }
}


struct LargeWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        WidgeTaskListWithCompletedView(entry: entry, maxNumberOfTasks: WidgetSync.maxNumberOfTasks, taskNumber: entry.taskNumber)
    }
}

struct WidgeTaskListView: View {
    var entry: Provider.Entry
    
    let maxNumberOfTasks: Int
    let showDate: Bool
    let taskNumber: Int
    
    var body: some View {
        
        ZStack (alignment: .topLeading) {
            Color(uiColor: .systemGray6)
            VStack(alignment: .trailing, spacing: 2) {
                TitleRow(titleText: entry.title, taskNumber: taskNumber)
                
                if entry.upcomingTasks.count > 0 {
                    ForEach(0..<min(maxNumberOfTasks, entry.upcomingTasks.count)) { i in
                        UpcomingTaskRow(task: entry.upcomingTasks[i], showDate: showDate, currentDate: entry.date)
                    }

                    Spacer()
                } else {
                    HStack{
                        Text("You don't have any tasks here yet.")
                                .foregroundColor(.gray)
                                .font(.footnote)
                        Spacer()
                    }
                }
                
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            .padding()
        }
    }
}

struct WidgeTaskListWithCompletedView: View {
    var entry: Provider.Entry
    
    let maxNumberOfTasks: Int
    let taskNumber: Int
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGray6)
            VStack(alignment: .trailing, spacing: 2) {
                TitleRow(titleText: entry.title, taskNumber: taskNumber)
                
                if entry.upcomingTasks.count > 0 || entry.completedTasks.count > 0 {
                    HStack {
                        Text("Upcoming")
                           .font(.footnote)
                           .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding(.vertical, 2)

                    ForEach(entry.upcomingTasks) { upcomingTask in
                        UpcomingTaskRow(task: upcomingTask, showDate: true, currentDate: entry.date)
                    }
                    
                    if entry.upcomingTasks.count <= WidgetSync.maxNumberOfTasks  {
                        HStack {
                            Text("Completed")
                               .font(.footnote)
                               .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding(.top, 6)
                        .padding(.bottom, 2)

                        ForEach(entry.completedTasks) { completedTask in
                            CompletedTaskRow(task: completedTask, showDate: true, currentDate: entry.date)
                        }
                    }
                    

                    Spacer()
                } else {
                    HStack{
                        Text("You don't have any tasks here yet.")
                                .foregroundColor(.gray)
                                .font(.footnote)
                        Spacer()
                    }
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            .padding()
        }
    }
}

struct UpcomingTaskRow: View {
    let task: WidgetTask
    let showDate: Bool
    let currentDate: Date
    
    var body: some View {
        HStack {
            Circle()
                .frame(width: 6, height: 6)
                .foregroundColor(Color(hex: task.colorHex))
            Text(task.name)
                .font(.system(size: 12))
                .lineLimit(1)
            Spacer()
            
            if showDate {
                Text(task.assignedDateTimeString(currentDate: currentDate))
                    .font(.system(size: 10))
                    .foregroundColor(task.isOverdue(currentDate: currentDate) ? Color.red.lerp(second: .black, percentage: 0.2) : Color(uiColor: .systemGray))
            }
        }
    }
}

struct CompletedTaskRow: View {

    let task: WidgetTask
    let showDate: Bool
    let currentDate: Date
    
    var body: some View {
        HStack {
            Text(task.name)
                .strikethrough(true, color: Color(uiColor: .systemGray3))
                .font(.system(size: 12))
                .foregroundColor(Color(uiColor: .systemGray3))
                .lineLimit(1)
            Spacer()
            if showDate {
                Text(task.assignedDateTimeString(currentDate: currentDate))
                    .strikethrough()
                    .font(.system(size: 10))
                    .foregroundColor(Color(uiColor: .systemGray3))
            }
        }
    }
    
}

struct TitleRow: View {
    let titleText: String
    let taskNumber: Int
    
    var body: some View {
        HStack {
            Text(titleText)
                .font(.system(size: 20, weight: .bold))
            Spacer()
            Text(taskNumber == 0 ? "" : taskNumber.description)
                .foregroundColor(.gray)
                .font(.system(size: 16))
        }
        .frame(height: 22)
        .padding(.bottom, 4)
    }
}

