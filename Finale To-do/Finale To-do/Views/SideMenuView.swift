//
//  SideBarView.swift
//  Finale To-do
//
//  Created by Grant Oganan on 3/15/22.
//

import SwiftUI

struct SideMenuView: View {
    let sideMenuWidth: CGFloat
    
    var allTaskList = TaskList(name: "All", primaryColor: .defaultColor)
    
    @Binding var mainTaskList: TaskList
    @Binding var userTaskLists: [TaskList]
    @Binding var currentListIndex: Int
    
    var mainView: MainView?
    
    var body: some View {
        ZStack {
            Color.defaultColor.thirdColor
                .ignoresSafeArea()
            
            GeometryReader { geo in
                ScrollView {
                    VStack (alignment: .leading, spacing: 10) {
                        Spacer().padding(20)
                        CategoryView(taskList: mainTaskList, index: 0, currentListIndex: $currentListIndex)
                            .onTapGesture {
                                mainView?.SelectList(ID: 0)
                            }
                        ForEach(0..<userTaskLists.count) { i in
                            CategoryView(taskList: userTaskLists[i], index: i+1, currentListIndex: $currentListIndex)
                                .onTapGesture {
                                    mainView?.SelectList(ID: i+1)
                                }
                        }
                    }.padding()
                }
            }
        }
        .frame(width: sideMenuWidth)
    }
}

struct CategoryView: View {
    var taskList: TaskList
    var index: Int
    @Binding var currentListIndex: Int

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                   .foregroundColor(getFrameColor(ID: index))
               HStack () {
                   Image(systemName: "folder.fill")
                       .foregroundColor(taskList.primaryColor)
                   Text(taskList.name)
               }
               .frame(maxWidth: .infinity, alignment: .leading)
               .padding(.all, 14)
               .foregroundColor(.white)
        }
    }
    
    func getFrameColor (ID: Int) -> Color {
        return ID == currentListIndex ? Color.defaultColor.secondaryColor : Color.clearInteractive
    }
}

struct SideBarView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuView(sideMenuWidth: UIScreen.main.bounds.width * 0.8, mainTaskList: .constant(TaskList(name: "Main", primaryColor: .defaultColor)), userTaskLists: .constant([TaskList(name: "Work", primaryColor: .red, upcomingTasks: [Task(name: "Yollo"), Task(name: "Yollo2")], completedTasks: [Task(name: "Yollo"), Task(name: "Yollo2")]), TaskList(name: "Home", primaryColor: .cyan, upcomingTasks: [Task(name: "Die")])]), currentListIndex: .constant(0), mainView: nil)
    }
}
