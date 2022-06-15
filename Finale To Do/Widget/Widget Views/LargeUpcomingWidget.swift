//
//  LargeUpcomingWidget.swift
//  WidgetExtension
//
//  Created by Grant Oganan on 6/13/22.
//

import SwiftUI

struct LargeUpcomingWidget: View {
    var entry: SimpleEntry
    
    let maxNumberOfTasks: Int = 18
    let taskNumber: Int
    
    @State var tasksOverdue = [WidgetTask]()
    @State var tasksToday = [WidgetTask]()
    @State var tasksTomorrow = [WidgetTask]()
    @State var tasksThisWeek = [WidgetTask]()
    @State var tasksNextWeek = [WidgetTask]()
    @State var tasksThisMonth = [WidgetTask]()
    @State var tasksLater = [WidgetTask]()
    @State var tasksWithoutDate = [WidgetTask]()
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .onAppear {
                    InitArrays()
                }
            VStack(alignment: .trailing, spacing: 2) {
                TitleRow(titleText: entry.title, taskNumber: taskNumber)
                
                if entry.upcomingTasks.count > 0 {
                    if tasksOverdue.count > 0 {
                        UpcomingTasksSection(title: "Overdue", tasks: tasksOverdue, currentDate: entry.date, maxNumberOfTasks: min(maxNumberOfTasks, tasksOverdue.count))
                    }
                    if tasksToday.count > 0 {
                        UpcomingTasksSection(title: "Today", tasks: tasksToday, currentDate: entry.date, maxNumberOfTasks: min(maxNumberOfTasks - tasksOverdue.count, tasksToday.count))
                    }
                    if tasksTomorrow.count > 0 {
                        UpcomingTasksSection(title: "Tomorrow", tasks: tasksTomorrow, currentDate: entry.date, maxNumberOfTasks: min(maxNumberOfTasks - tasksOverdue.count - tasksToday.count, tasksTomorrow.count))
                    }
                    if tasksThisWeek.count > 0 {
                        UpcomingTasksSection(title: "This Week", tasks: tasksThisWeek, currentDate: entry.date, maxNumberOfTasks: min(maxNumberOfTasks - tasksOverdue.count - tasksToday.count - tasksTomorrow.count, tasksThisWeek.count))
                    }
                    if tasksNextWeek.count > 0 {
                        UpcomingTasksSection(title: "Next Week", tasks: tasksNextWeek, currentDate: entry.date, maxNumberOfTasks: min(maxNumberOfTasks - tasksOverdue.count - tasksToday.count - tasksTomorrow.count - tasksThisWeek.count, tasksNextWeek.count))
                    }
                    if tasksThisMonth.count > 0 {
                        UpcomingTasksSection(title: "This Month", tasks: tasksThisMonth, currentDate: entry.date, maxNumberOfTasks: min(maxNumberOfTasks - tasksOverdue.count - tasksToday.count - tasksTomorrow.count - tasksThisWeek.count - tasksNextWeek.count, tasksThisMonth.count))
                    }
                    if tasksLater.count > 0 {
                        UpcomingTasksSection(title: "Later", tasks: tasksLater, currentDate: entry.date, maxNumberOfTasks: min(maxNumberOfTasks - tasksOverdue.count - tasksToday.count - tasksTomorrow.count - tasksThisWeek.count - tasksNextWeek.count - tasksThisMonth.count, tasksLater.count))
                    }
                    if tasksWithoutDate.count > 0 {
                        UpcomingTasksSection(title: "Without Date", tasks: tasksWithoutDate, currentDate: entry.date, maxNumberOfTasks: min(maxNumberOfTasks - tasksOverdue.count - tasksToday.count - tasksTomorrow.count - tasksThisWeek.count - tasksNextWeek.count - tasksThisMonth.count - tasksLater.count, tasksWithoutDate.count))
                    }
                } else {
                    PlaceholderTitle(title: "You don't have any tasks here yet.")
                }
                
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            .padding()
        }
    }
    
    func InitArrays () {
        for task in entry.upcomingTasks {
            if task.isDateAssigned {
                if task.isOverdue(currentDate: entry.date) {
                    tasksOverdue.append(task)
                } else if task.isToday(currentDate: entry.date) {
                    tasksToday.append(task)
                } else if task.isTomorrow(currentDate: entry.date) {
                    tasksTomorrow.append(task)
                } else if task.isThisWeek(currentDate: entry.date) {
                    tasksThisWeek.append(task)
                } else if task.isNextWeek(currentDate: entry.date) {
                    tasksNextWeek.append(task)
                }  else if task.isThisMonth(currentDate: entry.date) {
                    tasksThisMonth.append(task)
                } else {
                    tasksLater.append(task)
                }
            } else {
                tasksWithoutDate.append(task)
            }
        }
    }
}

struct UpcomingTasksSection: View {
    
    let title: String
    let tasks: [WidgetTask]
    let currentDate: Date
    
    let maxNumberOfTasks: Int
    
    var body: some View {
        if maxNumberOfTasks > 0 {
            SectionTitle(title: title)
            
            ForEach(0..<min(maxNumberOfTasks, tasks.count)) { i in
                UpcomingTaskRow(task: tasks[i], showDate: true, currentDate: currentDate)
            }
        }
    }
}

