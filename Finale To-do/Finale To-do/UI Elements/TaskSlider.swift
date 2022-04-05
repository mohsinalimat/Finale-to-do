//
//  TaskSlider.swift
//  Finale To-do
//
//  Created by Grant Oganan on 3/14/22.
//

import SwiftUI

struct TaskSlider: View {
    @State private var confettiCannon: Int = 0
    @State private var percentage: CGFloat = 0.027
    
    @State var isCompleted = false
    @State var taskName: String = ""
    @Binding var task: Task
    @Binding var isDraggingParentView: Bool
    
    @FocusState var focusInputField: Bool
    
    @Binding var isPickingDate: Bool
    @Binding var taskBeingEdited: Task
    
    var taskListView: TaskListView?
    var homeView: HomeView?
    
    var sliderColor: Color
    let sliderHeight = UIScreen.main.bounds.height * 0.042
    let sliderWidth = UIScreen.main.bounds.height * 0.03
    let backgroundColor = Color(uiColor: UIColor.systemGray6)
    let cornerRadius: CGFloat = 10
    
    let placeholders: [String] = ["Finish annual report", "Create images for the presentation", "Meditate", "Plan holidays with the family", "Help mom with groceries", "Buy new shoes", "Get cat food", "Get dog food", "Brush my corgie", "Say hi to QQ", "Chmok my QQ", "Buy airplane tickets", "Cancel streaming subscription", "Schedule coffee chat", "Schedule work meeting", "Dye my hair", "Download Elden Ring", "Get groceries"]
    @State var randomPlaceholder = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                ForEach (0..<4) {
                    ConfettiCannon(counter: $confettiCannon, num: 5,  confettis: [.shape(.circle)], colors: [sliderColor], confettiSize: 5, rainHeight: 0, openingAngle: Angle(degrees: 10), closingAngle: Angle(degrees: 170), radius: 50)
                        .offset(x: CGFloat($0) * geometry.size.width / 4)

                    ConfettiCannon(counter: $confettiCannon, num: 5,  confettis: [.shape(.circle)], colors: [sliderColor], confettiSize: 5, rainHeight: 0, openingAngle: Angle(degrees: 190), closingAngle: Angle(degrees: 350), radius: 50)
                        .offset(x: CGFloat($0) * geometry.size.width / 4)
                }
                Rectangle()
                    .foregroundColor(isCompleted ? sliderColor.secondaryColor.opacity(0.5) : backgroundColor)
                    .cornerRadius(cornerRadius)
                    .frame(height: sliderHeight)
                    .onAppear {
                        randomPlaceholder = Int.random(in: 0..<placeholders.count)
                        isCompleted = task.isCompleted
                        taskName = task.name
                    }
                
                Rectangle()
                    .foregroundColor(sliderColor)
                    .opacity(isCompleted ? 0 : 1)
                    .cornerRadius(cornerRadius)
                    .frame(width: geometry.size.width * self.percentage, height: sliderHeight)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged({ value in
                                if task.isCompleted || task.name.isEmpty { return }

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
                            .opacity(isCompleted ? 0 : 1)
                    )

                HStack {
                    let padding = isCompleted ? 4 : sliderWidth

                    if !isCompleted {
                        TextField(placeholders[randomPlaceholder], text: $taskName)
                            .padding(.horizontal, CGFloat((padding + 4)))
                            .frame(height: sliderHeight, alignment: .leading)
                            .disabled(!isBeingEdited)
                            .focused($focusInputField)
                            .foregroundColor(Color.primary)
                            .onSubmit {
                                StopEditing()
                            }
                    } else {
                        Text(task.name)
                            .strikethrough()
                            .padding(.horizontal, CGFloat((padding + 4)))
                            .frame(height: sliderHeight, alignment: .trailing)
                            .foregroundColor(Color(uiColor: UIColor.systemGray))
                    }

                    Spacer()

                    HStack {
                        if !isBeingEdited {
                            if task.isDateAssigned {
                                Text(assignedDateTimeString)
                                    .strikethrough(isCompleted)
                                    .frame(height: sliderHeight, alignment: .trailing)
                                    .foregroundColor(Color(uiColor: UIColor.systemGray))
                                if !isCompleted {
                                    Image(systemName: "calendar")
                                        .foregroundColor(.gray)
                                }
                            }
                        } else {
                            Group {
                                Text(assignedDateTimeString)
                                    .strikethrough(isCompleted)
                                    .frame(height: sliderHeight, alignment: .trailing)
                                    .foregroundColor(Color(uiColor: UIColor.systemGray))
                                if !isCompleted {
                                    Image(systemName: "calendar")
                                        .foregroundColor(.gray)
                                }
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
            .contextMenu {
                if !isDraggingParentView {
                    if task.isCompleted {
                        Button(action: {
                            Undo()
                        }, label: {
                            Label("Undo", systemImage: "arrow.uturn.backward")
                        })
                    } else {
                        Button(action: {
                            StartEditing()
                        }, label: {
                            Label("Edit", systemImage: "square.and.pencil")
                        })
                    }
                    Button(role: .destructive, action: {
                        DeleteTask()
                    }, label: {
                        Label("Delete", systemImage: "trash")
                    })
                }
            }
            .onTapGesture(count: 2) {
                StartEditing()
            }
        }
    }
    
    func Undo () {
        withAnimation(.linear(duration: 0.15)) {
            isCompleted = false
        }
        taskListView?.UndoTask(task: task)
    }
    
    func StartEditing () {
        taskBeingEdited = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                focusInputField = true
            }
    }
    
    func DeleteTask () {
        if !task.isCompleted {
            taskListView?.DeleteUpcoming(task: task)
            homeView?.DeleteUpcoming(task: task)
        } else {
            taskListView?.DeleteCompleted(task: task)
            homeView?.DeleteCompleted(task: task)
        }
    }
    
    func StopEditing () {
        taskBeingEdited = Task()
        focusInputField = false
        UIApplication.shared.endEditing()
        task.name = taskName
        if task.name == "" {
            DeleteTask()
        }
    }
    
    func OnFullSlide () {
        focusInputField = false
        confettiCannon+=1
        taskListView?.CompleteTask(task: task)
        homeView?.CompleteTask(task: task)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(.linear(duration: 0.15)) {
                    isCompleted = true
                }
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

struct MenuView: View {
    var slider: TaskSlider
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(.ultraThinMaterial)
            
            VStack (alignment: .leading) {
                if slider.task.isCompleted {
                    Button(action: {
                        slider.Undo()
                    }, label: {
                        Label("Undo", systemImage: "arrow.uturn.backward")
                    })
                } else {
                    Button(action: {
                        slider.StartEditing()
                    }, label: {
                        Label("Edit", systemImage: "square.and.pencil")
                    })
                }
                Button(role: .destructive, action: {
                    slider.DeleteTask()
                }, label: {
                    Label("Delete", systemImage: "trash")
                })
            }
        }
        .frame(width: UIScreen.main.bounds.width*0.3, height: UIScreen.main.bounds.width*0.2)
    }
}

struct TaskSlider_Preview: PreviewProvider {
    static var previews: some View {
        let task = Task(name: "Name", isComleted: false, isDateAssigned: true, dateAssigned: Date())
        TaskSlider(task: .constant(task), isDraggingParentView: .constant(false), isPickingDate: .constant(false), taskBeingEdited: .constant(Task(name: "")), sliderColor: .cyan)
    }
}

