//
//  UpcomingWidget.swift
//  Finale To Do
//
//  Created by Grant Oganan on 6/13/22.
//

import SwiftUI
import WidgetKit

struct UpcomingWidgetView : View {
    var entry: SimpleEntry

    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemLarge: LargeUpcomingWidget(entry: entry, taskNumber: entry.taskNumber)
        case .systemExtraLarge: EmptyView()
        @unknown default: EmptyView()
        }
    }
}

struct UpcomingWidget: Widget {
    let kind: String = "UpcomingWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            UpcomingWidgetView(entry: entry)
        }
        .configurationDisplayName("Upcoming Tasks")
        .description("Overview of your upcoming tasks categorized my due date.")
        .supportedFamilies([.systemLarge])
    }
}
