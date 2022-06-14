//
//  LargeCalendarViewWidget.swift
//  WidgetExtension
//
//  Created by Grant Oganan on 6/13/22.
//

import SwiftUI

struct LargeCalendarWidget: View {
    var entry: SimpleEntry
    
    let allWeeks: [WeekModel]
    let weekdaysLabels: [String]
    
    init(_ entry: SimpleEntry) {
        self.entry = entry
        
        var weeks = [WeekModel]()
        
        let firstDayOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: Date.now)))!
        
        let daysInCurrentMonth = Date().nOfDaysInCurrentMonth()
        let firstDayOfWeek = firstDayOfMonth.get(.weekday) - (Calendar.current.firstWeekday == 1 ? 1 : 2)
        let numberOfWeeks = Int(ceil(Double(daysInCurrentMonth+firstDayOfWeek)/Double(7)))
                
        var firstWeek = WeekModel()
        for i in 0..<firstDayOfWeek {
            firstWeek.days.append(DayModel(date: Calendar.current.date(byAdding: .day, value: i-firstDayOfWeek, to: firstDayOfMonth)!, tasks: [self.entry.upcomingTasks.first!]))
        }
        for i in 0..<7-firstDayOfWeek {
            firstWeek.days.append(DayModel(date: Calendar.current.date(byAdding: .day, value: i, to: firstDayOfMonth)!, tasks: [self.entry.upcomingTasks.last!]))
        }
        
        weeks.append(firstWeek)
        
        for week in 1..<numberOfWeeks {
            var newWeek = WeekModel()
            for day in 1..<8 {
                newWeek.days.append(DayModel(date: Calendar.current.date(byAdding: .day, value: day, to: weeks[week-1].days.last!.date)!, tasks: [self.entry.upcomingTasks.first!]))
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
                MonthLabel()
                WeekdaysLabels(labels: weekdaysLabels)
                
                ForEach(allWeeks) { week in
                    HStack(spacing: 0) {
                        ForEach(week.days) { day in
                            DayView(dayModel: day, drawLeadingBorder: day != week.days.first)
                        }
                    }
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

struct DayView: View {
    let dayModel: DayModel
    
    let drawLeadingBorder: Bool
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .overlay(Rectangle().frame(width: nil, height: 1, alignment: .top).foregroundColor(Color(uiColor: .systemGray4)), alignment: .top)
                .overlay(Rectangle().frame(width: drawLeadingBorder ? 1 : 0, height: nil, alignment: .leading).foregroundColor(Color(uiColor: .systemGray4)), alignment: .leading)
            VStack (spacing: 0) {
                HStack{
                    Text(dayModel.date.get(.day).description)
                        .font(.system(size: 10, weight: Calendar.current.isDateInToday(dayModel.date) ? .bold : .regular))
                        .padding(.leading, 4)
                        .padding(.top, 2)
                        .foregroundColor(dateColor)
                    
                    Spacer()
                }
                ForEach(dayModel.tasks) { task in
                    UpcomingTaskCalendarRow(task: task)
                }
                Spacer()
            }
        }
    }
    
    var dateColor: Color {
        if dayModel.date.get(.month, calendar: Calendar.current) - Date.now.get(.month, calendar: Calendar.current) != 0 { return Color(uiColor: .systemGray4) }
        return Calendar.current.isDateInToday(dayModel.date) ? Color.defaultColor : Color(uiColor: .label)
    }
}

struct UpcomingTaskCalendarRow: View {
    let task: WidgetTask
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(hex: task.colorHex))
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 12)
            HStack {
                Text(task.name)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 10))
                    .lineLimit(1)
                    .padding(.leading, 1)
                    .fixedClipped()
            }
        }
        .padding(.vertical, 1)
        .padding(.horizontal, 2)
        .frame(maxWidth: .infinity)
    }
}

struct CompletedTaskCalendarRow: View {
    let task: WidgetTask
    
    var body: some View {
        HStack {
            Text(task.name)
                .strikethrough()
                .foregroundColor(Color(uiColor: .systemGray2))
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 10))
                .lineLimit(1)
                .padding(.leading, 1)
                .fixedClipped()
        }
        .padding(.vertical, 1)
        .padding(.horizontal, 2)
        .frame(maxWidth: .infinity)
    }
}

struct DayModel: Identifiable, Equatable {
    static func == (lhs: DayModel, rhs: DayModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id = UUID()
    
    let date: Date
    let tasks: [WidgetTask]
}

struct WeekModel: Identifiable {
    var id = UUID()
    
    var days = [DayModel]()
}


struct WeekdaysLabels: View {
    let labels: [String]
    
    var body: some View {
        HStack (spacing: 0){
            ForEach(labels, id: \.self) { char in
                Spacer()
                Text(char)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                Spacer()
            }
        }
    }
}

struct MonthLabel: View {
    var body: some View {
        HStack {
            Spacer()
            Text(monthString)
                .multilineTextAlignment(.center)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.defaultColor)
            Spacer()
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
