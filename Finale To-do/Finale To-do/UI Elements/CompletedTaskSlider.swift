//
//  TaskSlider.swift
//  Finale To-do
//
//  Created by Grant Oganan on 3/14/22.
//

import SwiftUI

struct CompletedTaskSlider: View {
    @State var task: Task
    
    let sliderHeight = UIScreen.main.bounds.height * 0.04
    let sliderColor = Color.clear //Color(uiColor: UIColor.systemGray6)
    let cornerRadius: CGFloat = 10
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(sliderColor)
                    .cornerRadius(cornerRadius)
                    .frame(height: sliderHeight)
                Text(task.name)
                    .strikethrough()
                    .padding(.horizontal, geometry.size.width*0.02)
                    .frame(height: sliderHeight, alignment: .leading)
                    .foregroundColor(Color(uiColor: .systemGray2))
                Text(assignedDateString)
                    .strikethrough()
                    .padding(.horizontal, geometry.size.width*0.02)
                    .frame(height: sliderHeight, alignment: .trailing)
                    .foregroundColor(Color(uiColor: UIColor.systemGray))
            }
        }
        .frame(height: sliderHeight)
    }
    
    var assignedDateString: String {
        if task.dateAssigned == Date(timeIntervalSince1970: 0) {
            return ""
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: task.dateAssigned)
    }
}

struct CompletedTaskSlider_Preview: PreviewProvider {
    static var previews: some View {
        CompletedTaskSlider(task: Task(name: "Title"))
    }
}

