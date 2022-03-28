//
//  SideBarView.swift
//  Finale To-do
//
//  Created by Grant Oganan on 3/15/22.
//

import SwiftUI

struct SideMenuView: View {
    let sideMenuWidth: CGFloat
    
    var allTaskList = TaskList(name: "Home", primaryColor: .defaultColor, systemIcon: "house.fill")
    
    @ObservedObject var mainTaskList: TaskList
    @ObservedObject var userTaskLists: TaskListContainer
    @Binding var currentListIndex: Int
    
    var appView: AppView?
    
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    Text("Home")
                        .font(.system(size: 22))
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.horizontal)
                        .padding(.top, UIScreen.main.bounds.height * 0.0725)
                        .foregroundColor(.white)
                    
                    CategoryView(taskList: allTaskList, index: 0, currentListIndex: $currentListIndex)
                        .onTapGesture {
                            appView?.SelectList(ID: 0)
                        }
                        .frame(height: UIScreen.main.bounds.height*0.06)
                        .padding(.horizontal)
                    
                    
                    Text("Lists")
                        .font(.system(size: 22))
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.horizontal)
                        .padding(.top)
                        .foregroundColor(.white)
                }
                .zIndex(2)
                .background(Color.defaultColor.thirdColor)
                
                ScrollView {
                    VStack (spacing: 0) {
                        CategoryView(taskList: mainTaskList, index: 1, currentListIndex: $currentListIndex)
                            .onTapGesture {
                                appView?.SelectList(ID: 1)
                            }
                        ForEach(0..<userTaskLists.taskLists.count) { i in
                            CategoryView(taskList: userTaskLists.taskLists[i], index: i+2, currentListIndex: $currentListIndex)
                                .onTapGesture {
                                    appView?.SelectList(ID: i+2)
                                }
                        }
                    }
                }
                .zIndex(0)
                .padding(.horizontal)

                HStack {
                    Button(action: {
                        
                    }, label: {
                        Label("Add list", systemImage: "plus")
                            .foregroundColor(.white)
                            .padding(.all, 14)
                    })
                    
                    Spacer()
                    
                    Button(action: {
                        
                    }, label: {
                        Image(systemName: "gearshape")
                            .foregroundColor(.white)
                            .padding(.all, 14)
                    })
                }
                .zIndex(1)
                .padding()
                .background(Color.defaultColor.thirdColor)
            }
            .background(Color.defaultColor.thirdColor)
            .frame(width: sideMenuWidth)
        }
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
                   Image(systemName: taskList.systemIcon)
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
        SideMenuView(sideMenuWidth: UIScreen.main.bounds.width * 0.8, mainTaskList: TaskList(name: "Main", primaryColor: .defaultColor), userTaskLists: TaskListContainer(), currentListIndex: .constant(0), appView: nil)
    }
}
