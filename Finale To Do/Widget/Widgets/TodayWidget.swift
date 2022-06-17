//
//  TodayWidget.swift
//  WidgetExtension
//
//  Created by Grant Oganan on 6/16/22.
//

import WidgetKit
import SwiftUI

struct TodayWidgetView : View {
    var entry: SimpleEntry

    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall: SmallTodayWidget(entry: entry)
        case .systemMedium: MediumTodayWidget(entry: entry)
        case .systemExtraLarge: EmptyView()
        @unknown default: EmptyView()
        }
    }
}

struct TodayWidget: Widget {
    let kind: String = "TodayWiget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TodayWidgetView(entry: entry)
        }
        .configurationDisplayName("Tasks Today")
        .description("Overview of your tasks for today.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
