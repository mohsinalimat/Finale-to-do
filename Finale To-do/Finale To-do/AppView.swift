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
    
    @StateObject var mainTaskList = TaskList(name: "Main", primaryColor: .defaultColor)
    @StateObject var userTaskLists = TaskListContainer()
    
    @State var currentListIndex = 0
    
    var body: some View {
        ZStack {
            SideMenuView(sideMenuWidth: sideMenuWidth, mainTaskList: mainTaskList, userTaskLists: userTaskLists, currentListIndex: $currentListIndex, appView: self)
                .offset(x: -0.5*(UIScreen.main.bounds.width-sideMenuWidth))
            
            TaskListView(taskList: currentListIndex <= 1 ? mainTaskList : userTaskLists.taskLists[currentListIndex-2], appView: self)
                .offset(x: xOffset)
                .opacity(currentListIndex == 0 ? 0 : 1)
                .disabled(isSideMenuOpen)
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
            
            HomeView(mainTaskList: mainTaskList, userTaskLists: userTaskLists, appView: self)
                .offset(x: xOffset)
                .opacity(currentListIndex == 0 ? 1 : 0)
                .disabled(isSideMenuOpen)
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

class TaskListContainer: ObservableObject {
    @Published var taskLists = [TaskList]()
}

class TaskList: Identifiable, Equatable, ObservableObject {
    static func == (lhs: TaskList, rhs: TaskList) -> Bool {
        return
            lhs.name == rhs.name &&
            lhs.primaryColor == rhs.primaryColor &&
            lhs.upcomingTasks == rhs.upcomingTasks &&
            lhs.completedTasks == rhs.completedTasks
    }
    
    @Published var id = UUID()
    
    @Published var name: String
    @Published var primaryColor: Color
    @Published var systemIcon: String
    @Published var upcomingTasks: [Task]
    @Published var completedTasks: [Task]
    
    init(name: String, primaryColor: Color = Color.defaultColor, systemIcon: String = "folder.fill", upcomingTasks: [Task] = [Task](), completedTasks: [Task] = [Task]()) {
        self.name = name
        self.upcomingTasks = upcomingTasks
        self.systemIcon = systemIcon
        self.completedTasks = completedTasks
        self.primaryColor = primaryColor
    }
}

class Task: Identifiable, Equatable, ObservableObject {
    static func == (lhs: Task, rhs: Task) -> Bool {
        return
            lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.isCompleted == rhs.isCompleted &&
            lhs.dateAssigned == rhs.dateAssigned &&
            lhs.dateCreated == rhs.dateCreated &&
            lhs.dateCompleted == rhs.dateCompleted
    }
    
    @Published var id = UUID()
    
    @Published var name: String
    @Published var isCompleted: Bool
    @Published var isDateAssigned: Bool
    @Published var isNotificationEnabled: Bool
    @Published var dateAssigned: Date
    @Published var dateCreated: Date
    @Published var dateCompleted: Date
    
    init () {
        self.id = UUID()
        self.name = ""
        self.isCompleted = false
        self.isDateAssigned = false
        self.isNotificationEnabled = false
        self.dateAssigned = Date(timeIntervalSince1970: 0)
        self.dateCreated = Date(timeIntervalSince1970: 0)
        self.dateCompleted = Date(timeIntervalSince1970: 0)
    }
    
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
