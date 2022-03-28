//
//  DateSelectionUI.swift
//  Finale To-do
//
//  Created by Grant Oganan on 3/21/22.
//

import SwiftUI

struct DateSelectionUI: View {
    
    @Binding var showView: Bool
    @Binding var taskBeingEdited: Task
    var color: Color
    
    @State var notificationEnabled: Bool
    var selectedNotificationTime = Date()
    
    let transitionDuration = 0.15
    
    var body: some View {
        ZStack {
            Rectangle()
                .ignoresSafeArea()
                .background(.ultraThinMaterial)
                .foregroundColor(.black.opacity(0.2))
            ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.5), radius: 20)
                    VStack {
                        DatePicker("", selection: $taskBeingEdited.dateAssigned, displayedComponents: [.date])
                            .datePickerStyle(.graphical)
                            .padding(.horizontal)
                            .padding(.bottom, -50)
                            .accentColor(color)
                        ZStack {
                            HStack {
                                    DatePicker("Notification", selection: $taskBeingEdited.dateAssigned, displayedComponents: [.hourAndMinute])
                                        .datePickerStyle(.graphical)
                                        .accentColor(color)
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(Color(uiColor: .systemGray2))
                                        .onTapGesture {
                                            withAnimation(.linear(duration: transitionDuration)) {
                                                notificationEnabled = false
                                                taskBeingEdited.isNotificationEnabled = false
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
                                        .foregroundColor(Color(uiColor: .systemGray2))
                                    Text("Notification")
                                        .padding(.horizontal)
                                }
                                .frame(width: UIScreen.main.bounds.width*0.32, height: 34)
                                .onTapGesture {
                                    withAnimation(.linear(duration: transitionDuration)) {
                                        notificationEnabled = true
                                        taskBeingEdited.isNotificationEnabled = true
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
                                    withAnimation (.linear(duration: transitionDuration)) {
                                        showView.toggle()
                                        taskBeingEdited.isDateAssigned = false
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
                                    withAnimation (.linear(duration: transitionDuration)) {
                                        showView.toggle()
                                        taskBeingEdited.isDateAssigned = true
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
}

struct DateSelectionUI_Previews: PreviewProvider {
    static var previews: some View {
        DateSelectionUI(showView: .constant(true), taskBeingEdited: .constant(Task(name: "Test")), color: .defaultColor, notificationEnabled: true)
    }
}

