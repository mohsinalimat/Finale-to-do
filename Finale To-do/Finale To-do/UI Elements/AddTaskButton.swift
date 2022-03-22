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
    
    var body: some View {
        Circle()
            .shadow(radius: 10)
            .foregroundColor(color)
//            .foregroundStyle(.ultraThinMaterial)
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
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ value in
                        withAnimation(.easeOut(duration: 0.07)) {
                            self.radius = 40
                        }
                    })
                    .onEnded( { value in
                        withAnimation(.easeOut(duration: 0.07)) {
                            self.radius = 45
                        }
                    })
            )
            
    }
}

struct AddTaskButton_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskButton(color: .cyan)
    }
}
