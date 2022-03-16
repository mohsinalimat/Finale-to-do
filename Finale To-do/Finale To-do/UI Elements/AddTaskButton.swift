//
//  FinaleDivider.swift
//  Finale To-do
//
//  Created by Grant Oganan on 3/14/22.
//

import SwiftUI

struct AddTaskButton: View {
    
    var color: Color
    var radius: CGFloat = 40
    
    var body: some View {
        Circle()
            .fill(color)
            .padding()
            .frame(width: radius*2, height: radius*2, alignment: .center)
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: radius*0.1, height: radius*0.7, alignment: .center)
                    .foregroundColor(.white)
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: radius*0.7, height: radius*0.1, alignment: .center)
                    .foregroundColor(.white)
            }
            .shadow(radius: 10)
            .opacity(1)
    }
}

struct AddTaskButton_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskButton(color: .cyan)
    }
}
