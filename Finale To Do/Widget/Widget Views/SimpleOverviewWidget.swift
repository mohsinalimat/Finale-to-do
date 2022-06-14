//
//  MediumWidget.swift
//  Finale To Do
//
//  Created by Grant Oganan on 6/13/22.
//

import SwiftUI

struct SimpleOverviewWidget: View {
    var entry: SimpleEntry
    
    let maxNumberOfTasks: Int = 6
    let showDate: Bool
    let taskNumber: Int
    
    var body: some View {
        ZStack (alignment: .topLeading) {
            Color(uiColor: .systemGray6)
            VStack(alignment: .trailing, spacing: 2) {
                TitleRow(titleText: entry.title, taskNumber: taskNumber)
                    .padding(.bottom, 4)
                
                if entry.upcomingTasks.count > 0 {
                    ForEach(0..<min(maxNumberOfTasks, entry.upcomingTasks.count)) { i in
                        UpcomingTaskRow(task: entry.upcomingTasks[i], showDate: showDate, currentDate: entry.date)
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
