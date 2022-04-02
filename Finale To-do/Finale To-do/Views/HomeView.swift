//
//  AllTaskListsView.swift
//  Finale To-do
//
//  Created by Grant Oganan on 3/24/22.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var mainTaskList: TaskList
    @ObservedObject var userTaskLists: TaskListContainer
    
    @State var showCalendar = false
    @State var taskBeingEdited = Task(name: "", dateAssigned: Date.now)
    
    @State var needResetInitialOffest = true
    
    var appView: AppView?
    
    @State var scrollScaleFactor = 0.0
    @State var initialHeaderOffset = 1.0
    
    var body: some View {
        ZStack {
            Color(uiColor: UIColor.systemBackground)
                .ignoresSafeArea()
                .zIndex(0)
                .onChange(of: showCalendar) { newValue in
                    appView?.blockSideMenu = newValue
                }
                .onChange(of: appView?.currentListIndex) { newVal in
                    scrollScaleFactor = 0
                    needResetInitialOffest = true
                }
            
            VStack (spacing: 0) {
                ZStack (alignment: .leading) {
                    Rectangle()
                        .ignoresSafeArea()
                        .foregroundStyle(.ultraThinMaterial)
                        .frame(height: UIScreen.main.bounds.height*0.15)
                        .scaleEffect(y: 1+(scrollScaleFactor/(UIScreen.main.bounds.height*0.15)), anchor: UnitPoint(x: 0, y: 0))
                    VStack (alignment: .leading, spacing: 10) {
                        Button {
                            if appView!.isSideMenuOpen { appView?.CloseSideMenu() }
                            else { appView?.OpenSideMenu() }
                        } label: {
                            Label("", systemImage: "line.3.horizontal")
                                .foregroundColor(.primary)
                                .font(.title)
                        }
                        .padding()
                        
                        Text("Hi, Grant")
                            .font(.system(size: 40 + scrollScaleFactor/30))
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .offset(y: scrollScaleFactor)
                    }
                }.zIndex(2)
                
                
                List {
                    Section (header: Text("Upcoming")) {
                      ForEach($mainTaskList.upcomingTasks) { task in
                          TaskSlider(task: task, isPickingDate: $showCalendar, taskBeingEdited: $taskBeingEdited, homeView: self, sliderColor: mainTaskList.primaryColor)
                        }
                        ForEach(0..<userTaskLists.taskLists.count, id: \.self) { i in
                            ForEach($userTaskLists.taskLists[i].upcomingTasks) { task in
                                TaskSlider(task: task, isPickingDate: $showCalendar, taskBeingEdited: $taskBeingEdited, homeView: self, sliderColor: userTaskLists.taskLists[i].primaryColor)
                            }
                        }
                    }
                    .listRowSeparator(.hidden)
                    Section (header: Text("Completed")) {
                        ForEach($mainTaskList.completedTasks) { task in
                            TaskSlider(task: task, isPickingDate: $showCalendar, taskBeingEdited: $taskBeingEdited, homeView: self, sliderColor: mainTaskList.primaryColor)
                          }
                          ForEach($userTaskLists.taskLists) { taskList in
                              ForEach(taskList.completedTasks) { task in
                                  TaskSlider(task: task, isPickingDate: $showCalendar, taskBeingEdited: $taskBeingEdited, homeView: self, sliderColor: taskList.primaryColor.wrappedValue)
                              }
                          }
                    }
                    .listRowSeparator(.hidden)
                    GeometryReader { proxy in
                        let offset = proxy.frame(in: .named("scroll")).minY
                        Color.clear.preference(key: ViewOffsetKey.self, value: offset)
                    }
                    .onPreferenceChange(ViewOffsetKey.self) { value in
                        if needResetInitialOffest {
                            initialHeaderOffset = value
                            needResetInitialOffest = false
                        } else {
                            withAnimation(.linear(duration: 0.04)) {
                                scrollScaleFactor = value-initialHeaderOffset > 0 ? value-initialHeaderOffset : 0
                            }
                        }
                    }
                    .listRowSeparator(.hidden)
                }
                .padding(.top, -200)
                .listStyle(.plain)
                .overlay {
                    GeometryReader { geo in
                        AddTaskButton(color: .defaultColor, homeView: self)
                            .padding()
                            .position(x: geo.size.width*0.85, y: geo.size.height-geo.size.width*0.075)
                    }

                }
                .coordinateSpace(name: "scroll")
                .onAppear {
                    UIScrollView.appearance().clipsToBounds = false
                    UIScrollView.appearance().contentInset = UIEdgeInsets(top: 200, left: 0, bottom: 0, right: 0)
                }
                .zIndex(1)
            }
            if showCalendar {
                DateSelectionUI(showView: $showCalendar, taskBeingEdited: $taskBeingEdited, color: .defaultColor, notificationEnabled: taskBeingEdited.isNotificationEnabled)
                    .transition(.opacity)
                    .zIndex(3)
            }
        }
    }
    
    func CompleteTask (task: Task) {
        if mainTaskList.upcomingTasks.contains(task) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(.linear(duration: 0.5)) {
                    mainTaskList.upcomingTasks.remove(at: mainTaskList.upcomingTasks.firstIndex(of: task)!)
                    mainTaskList.completedTasks.insert(task, at: 0)
                }
            }
            task.isCompleted = true
            return
        }
        
        for i in 0..<userTaskLists.taskLists.count {
            if userTaskLists.taskLists[i].upcomingTasks.contains(task) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation(.linear(duration: 0.5)) {
                        userTaskLists.taskLists[i].upcomingTasks.remove(at: userTaskLists.taskLists[i].upcomingTasks.firstIndex(of: task)!)
                        userTaskLists.taskLists[i].completedTasks.insert(task, at: 0)
                    }
                }
                task.isCompleted = true
                return
            }
        }
    }
    
    func CreateNewTask () {
        needResetInitialOffest = true
        withAnimation(.linear(duration: 0.5)) {
            let newTask = Task(name: "")
            mainTaskList.upcomingTasks.insert(newTask, at: 0)
            taskBeingEdited = newTask
        }
    }
    
    func DeleteUpcoming (task: Task) {
        if mainTaskList.upcomingTasks.contains(task) {
            withAnimation(.linear(duration: 0.5)) {
                mainTaskList.upcomingTasks.remove(at: mainTaskList.upcomingTasks.firstIndex(of: task)!)
            }
            return
        }
        
        for i in 0..<userTaskLists.taskLists.count {
            if userTaskLists.taskLists[i].upcomingTasks.contains(task) {
                withAnimation(.linear(duration: 0.5)) {
                    userTaskLists.taskLists[i].upcomingTasks.remove(at: userTaskLists.taskLists[i].upcomingTasks.firstIndex(of: task)!)
                }
                return
            }
        }
    }
    
    func DeleteCompleted (task: Task) {
        if mainTaskList.completedTasks.contains(task) {
            withAnimation(.linear(duration: 0.5)) {
                mainTaskList.completedTasks.remove(at: mainTaskList.completedTasks.firstIndex(of: task)!)
            }
            return
        }
        for i in 0..<userTaskLists.taskLists.count {
            if userTaskLists.taskLists[i].completedTasks.contains(task) {
                withAnimation(.linear(duration: 0.5)) {
                    userTaskLists.taskLists[i].completedTasks.remove(at: userTaskLists.taskLists[i].completedTasks.firstIndex(of: task)!)
                }
                return
            }
        }
    }
    
    func StopEditingTasks () {
        taskBeingEdited = Task(name: "", dateAssigned: Date.now)
        UIApplication.shared.endEditing()
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(mainTaskList: TaskList(name: "Main", primaryColor: .defaultColor, upcomingTasks: [Task(name: "Main task")]), userTaskLists: TaskListContainer())
    }
}
