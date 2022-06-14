//
//  LargeWidgetMain.swift
//  Finale To Do
//
//  Created by Grant Oganan on 6/13/22.
//

import SwiftUI

struct LargeOverviewWidget: View {
    var entry: SimpleEntry
    
    let maxNumberOfTasks: Int
    let taskNumber: Int
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
            VStack(alignment: .trailing, spacing: 2) {
                TitleRow(titleText: entry.title, taskNumber: taskNumber)
                
                if entry.upcomingTasks.count > 0 || entry.completedTasks.count > 0 {
                    SectionTitle(title: "Upcoming")

                    ForEach(entry.upcomingTasks) { upcomingTask in
                        UpcomingTaskRow(task: upcomingTask, showDate: true, currentDate: entry.date)
                    }
                    
                    if entry.upcomingTasks.count <= WidgetSync.maxNumberOfTasks  {
                        SectionTitle(title: "Completed")

                        ForEach(entry.completedTasks) { completedTask in
                            CompletedTaskRow(task: completedTask, showDate: true, currentDate: entry.date)
                        }
                    }
                    

                    Spacer()
                } else {
                    PlaceholderTitle(title: "You don't have any tasks here yet.")
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            .padding()
        }
    }
}

