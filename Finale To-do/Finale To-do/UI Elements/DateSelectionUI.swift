//
//  DateSelectionUI.swift
//  Finale To-do
//
//  Created by Grant Oganan on 3/21/22.
//

import SwiftUI

struct DateSelectionUI: View {
    
    @Binding var showView: Bool
    @Binding var task: Task
    @Binding var color: Color
    
    @State var notificationEnabled: Bool
    var selectedNotificationTime = Date()
    
    var body: some View {
          ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(.ultraThinMaterial)
                    .shadow(color: .black, radius: 20)
                VStack {
                    DatePicker("", selection: $task.dateAssigned, displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                        .padding(.horizontal)
                        .padding(.bottom, -50)
                        .accentColor(color)
                    ZStack {
                        HStack {
                                DatePicker("Notification", selection: $task.dateAssigned, displayedComponents: [.hourAndMinute])
                                    .datePickerStyle(.graphical)
                                    .accentColor(color)
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Color(uiColor: .systemGray4))
                                    .onTapGesture {
                                        withAnimation(.linear(duration: 0.2)) {
                                            notificationEnabled = false
                                            task.isNotificationEnabled = false
                                        }
                                    }
                            }
                            .padding(.horizontal)
                            .disabled(!notificationEnabled)
                            .opacity(notificationEnabled ? 1 : 0)
                        HStack {
                            Spacer()
                            ZStack () {
                                RoundedRectangle(cornerRadius: 6)
                                    .foregroundColor(Color(uiColor: .systemGray4))
                                Text("Notification")
                                    .padding(.horizontal)
                            }
                            .frame(width: UIScreen.main.bounds.width*0.32, height: 34)
                            .onTapGesture {
                                withAnimation(.linear(duration: 0.2)) {
                                    notificationEnabled = true
                                    task.isNotificationEnabled = true
                                }
                            }
                        }
                        .padding(.horizontal)
                        .opacity(notificationEnabled ? 0 : 1)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Button(
                            action: {
                                withAnimation (.linear(duration: 0.2)) {
                                    showView.toggle()
                                    task.isDateAssigned = false
                                }
                            },
                            label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 6)
                                        .foregroundColor(Color(uiColor: .systemGray2))
                                    Text("Clear")
                                        .foregroundColor(.white)
                                }
                                .frame(height: 30, alignment: .center)
                            })
                                                
                        Button(
                            action: {
                                withAnimation (.linear(duration: 0.2)) {
                                    showView.toggle()
                                    task.isDateAssigned = true
                                }
                            },
                            label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 6)
                                        .foregroundColor(color)
                                    Text("Confirm")
                                        .foregroundColor(.white)
                                }
                                .frame(height: 30, alignment: .center)
                            })
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    .padding(.top, -20)
                    
                }
            }
            .frame(width: UIScreen.main.bounds.width*0.8, height: UIScreen.main.bounds.width, alignment: .center)
    }
}

struct DateSelectionUI_Previews: PreviewProvider {
    static var previews: some View {
        DateSelectionUI(showView: .constant(true), task: .constant(Task(name: "Test")), color: .constant(.defaultColor), notificationEnabled: true)
    }
}

