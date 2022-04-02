//
//  UndoButton.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/2/22.
//

import SwiftUI

struct UndoButton: View {
    @Environment(\.colorScheme) var colorScheme
    
    var color: Color
    @State var radius: CGFloat = 40
    
    var taskListView: TaskListView?
    var homeView: HomeView?
    
    var body: some View {
        ZStack {
            Circle()
                .foregroundStyle(.ultraThinMaterial)
            Circle()
                .foregroundColor(color.opacity(colorScheme == .light ? 1 : 0.8))
                .blendMode(colorScheme == .light ? .multiply : .screen)
            Image(systemName: "arrow.uturn.left")
                .foregroundColor(color.lerp(second: .white, percentage: 0.8))
                .font(Font.system(size: 20, weight: .bold))
        }
        .shadow(radius: 10)
        .padding()
        .frame(width: radius*2, height: radius*2, alignment: .center)
        .onTapGesture {
            taskListView?.UndoTask()
//            homeView?.UndoTask()
        }
        
    }
}

struct UndoButton_Previews: PreviewProvider {
    static var previews: some View {
        UndoButton(color: .cyan)
    }
}

