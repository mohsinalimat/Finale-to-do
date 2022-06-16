//
//  CalendarWidget.swift
//  WidgetExtension
//
//  Created by Grant Oganan on 6/13/22.
//

import WidgetKit
import SwiftUI

struct CalendarWidgetView : View {
    var entry: SimpleEntry

    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemLarge: LargeCalendarWidget(entry)
        case .systemExtraLarge: EmptyView()
        @unknown default: EmptyView()
        }
    }
}

struct CalendargWidget: Widget {
    let kind: String = "CalendarWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CalendarWidgetView(entry: entry)
        }
        .configurationDisplayName("Calendar")
        .description("An overview of all your tasks for the current month.")
        .supportedFamilies([.systemLarge])
    }
}
