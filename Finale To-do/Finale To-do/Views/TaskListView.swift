//
//  TaskGroupView.swift
//  Finale To-do
//
//  Created by Grant Oganan on 3/15/22.
//

import SwiftUI

struct TaskListView: View {
    @Binding var taskList: TaskList
    
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
            
            VStack (spacing: 0) {
                ZStack (alignment: .leading) {
                    Rectangle()
                        .ignoresSafeArea()
                        .foregroundStyle(.ultraThinMaterial)
                        .colorMultiply(taskList.primaryColor)
                        .frame(height: UIScreen.main.bounds.height*0.15)
                        .scaleEffect(y: 1+(scrollScaleFactor/(UIScreen.main.bounds.height*0.15)), anchor: UnitPoint(x: 0, y: 0))
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
                            .font(.system(size: 40 + scrollScaleFactor/30))
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .offset(y: scrollScaleFactor)
                            .foregroundColor(.white)
                    }
                }.zIndex(2)
                
                
                List {
                    Section (header: Text("Upcoming")) {
                        ForEach(taskList.upcomingTasks) { task in
                            UpcomingTaskSlider(task: task, isPickingDate: $showCalendar, taskBeingEdited: $taskBeingEdited, sliderColor: taskList.primaryColor)
                        }
                        .onDelete(perform: deleteUpcoming)
                    }
                    .listRowSeparator(.hidden)
                    Section (header: Text("Completed")) {
                        ForEach(taskList.completedTasks) { task in
                            CompletedTaskSlider(task: task, sliderColor: taskList.primaryColor.secondaryColor)
                        }
                        .onDelete(perform: deleteCompleted)
                    }
                    .listRowSeparator(.hidden)
                    .onChange(of: taskList) { newVal in
                        needResetInitialOffest = true
                    }
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
                        AddTaskButton(color: taskList.primaryColor)
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
                DateSelectionUI(showView: $showCalendar, task: $taskBeingEdited, color: taskList.primaryColor, notificationEnabled: taskBeingEdited.isNotificationEnabled)
                    .transition(.opacity)
                    .zIndex(3)
            }
        }
    }
    
    func deleteUpcoming(at offsets: IndexSet) {
        taskList.upcomingTasks.remove(atOffsets: offsets)
    }
    func deleteCompleted(at offsets: IndexSet) {
        taskList.completedTasks.remove(atOffsets: offsets)
    }
}

struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        TaskListView(taskList: .constant(TaskList(name: "Home", primaryColor: .cyan, upcomingTasks: [Task(name: "Die")])), appView: nil)
    }
}

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

