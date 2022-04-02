//
//  ContentView.swift
//  Finale To-do
//
//  Created by Grant Oganan on 3/12/22.
//

import SwiftUI

struct AppView: View {
    @Environment(\.scenePhase) var scenePhase
    
    @State var userName: String = ""
    
    @State var blockSideMenu = false
    let openSideMenuThreashold = UIScreen.main.bounds.width * 0.2
    let sideMenuWidth = UIScreen.main.bounds.width * 0.8
    
    @State var isSideMenuOpen = false
    @State var xOffset: CGFloat = 0
    
    @State var isAddListOpen = false
    @State var addListYOffset: CGFloat = 0
    
    @State var isSettingsOpen = false
    @State var settingsYOffset: CGFloat = 0
    
    @StateObject var mainTaskList = TaskList(name: "Main", primaryColor: .defaultColor)
    @StateObject var userTaskLists = TaskListContainer()
    
    @State var currentListIndex = 0
    
    @State var settings: Settings = Settings()
    
    var body: some View {
        ZStack {
            SideMenuView(sideMenuWidth: sideMenuWidth, mainTaskList: mainTaskList, userTaskLists: userTaskLists, currentListIndex: $currentListIndex, appView: self)
                .offset(x: -0.5*(UIScreen.main.bounds.width-sideMenuWidth))
                .onAppear {
                    LoadData()
                }
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .inactive || newPhase == .background {
                        SaveData()
                    }
                }
            
            TaskListView(taskList: currentListIndex <= 1 ? mainTaskList : userTaskLists.taskLists[currentListIndex-2], appView: self)
                .offset(x: xOffset)
                .opacity(currentListIndex == 0 ? 0 : 1)
                .overlay {
                    DragRectangle(xOffset: $xOffset, isSideMenuOpen: $isSideMenuOpen, appView: self)
                }
            
            HomeView(userName: $settings.userName, mainTaskList: mainTaskList, userTaskLists: userTaskLists, appView: self)
                .offset(x: xOffset)
                .opacity(currentListIndex == 0 ? 1 : 0)
                .overlay {
                    DragRectangle(xOffset: $xOffset, isSideMenuOpen: $isSideMenuOpen, appView: self)
                }
            
            Rectangle()
                .fill(Color.black)
                .ignoresSafeArea()
                .opacity(isAddListOpen || isSettingsOpen ? 0.5 : 0)
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.2)) {
                        self.addListYOffset = 0
                        isAddListOpen = false
                        
                        if isSettingsOpen { SaveSettings() }
                        self.settingsYOffset = 0
                        isSettingsOpen = false
                    }
                    UIApplication.shared.endEditing()
                }
            
            AddListView (appView: self)
                .offset(x: 0, y: addListYOffset)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            withAnimation(.linear(duration: 0.03)) {
                                self.addListYOffset = max(0, value.translation.height)
                            }
                        }
                        .onEnded { value in
                            if value.translation.height <= UIScreen.main.bounds.height*0.2 {
                                withAnimation(.linear(duration: 0.25)) {
                                    self.addListYOffset = 0
                                }
                            } else {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    self.addListYOffset = 0
                                    isAddListOpen = false
                                }
                            }
                        }
                )
            
            SettingsView(settings: $settings, userTaskLists: userTaskLists, appView: self)
                .offset(x: 0, y: settingsYOffset)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            withAnimation(.linear(duration: 0.03)) {
                                self.settingsYOffset = max(0, value.translation.height)
                            }
                        }
                        .onEnded { value in
                            if value.translation.height <= UIScreen.main.bounds.height*0.1 {
                                withAnimation(.linear(duration: 0.25)) {
                                    self.settingsYOffset = 0
                                }
                            } else {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    SaveSettings()
                                    self.settingsYOffset = 0
                                    isSettingsOpen = false
                                }
                            }
                        }
                )
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
    
    func SaveSettings () {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: "FINALE_DEV_APP_settings")
        }
    }
    
    func LoadData () {
        if let data = UserDefaults.standard.data(forKey: "FINALE_DEV_APP_mainUpcomingTasks") {
                if let decoded = try? JSONDecoder().decode([Task].self, from: data) {
                    mainTaskList.upcomingTasks = decoded
                }
            }
        if let data = UserDefaults.standard.data(forKey: "FINALE_DEV_APP_mainCompletedTasks") {
                if let decoded = try? JSONDecoder().decode([Task].self, from: data) {
                    mainTaskList.completedTasks = decoded
                }
            }
        if let data = UserDefaults.standard.data(forKey: "FINALE_DEV_APP_userTaskLists") {
                if let decoded = try? JSONDecoder().decode([TaskList].self, from: data) {
                    userTaskLists.taskLists = decoded
                }
            }
        if let data = UserDefaults.standard.data(forKey: "FINALE_DEV_APP_settings") {
                if let decoded = try? JSONDecoder().decode(Settings.self, from: data) {
                    settings = decoded
                }
            }
    }
    
    func SaveData () {
        if let encoded = try? JSONEncoder().encode(mainTaskList.upcomingTasks) {
            UserDefaults.standard.set(encoded, forKey: "FINALE_DEV_APP_mainUpcomingTasks")
        }
        if let encoded = try? JSONEncoder().encode(mainTaskList.completedTasks) {
            UserDefaults.standard.set(encoded, forKey: "FINALE_DEV_APP_mainCompletedTasks")
        }
        if let encoded = try? JSONEncoder().encode(userTaskLists.taskLists) {
            UserDefaults.standard.set(encoded, forKey: "FINALE_DEV_APP_userTaskLists")
        }
    }
}

