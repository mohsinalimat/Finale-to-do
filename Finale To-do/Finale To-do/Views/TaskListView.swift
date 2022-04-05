//
//  TaskGroupView.swift
//  Finale To-do
//
//  Created by Grant Oganan on 3/15/22.
//

import SwiftUI

struct TaskListView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var taskList: TaskList
    
    @State var showCalendar = false
    @State var taskBeingEdited = Task(name: "", dateAssigned: Date.now)
    @State var lastCompletedTask: Task?
    
    @State var needResetInitialOffest = true
    
    var appView: AppView?
    
    @State var undoTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color(uiColor: UIColor.systemBackground)
                .ignoresSafeArea()
                .zIndex(0)
                .onChange(of: showCalendar) { newValue in
                    appView?.blockSideMenu = newValue
                }
            
            VStack (spacing: 0) {
                ZStack (alignment: .leading) {
                    ZStack {
                        Rectangle()
                            .foregroundStyle(.ultraThinMaterial)
                        Rectangle()
                            .foregroundColor(taskList.primaryColor.opacity(colorScheme == .light ? 1 : 0.8))
                            .blendMode(colorScheme == .light ? .multiply : .screen)
                    }
                    .ignoresSafeArea()
                    .frame(height: UIScreen.main.bounds.height*0.15)
                    
                    VStack (alignment: .leading, spacing: 10) {
                        Button {
                            if appView!.isSideMenuOpen { appView?.CloseSideMenu() }
                            else { appView?.OpenSideMenu() }
                        } label: {
                            Label("", systemImage: "line.3.horizontal")
                                .foregroundColor(.white)
                                .font(.title)
                        }
                        .padding()
                        
                        Text(taskList.name)
                            .font(.system(size: 40, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .foregroundColor(.white)
                    }
                }.zIndex(2)
                
                
                List {
                    Section (header: Text("Upcoming")) {
                        ForEach($taskList.upcomingTasks) { task in
                            TaskSlider(task: task, isDraggingParentView: appView!.$isDragging, isPickingDate: $showCalendar, taskBeingEdited: $taskBeingEdited, taskListView: self, sliderColor: taskList.primaryColor)
                        }
                    }
                    .listRowSeparator(.hidden)
                    Section (header: Text("Completed")) {
                        ForEach($taskList.completedTasks) { task in
                            TaskSlider(task: task, isDraggingParentView: appView!.$isDragging, isPickingDate: $showCalendar, taskBeingEdited: $taskBeingEdited, taskListView: self, sliderColor: taskList.primaryColor)
                        }
                    }
                    .listRowSeparator(.hidden)
                }
                .padding(.top, -200)
                .listStyle(.plain)
                .overlay {
                    GeometryReader { geo in
                        AddTaskButton(color: taskList.primaryColor, taskListView: self)
                            .padding()
                            .position(x: geo.size.width*0.85, y: geo.size.height-geo.size.width*0.075)
                        
                        UndoButton(color: taskList.primaryColor, taskListView: self)
                            .padding()
                            .position(x: geo.size.width*0.15, y: lastCompletedTask == nil ? geo.size.height+geo.size.width*0.15 : geo.size.height-geo.size.width*0.075)
                            .onReceive(undoTimer) { _ in
                                withAnimation(.linear(duration: 0.25)) {
                                    lastCompletedTask = nil
                                }
                                self.undoTimer.upstream.connect().cancel()
                            }
                    }

                }
                .zIndex(1)
            }
            
            if showCalendar {
                DateSelectionUI(showView: $showCalendar, taskBeingEdited: $taskBeingEdited, color: taskList.primaryColor, notificationEnabled: taskBeingEdited.isNotificationEnabled)
                    .transition(.opacity)
                    .zIndex(3)
            }
        }
        .ignoresSafeArea(.keyboard)
    }
    
    func CompleteTask (task: Task) {
        if !taskList.upcomingTasks.contains(task) { return }
        
        task.isCompleted = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation(.linear(duration: 0.5)) {
                taskList.upcomingTasks.remove(at: taskList.upcomingTasks.firstIndex(of: task)!)
                taskList.completedTasks.insert(task, at: 0)
            }
            withAnimation(.linear(duration: 0.25)) {
                lastCompletedTask = task
            }
            
            self.undoTimer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
        }
    }
    
    func UndoTask () {
        if lastCompletedTask == nil { return }
        
        UndoTask(task: lastCompletedTask!)
    }
    func UndoTask(task: Task) {
        if !taskList.completedTasks.contains(task) { return }
        
        withAnimation(.linear(duration: 0.5)) {
            task.isCompleted = false
            taskList.upcomingTasks.insert(task, at: 0)
            taskList.completedTasks.remove(at: taskList.completedTasks.firstIndex(of: task)!)
        }
        withAnimation(.linear(duration: 0.25)) {
            lastCompletedTask = nil
        }
    }
    
    func CreateNewTask () {
        needResetInitialOffest = true
        withAnimation(.linear(duration: 0.5)) {
            let newTask = Task(name: "")
            taskList.upcomingTasks.insert(newTask, at: 0)
            taskBeingEdited = newTask
        }
    }
    
    func DeleteUpcoming (task: Task) {
        if !taskList.upcomingTasks.contains(task) { return }
        
        withAnimation(.linear(duration: 0.5)) {
            taskList.upcomingTasks.remove(at: taskList.upcomingTasks.firstIndex(of: task)!)
        }
    }
    
    func DeleteCompleted (task: Task) {
        if !taskList.completedTasks.contains(task) { return }
        
        withAnimation(.linear(duration: 0.5)) {
            taskList.completedTasks.remove(at: taskList.completedTasks.firstIndex(of: task)!)
        }
    }
}

struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        TaskListView(taskList: TaskList(name: "Home", primaryColor: .cyan, upcomingTasks: [Task(name: "Die")]), appView: nil)
    }
}

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}