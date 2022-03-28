//
//  FinaleDivider.swift
//  Finale To-do
//
//  Created by Grant Oganan on 3/14/22.
//

import SwiftUI

struct AddTaskButton: View {
    
    var color: Color
    @State var radius: CGFloat = 45
    
    var taskListView: TaskListView?
    var homeView: HomeView?
    
    var body: some View {
        Circle()
            .shadow(radius: 10)
            .foregroundColor(color)
            .padding()
            .frame(width: radius*2, height: radius*2, alignment: .center)
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: radius*0.1, height: radius*0.7, alignment: .center)
                    .foregroundColor(color.lerp(second: .white, percentage: 0.8))
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: radius*0.7, height: radius*0.1, alignment: .center)
                    .foregroundColor(color.lerp(second: .white, percentage: 0.8))
            }
            .onTapGesture {
                taskListView?.CreateNewTask()
                homeView?.CreateNewTask()
            }
    }
}

struct AddTaskButton_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskButton(color: .cyan)
    }
}
