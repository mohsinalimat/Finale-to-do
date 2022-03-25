//
//  ContentView.swift
//  Finale To-do
//
//  Created by Grant Oganan on 3/12/22.
//

import SwiftUI

struct AppView: View {
    @GestureState private var dragGestureActive: Bool = false
    @State var blockSideMenu = false
    let openSideMenuThreashold = UIScreen.main.bounds.width * 0.2
    let sideMenuWidth = UIScreen.main.bounds.width * 0.8
    
    @State var isSideMenuOpen = false
    @State var xOffset: CGFloat = 0
    
    @State var mainTaskList = TaskList(name: "Main", primaryColor: .defaultColor)
    @State var userTaskLists = [TaskList(name: "Work", primaryColor: .red, upcomingTasks: [Task(name: "Yollo"), Task(name: "Yollo2")], completedTasks: [Task(name: "Yollo"), Task(name: "Yollo2")]), TaskList(name: "Home", primaryColor: .cyan, upcomingTasks: [Task(name: "Die")])]
    
    @State var currentListIndex = 0
    
    var body: some View {
        ZStack {
            SideMenuView(sideMenuWidth: sideMenuWidth, mainTaskList: $mainTaskList, userTaskLists: $userTaskLists, currentListIndex: $currentListIndex, appView: self)
                .offset(x: -0.5*(UIScreen.main.bounds.width-sideMenuWidth))
            
            TaskListView(taskList: currentListIndex <= 1 ? $mainTaskList : $userTaskLists[currentListIndex-2], appView: self)
                .offset(x: xOffset)
                .opacity(currentListIndex == 0 ? 0 : 1)
                .gesture(
                    DragGesture()
                        .updating($dragGestureActive) { value, state, transaction in
                            state = true
                        }
                        .onChanged { value in
                            OnDragChanged(value: value)
                        }
                        .onEnded { value in
                            OnDragEnded(value: value)
                        })
                .onChange(of: dragGestureActive) { newIsActiveValue in
                        if newIsActiveValue == false {
                            OnDragCancelled()
                        }
                    }
            
            MainView(mainTaskList: $mainTaskList, userTaskLists: $userTaskLists, appView: self)
                .offset(x: xOffset)
                .opacity(currentListIndex == 0 ? 1 : 0)
                .gesture(
                    DragGesture()
                        .updating($dragGestureActive) { value, state, transaction in
                            state = true
                        }
                        .onChanged { value in
                            OnDragChanged(value: value)
                        }
                        .onEnded { value in
                            OnDragEnded(value: value)
                        })
                .onChange(of: dragGestureActive) { newIsActiveValue in
                        if newIsActiveValue == false {
                            OnDragCancelled()
                        }
                    }
        }
    }
    
    func OnDragChanged (value: DragGesture.Value) {
        if blockSideMenu { return }
        
        withAnimation(.linear(duration: 0.03)) {
            self.xOffset = max(0, min(sideMenuWidth, (!isSideMenuOpen ? 0 : sideMenuWidth) + value.translation.width))
        }
    }
    
    func OnDragEnded (value: DragGesture.Value) {
        if blockSideMenu { return }
        
        if !isSideMenuOpen {
            if value.translation.width > openSideMenuThreashold {
                OpenSideMenu()
            } else {
                CloseSideMenu()
            }
        } else {
            if value.translation.width < -openSideMenuThreashold*0.5 {
                CloseSideMenu()
            } else {
                OpenSideMenu()
            }
        }
    }
    
    func OnDragCancelled () {
        if !isSideMenuOpen {
            CloseSideMenu()
        } else {
            OpenSideMenu()
        }
    }
    
    func OpenSideMenu() {
        if blockSideMenu { return }
        
        withAnimation (.easeOut(duration: 0.2)) {
            xOffset = sideMenuWidth
        }
        isSideMenuOpen = true
    }
    func CloseSideMenu () {
        if blockSideMenu { return }
        
        withAnimation (.easeOut(duration: 0.2)) {
            xOffset = 0
        }
        isSideMenuOpen = false
    }
    
    func SelectList(ID: Int) {
        currentListIndex = ID
        CloseSideMenu()
    }
}

class TaskList: Identifiable, Equatable {
    static func == (lhs: TaskList, rhs: TaskList) -> Bool {
        return
            lhs.name == rhs.name &&
            lhs.primaryColor == rhs.primaryColor &&
            lhs.upcomingTasks == rhs.upcomingTasks &&
            lhs.completedTasks == rhs.completedTasks
    }
    
    var id = UUID()
    
    var name: String
    var primaryColor: Color
    var systemIcon: String
    var upcomingTasks: [Task]
    var completedTasks: [Task]
    
    init(name: String, primaryColor: Color = Color.defaultColor, systemIcon: String = "folder.fill", upcomingTasks: [Task] = [Task](), completedTasks: [Task] = [Task]()) {
        self.name = name
        self.upcomingTasks = upcomingTasks
        self.systemIcon = systemIcon
        self.completedTasks = completedTasks
        self.primaryColor = primaryColor
    }
}

class Task: Identifiable, Equatable {
    static func == (lhs: Task, rhs: Task) -> Bool {
        return
            lhs.name == rhs.name &&
            lhs.isCompleted == rhs.isCompleted &&
            lhs.dateAssigned == rhs.dateAssigned &&
            lhs.dateCreated == rhs.dateCreated &&
            lhs.dateCompleted == rhs.dateCompleted
    }
    
    var id = UUID()
    
    var name: String
    var isCompleted: Bool
    var isDateAssigned: Bool
    var isNotificationEnabled: Bool
    var dateAssigned: Date
    var dateCreated: Date
    var dateCompleted: Date
    
    init(name: String, isComleted: Bool = false, isDateAssigned: Bool = false, isNotificationEnabled: Bool = false, dateAssigned: Date = Date(timeIntervalSince1970: 0), dateCreated: Date = Date(timeIntervalSince1970: 0), dateCompleted: Date = Date(timeIntervalSince1970: 0)) {
        self.name = name
        self.isCompleted = isComleted
        self.isDateAssigned = isDateAssigned
        self.isNotificationEnabled = isNotificationEnabled
        self.dateAssigned = dateAssigned
        self.dateCreated = dateCreated
        self.dateCompleted = dateCompleted
    }
}

struct UpcomingTaskSlider_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