struct DragRectangle: View {
    @Binding var xOffset: CGFloat
    @Binding var isSideMenuOpen: Bool
    @GestureState private var dragGestureActive: Bool = false
    
    var appView: AppView?
    
    var body: some View {
        Rectangle()
            .ignoresSafeArea()
            .foregroundColor(.clearInteractive)
            .offset(x: -UIScreen.main.bounds.width*0.5 + xOffset + (isSideMenuOpen ? UIScreen.main.bounds.width*0.25 : 0), y: UIScreen.main.bounds.height*0.1)
            .frame(width: UIScreen.main.bounds.width*(0.05 + (isSideMenuOpen ? 0.5 : 0)), height: UIScreen.main.bounds.height*0.8)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($dragGestureActive) { value, state, transaction in
                        state = true
                    }
                    .onChanged { value in
                        appView?.OnDragChanged(value: value)
                    }
                    .onEnded { value in
                        appView?.OnDragEnded(value: value)
                    })
            .onChange(of: dragGestureActive) { newIsActiveValue in
                    if newIsActiveValue == false {
                        appView?.OnDragCancelled()
                    }
                }
    }
}

class TaskListContainer: ObservableObject {
    @Published var taskLists = [TaskList]()
}

class TaskList: Identifiable, Equatable, ObservableObject, Codable {
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
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TaskListCodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        upcomingTasks = try container.decode([Task].self, forKey: .upcomingTasks)
        systemIcon = try container.decode(String.self, forKey: .systemIcon)
        completedTasks = try container.decode([Task].self, forKey: .completedTasks)
        primaryColor = try container.decode(Color.self, forKey: .primaryColor)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: TaskListCodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(upcomingTasks, forKey: .upcomingTasks)
        try container.encode(systemIcon, forKey: .systemIcon)
        try container.encode(completedTasks, forKey: .completedTasks)
        try container.encode(primaryColor, forKey: .primaryColor)
    }
}

class Task: Identifiable, Equatable, ObservableObject, Codable {
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
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TaskCodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        isDateAssigned = try container.decode(Bool.self, forKey: .isDateAssigned)
        isNotificationEnabled = try container.decode(Bool.self, forKey: .isNotificationEnabled)
        dateAssigned = try container.decode(Date.self, forKey: .dateAssigned)
        dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        dateCompleted = try container.decode(Date.self, forKey: .dateCompleted)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: TaskCodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(isDateAssigned, forKey: .isDateAssigned)
        try container.encode(isNotificationEnabled, forKey: .isNotificationEnabled)
        try container.encode(dateAssigned, forKey: .dateAssigned)
        try container.encode(dateCreated, forKey: .dateCreated)
        try container.encode(dateCompleted, forKey: .dateCompleted)
    }
}

enum TaskCodingKeys: CodingKey {
    case name
    case isCompleted
    case isDateAssigned
    case isNotificationEnabled
    case dateAssigned
    case dateCreated
    case dateCompleted
}
enum TaskListCodingKeys: CodingKey {
    case name
    case upcomingTasks
    case systemIcon
    case completedTasks
    case primaryColor
}

struct UpcomingTaskSlider_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
