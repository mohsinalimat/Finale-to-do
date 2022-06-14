//
//  SharedViews.swift
//  Finale To Do
//
//  Created by Grant Oganan on 6/13/22.
//

import SwiftUI


struct UpcomingTaskRow: View {
    let task: WidgetTask
    let showDate: Bool
    let currentDate: Date
    
    var body: some View {
        HStack {
            Circle()
                .frame(width: 6, height: 6)
                .foregroundColor(Color(hex: task.colorHex))
            Text(task.name)
                .font(.system(size: 12))
                .lineLimit(1)
                .foregroundColor(task.isHighPriority ? Color(hex: task.colorHex) : Color(uiColor: UIColor.label))
            Spacer()
            
            if showDate {
                Text(task.assignedDateTimeString(currentDate: currentDate))
                    .font(.system(size: 10))
                    .foregroundColor(task.isOverdue(currentDate: currentDate) ? Color.red.lerp(second: .black, percentage: 0.2) : Color(uiColor: .systemGray))
            }
        }
    }
}

struct CompletedTaskRow: View {

    let task: WidgetTask
    let showDate: Bool
    let currentDate: Date
    
    var body: some View {
        HStack {
            Text(task.name)
                .strikethrough(true, color: Color(uiColor: .systemGray3))
                .font(.system(size: 12))
                .foregroundColor(Color(uiColor: .systemGray3))
                .lineLimit(1)
            Spacer()
            if showDate {
                Text(task.assignedDateTimeString(currentDate: currentDate))
                    .strikethrough()
                    .font(.system(size: 10))
                    .foregroundColor(Color(uiColor: .systemGray3))
            }
        }
    }
    
}

struct TitleRow: View {
    let titleText: String
    let taskNumber: Int
    
    var body: some View {
        HStack {
            Text(titleText)
                .font(.system(size: 20, weight: .bold))
            Spacer()
            Text(taskNumber == 0 ? "" : taskNumber.description)
                .foregroundColor(.gray)
                .font(.system(size: 16))
        }
        .frame(height: 22)
    }
}


struct PlaceholderTitle: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
                .font(.footnote)
            Spacer()
        }
    }
}

struct SectionTitle: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.gray)
            Spacer()
        }
        .padding(.top, 4)
    }
}
