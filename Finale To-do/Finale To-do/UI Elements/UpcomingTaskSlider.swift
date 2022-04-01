//
//  TaskSlider.swift
//  Finale To-do
//
//  Created by Grant Oganan on 3/14/22.
//

import SwiftUI
import ConfettiSwiftUI

struct UpcomingTaskSlider: View {
    @State private var movingToCompleted: Bool = false
    @State private var confettiCannon: Int = 0
    @State private var percentage: CGFloat = 0.027
    @Binding var task: Task
    
    @FocusState var focusInputField: Bool
    
    @Binding var isPickingDate: Bool
    @Binding var taskBeingEdited: Task
    
    var taskListView: TaskListView?
    
    var sliderColor: Color
    let sliderHeight = UIScreen.main.bounds.height * 0.042
    let sliderWidth = UIScreen.main.bounds.height * 0.027 //0.07
    let backgroundColor = Color(uiColor: UIColor.systemGray6)
    let cornerRadius: CGFloat = 10
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                ForEach (0..<10) {
                    ConfettiCannon(counter: $confettiCannon, num: 10,  confettis: [.shape(.circle)], colors: [sliderColor], confettiSize: 5, rainHeight: 0, openingAngle: Angle(degrees: 0), closingAngle: Angle(degrees: 360), radius: 50)
                        .offset(x: CGFloat($0) * geometry.size.width / 5)
                }
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
                    let padding = movingToCompleted ? 4 : sliderWidth
                    TextField("New task", text: $task.name)
                        .padding(.horizontal, CGFloat((padding + 4)))
                        .frame(height: sliderHeight, alignment: .leading)
                        .disabled(!isBeingEdited)
                        .focused($focusInputField)
                        .foregroundColor(movingToCompleted ? Color(uiColor: .systemGray2) : Color.primary)
                        .onSubmit {
                            StopEditing()
                        }

                    Spacer()

                    HStack {
                        if !isBeingEdited {
                            if task.isDateAssigned {
                                Text(assignedDateTimeString)
                                    .frame(height: sliderHeight, alignment: .trailing)
                                    .foregroundColor(Color(uiColor: UIColor.systemGray))
                                Image(systemName: "calendar")
                                    .foregroundColor(.gray)
                            }
                        } else {
                            Group {
                                Text(assignedDateTimeString)
                                    .frame(height: sliderHeight, alignment: .trailing)
                                    .foregroundColor(Color(uiColor: UIColor.systemGray))
                                Image(systemName: "calendar")
                                    .foregroundColor(.gray)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation (.linear(duration: 0.15)) {
                                    isPickingDate.toggle()
                                    taskBeingEdited = task
                                }
                                if !task.isDateAssigned {
                                    task.dateAssigned = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date.now)!
                                }
                            }
                        }
                    }
                    .padding(.trailing, 6)
                }
            }
            .onAppear {
                percentage = sliderWidth/geometry.size.width
                if isBeingEdited { StartEditing() }
            }
        }
        .opacity(movingToCompleted ? 0.1 : 1)
        .contextMenu {
            Button(action: {
                StartEditing()
            }, label: {
                Label("Edit", systemImage: "square.and.pencil")
            })
            Button(role: .destructive, action: {
                DeleteTask()
            }, label: {
                Label("Delete", systemImage: "trash")
            })
        }
    }
    
    func StartEditing () {
        taskBeingEdited = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                focusInputField = true
            }
    }
    
    func DeleteTask () {
        taskListView?.DeleteUpcoming(task: task)
    }
    
    func StopEditing () {
        taskBeingEdited = Task()
        focusInputField = false
        UIApplication.shared.endEditing()
        if task.name == "" {
            DeleteTask()
        }
    }
    
    func OnFullSlide () {
        task.isCompleted = true
        focusInputField = false
        confettiCannon+=1
        taskListView?.CompleteTask(task: task)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            movingToCompleted = true
            }
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
    
    var isBeingEdited: Bool {
        return taskBeingEdited == task
    }
}

struct UpcomingTaskSlider_Preview: PreviewProvider {
    static var previews: some View {
        UpcomingTaskSlider(task: .constant(Task(name: "Task title", dateAssigned: Date())), isPickingDate: .constant(false), taskBeingEdited: .constant(Task(name: "")), sliderColor: .cyan)
    }
}

