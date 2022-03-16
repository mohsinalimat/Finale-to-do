//
//  SideBarView.swift
//  Finale To-do
//
//  Created by Grant Oganan on 3/15/22.
//

import SwiftUI

struct SideMenuView: View {
    let sideMenuWidth: CGFloat
    
    @Binding var allTaskLists: [TaskList]
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
                        ForEach(0..<allTaskLists.count) { i in
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundColor(getFrameColor(ID: i))
                                HStack () {
                                    Image(systemName: "folder.fill")
                                        .foregroundColor(allTaskLists[i].primaryColor)
                                    Text(allTaskLists[i].name)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.all, 14)
                                .foregroundColor(.white)
                            }.onTapGesture {
                                mainView?.SelectList(ID: i)
                            }
                        }
                    }.padding()
                }
            }
        }
        .frame(width: sideMenuWidth)
    }
    
    func getFrameColor (ID: Int) -> Color {
        return ID == currentListIndex ? Color.defaultColor.secondaryColor : Color.clearInteractive
    }
}

struct SideBarView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuView(sideMenuWidth: UIScreen.main.bounds.width * 0.8, allTaskLists: .constant([TaskList(name: "Work", primaryColor: .red), TaskList(name: "Home", primaryColor: .cyan)]), currentListIndex: .constant(0), mainView: nil)
    }
}
