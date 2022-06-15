//
//  OverviewWidget.swift
//  Finale To Do
//
//  Created by Grant Oganan on 6/13/22.
//

import WidgetKit
import SwiftUI

struct OveriviewWidgetView : View {
    var entry: SimpleEntry

    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall: SimpleOverviewWidget(entry: entry, showDate: false, taskNumber: entry.taskNumber)
        case .systemMedium: SimpleOverviewWidget(entry: entry, showDate: true, taskNumber: entry.taskNumber)
        case .systemLarge: LargeOverviewWidget(entry: entry, taskNumber: entry.taskNumber)
        case .systemExtraLarge: EmptyView()
        @unknown default: EmptyView()
        }
    }
}

struct OverviewWidget: Widget {
    let kind: String = "OverviewWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            OveriviewWidgetView(entry: entry)
        }
        .configurationDisplayName("Tasks Overview")
        .description("Quick overview of your upcoming tasks.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
