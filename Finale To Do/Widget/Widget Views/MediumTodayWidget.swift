//
//  MediumTodayWidget.swift
//  WidgetExtension
//
//  Created by Grant Oganan on 6/16/22.
//

import SwiftUI

struct MediumTodayWidget: View {
    var entry: SimpleEntry
    
    let maxNumberOfTasks: Int = 6
    
    var tasksToday = [WidgetTask]()
    
    @State var todaysDate = Date.now
    
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
            HStack {
                VStack(alignment: .trailing, spacing: 2) {
                    TitleRow(titleText: entry.title, taskNumber: 0)
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
                
                CompactCalendarView()
            }
            .padding()
        }
    }
}


struct CompactCalendarView: View {
    
    var allWeeks: [WeekModel]!
    let weekdaysLabels: [String]
    
    init() {
        var weeks = [WeekModel]()
        
        let firstDayOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: Date.now)))!
        
        let daysInCurrentMonth = Date().nOfDaysInCurrentMonth()
        let firstDayOfWeek = firstDayOfMonth.get(.weekday) - (Calendar.current.firstWeekday == 1 ? 1 : 2)
        let numberOfWeeks = Int(ceil(Double(daysInCurrentMonth+firstDayOfWeek)/Double(7)))
                
        var firstWeek = WeekModel()
        for i in 0..<firstDayOfWeek {
            firstWeek.days.append(DayModel(date: Calendar.current.date(byAdding: .day, value: i-firstDayOfWeek, to: firstDayOfMonth)!, tasks: []))
        }
        for i in 0..<7-firstDayOfWeek {
            firstWeek.days.append(DayModel(date: Calendar.current.date(byAdding: .day, value: i, to: firstDayOfMonth)!, tasks: []))
        }
        
        weeks.append(firstWeek)
        
        for week in 1..<numberOfWeeks {
            var newWeek = WeekModel()
            for day in 1..<8 {
                newWeek.days.append(DayModel(date: Calendar.current.date(byAdding: .day, value: day, to: weeks[week-1].days.last!.date)!, tasks: []))
            }
            weeks.append(newWeek)
        }
        self.allWeeks = weeks
        self.weekdaysLabels = Calendar.current.firstWeekday == 1 ? ["S", "M", "T", "W", "T", "F", "S"] : ["M", "T", "W", "T", "F", "S", "S"]
    }
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
            VStack(alignment: .trailing, spacing: 0) {
                CompactHeaderLabel()
                CompactWeekdaysLabels(labels: weekdaysLabels)
                
                ForEach(allWeeks) { week in
                    HStack(spacing: 0) {
                        ForEach(week.days) { day in
                            CompactDayView(dayModel: day, drawLeadingBorder: day != week.days.first)
                        }
                    }
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

struct CompactHeaderLabel: View {
    var body: some View {
        HStack {
            Spacer()
            Text(monthString)
                .multilineTextAlignment(.center)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.defaultColor)
        }
        .padding(.vertical, 2)
    }
    
    var monthString: String {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        return dateFormatter.string(from: now)
    }
}

struct CompactDayView: View {
    let dayModel: DayModel
    
    let drawLeadingBorder: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(Calendar.current.isDateInToday(dayModel.date) ? .defaultColor : .clear)
            Text(dayModel.date.get(.day).description)
                .font(.system(size: 10, weight: Calendar.current.isDateInToday(dayModel.date) ? .bold : .regular))
                .foregroundColor(dateColor)
        }
    }
    
    var dateColor: Color {
        if dayModel.date.get(.month, calendar: Calendar.current) - Date.now.get(.month, calendar: Calendar.current) != 0 { return Color(uiColor: .systemGray4) }
        return Calendar.current.isDateInToday(dayModel.date) ? Color.white : Color(uiColor: .label)
    }
}

struct CompactWeekdaysLabels: View {
    let labels: [String]
    
    var body: some View {
        HStack (spacing: 0){
           ForEach(labels, id: \.self) { char in
                ZStack {
                    Rectangle()
                        .foregroundColor(.clear)
                    Text(char)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

