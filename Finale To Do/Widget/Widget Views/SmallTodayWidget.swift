//
//  SmallTodayWidget.swift
//  WidgetExtension
//
//  Created by Grant Oganan on 6/16/22.
//

import SwiftUI

struct SmallTodayWidget: View {
    
    var entry: SimpleEntry
    
    let maxNumberOfTasks: Int = 6
    
    var tasksToday = [WidgetTask]()
    
    init(entry: SimpleEntry) {
        self.entry = entry
        
        for i in 0..<entry.upcomingTasks.count {
            if !entry.upcomingTasks[i].isDateAssigned { continue }
            if Calendar.current.isDateInToday(entry.upcomingTasks[i].dateAssigned) {
                tasksToday.append(entry.upcomingTasks[i] )
            }
        }
    }
    
    var body: some View {
        ZStack (alignment: .topLeading) {
            Color(uiColor: .systemGray6)
            VStack(alignment: .trailing, spacing: 2) {
                TitleRow(titleText: entry.title, taskNumber: tasksToday.count)
                    .padding(.bottom, 4)
                
                if tasksToday.count > 0 {
                    ForEach(0..<min(maxNumberOfTasks, tasksToday.count)) { i in
                        UpcomingTaskRow(task: tasksToday[i], showDate: false, currentDate: entry.date)
                    }

                    Spacer()
                } else {
                    PlaceholderTitle(title: "You are done with all tasks for today.")
                }
                
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            .padding()
        }
    }
}
