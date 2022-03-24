//
//  TaskSlider.swift
//  Finale To-do
//
//  Created by Grant Oganan on 3/14/22.
//

import SwiftUI

struct UpcomingTaskSlider: View {
    @State private var percentage: CGFloat = 0.027
    @State var task: Task
    @State var isEditing: Bool = false
    
    @Binding var isPickingDate: Bool
    @Binding var taskBeingEdited: Task
    
    var sliderColor: Color
    let sliderHeight = UIScreen.main.bounds.height * 0.042
    let sliderWidth = UIScreen.main.bounds.height * 0.027 //0.07
    let backgroundColor = Color(uiColor: UIColor.systemGray6)
    let cornerRadius: CGFloat = 10
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(backgroundColor)
                    .cornerRadius(cornerRadius)
                Rectangle()
                    .foregroundColor(sliderColor)
                    .cornerRadius(cornerRadius)
                    .frame(width: geometry.size.width * self.percentage, height: sliderHeight)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged({ value in
                                if task.isCompleted { return }
                                
                                withAnimation(.linear(duration: 0.03)) {
                                    self.percentage = min(max(sliderWidth/geometry.size.width, value.location.x / geometry.size.width), 1)
                                }
                            })
                            .onEnded( { value in
                                if task.isCompleted { return }
                                
                                if self.percentage >= 1 {
                                    OnFullSlide()
                                } else {
                                    if value.predictedEndLocation.x - value.location.x > 300 {
                                        withAnimation(.easeOut(duration: 0.2)) {
                                            self.percentage = 1
                                            OnFullSlide()
                                        }
                                    } else {
                                        withAnimation(.easeOut(duration: 0.2)) {
                                            self.percentage = sliderWidth/geometry.size.width
                                        }
                                    }
                                }
                            })
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius*0.8)
                            .foregroundColor(sliderColor.thirdColor)
                            .allowsHitTesting(false)
                            .frame(width: sliderWidth * 0.8, height: sliderHeight * 0.85)
                            .position(x: geometry.size.width * (CGFloat(percentage) - (sliderWidth/geometry.size.width)*0.5), y: sliderHeight*0.5)
                    )
                
                HStack {
                    if isEditing {
                        TextField("New task", text: $task.name)
                            .padding(.horizontal, CGFloat((sliderWidth + 4)))
                            .frame(height: sliderHeight, alignment: .leading)
                    } else {
                        Text(task.name)
                            .padding(.horizontal, CGFloat((sliderWidth + 4)))
                            .frame(height: sliderHeight, alignment: .leading)
                    }
                    
                    Spacer()

                    HStack {
                        if isEditing {
                            Group {
                                if assignedDateTimeString != "" {
                                    Text(assignedDateTimeString)
                                        .frame(height: sliderHeight, alignment: .trailing)
                                        .foregroundColor(Color(uiColor: UIColor.systemGray))
                                }

                                Image(systemName: "calendar")
                                    .foregroundColor(.gray)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation (.linear(duration: 0.2)) {
                                    isPickingDate.toggle()
                                    taskBeingEdited = task
                                }
                                if !task.isDateAssigned {
                                    task.dateAssigned = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date.now)!
                                }
                            }
                        } else {
                            if assignedDateTimeString != "" {
                                Text(assignedDateTimeString)
                                    .frame(height: sliderHeight, alignment: .trailing)
                                    .foregroundColor(Color(uiColor: UIColor.systemGray))
                                Image(systemName: "calendar")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.trailing, 6)
                }
            }
            .onAppear {
                percentage = sliderWidth/geometry.size.width
            }
        }
        .ignoresSafeArea(.keyboard)
        .frame(height: sliderHeight)
        .contextMenu {
            Button {
                isEditing = true
            } label: {
                Label("Edit", systemImage: "square.and.pencil")
            }
        }
    }
    
    func OnFullSlide () {
        task.isCompleted = true
    }
    
    var assignedDateTimeString: String {
        if !task.isDateAssigned {
            return ""
        }
        
        let formatter = DateFormatter()
        
        if task.dateAssigned.get(.year) == Date.now.get(.year) { //this year
            if !task.isNotificationEnabled {
                formatter.setLocalizedDateFormatFromTemplate("MMMMd")
            } else {
                formatter.setLocalizedDateFormatFromTemplate("MMMMd, hh:mm")
            }
        } else { //other years
            formatter.timeStyle = task.isNotificationEnabled ? .short : .none
            formatter.dateStyle = .short
        }
        return formatter.string(from: task.dateAssigned)
    }
}

struct UpcomingTaskSlider_Preview: PreviewProvider {
    static var previews: some View {
        UpcomingTaskSlider(task: Task(name: "Task title", dateAssigned: Date()), isPickingDate: .constant(false), taskBeingEdited: .constant(Task(name: "")), sliderColor: .cyan)
    }
}

