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
        SimpleEntry(title: "Hi, Grant", tasks: [WidgetTask]())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(title: "Hi, Grant", tasks: [WidgetTask]())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let userDefaults = UserDefaults(suiteName: "group.finale-to-do-widget-cache")!

        let title = userDefaults.value(forKey: WidgetSync.widgetTitleSyncKey) as! String
        var tasks = [WidgetTask]()

        if let data = userDefaults.data(forKey: WidgetSync.widgetTasksSyncKey) {
            if let decoded = try? JSONDecoder().decode([WidgetTask].self, from: data) {
                tasks = decoded
            }
        }
        
        
        let timeline = Timeline(entries: [SimpleEntry(title: title, tasks: tasks)], policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date = Date.now
    
    let title: String
    let tasks: [WidgetTask]
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
        WidgeTaskListView(entry: entry, maxNumberOfTasks: 5)
    }
}


struct MediumWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        WidgeTaskListView(entry: entry, maxNumberOfTasks: 5)
    }
}


struct LargeWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        WidgeTaskListWithCompletedView(entry: entry, maxNumberOfTasks: 16)
    }
}

struct WidgeTaskListView: View {
    var entry: Provider.Entry
    
    let maxNumberOfTasks: Int
    
    var body: some View {
        
        ZStack (alignment: .topLeading) {
            Color(uiColor: .systemGray6)
            VStack(alignment: .trailing, spacing: 2) {
                TitleRow(titleText: entry.title)
                    .frame(height: 30)
                
                ForEach(0..<min(maxNumberOfTasks, entry.tasks.count)) { i in
                    TaskRow(task: entry.tasks[i])
                }
                
                Spacer()
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            .padding()
        }
    }
}

struct WidgeTaskListWithCompletedView: View {
    var entry: Provider.Entry
    
    let maxNumberOfTasks: Int
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGray6)
            VStack(alignment: .trailing, spacing: 2) {
                TitleRow(titleText: entry.title)
                    .frame(height: 30)
                
                HStack {
                    Text("Upcoming")
                       .font(.footnote)
                       .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.vertical, 2)
                 
                ForEach(0..<min(7, entry.tasks.count)) { i in
                    TaskRow(task: entry.tasks[i])
                }
//                HStack {
//                    Text("Completed")
//                       .font(.footnote)
//                       .foregroundColor(.gray)
//                    Spacer()
//                }
//                .padding(.vertical, 2)
//                ForEach(8..<15) { i in
//                    CompletedTaskRow(task: entry.tasks[i])
//                }
//                
                Spacer()
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            .padding()
        }
    }
}

struct TaskRow: View {
    let task: WidgetTask
    
    var body: some View {
        HStack {
            Circle()
                .frame(width: 6, height: 6)
                .foregroundColor(Color(hex: task.colorHex))
            Text(task.name)
                .font(.footnote)
            Spacer()
        }
    }
}

struct CompletedTaskRow: View {

    let task: WidgetTask
    
    var body: some View {
        HStack {
            Text(task.name)
                .strikethrough(true, color: Color(uiColor: .systemGray3))
                .font(.footnote)
                .foregroundColor(Color(uiColor: .systemGray3))
            Spacer()
        }
    }
    
}

struct TitleRow: View {
    let titleText: String
    
    var body: some View {
        HStack {
            Text(titleText)
                .font(.system(size: 22, weight: .bold))
            Spacer()
        }
    }
}
