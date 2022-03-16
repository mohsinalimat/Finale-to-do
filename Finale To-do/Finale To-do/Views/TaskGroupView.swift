//
//  TaskGroupView.swift
//  Finale To-do
//
//  Created by Grant Oganan on 3/15/22.
//

import SwiftUI

struct TaskGroupView: View {
    @Binding var taskList: TaskList
    
    var mainView: MainView?
    
    var body: some View {
        NavigationView {
            List {
                Section (header: Text("Upcoming")) {
                    ForEach(taskList.upcomingTasks) { task in
                        UpcomingTaskSlider(task: task, sliderColor: taskList.primaryColor)
                    }
                    .onDelete(perform: deleteUpcoming)
                }.listRowSeparator(.hidden)
                Section (header: Text("Completed")) {
                    ForEach(taskList.completedTasks) { task in
                        CompletedTaskSlider(task: task)
                    }.onDelete(perform: deleteCompleted)
                }.listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .navigationTitle(taskList.name)
            .overlay (alignment: .bottomTrailing) {
                AddTaskButton(color: taskList.primaryColor)
                    .padding(.horizontal)
            }
            .toolbar {
                ToolbarItem (placement: .navigationBarLeading) {
                    Button {
                        if mainView!.isSideMenuOpen { mainView?.CloseSideMenu() }
                        else { mainView?.OpenSideMenu() }
                    } label: {
                        Label("Edit", systemImage: "line.3.horizontal")
                            .foregroundColor(.primary)
                    }
                }
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

struct TaskGroupView_Previews: PreviewProvider {
    static var previews: some View {
        TaskGroupView(taskList: .constant(TaskList(name: "Work")), mainView: nil)
    }
}

