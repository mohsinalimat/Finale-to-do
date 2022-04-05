//
//  AddListView.swift
//  Finale To-do
//
//  Created by Grant Oganan on 3/31/22.
//

import SwiftUI

struct AddListView: View {
    @Binding var isViewOpen: Bool
    @State var newList = TaskList(name: "", primaryColor: Color.red, systemIcon: "folder.fill")
    @State var listName = ""
    @State var updater = 0
    @State var panelHeight = 0.0
    
    let swatchSize: CGFloat = UIScreen.main.bounds.width*0.09
    
    let icons: [String] = ["folder.fill", "book.closed.fill", "heart.fill", "paperplane.fill", "calendar", "rectangle.fill.on.rectangle.fill", "trash.fill", "alarm.fill", "hourglass", "bolt.fill", "person.fill", "bag.fill", "tray.full.fill", "archivebox.fill", "graduationcap.fill", "briefcase.fill"]
    
    let colors: [Color] = [Color.red, Color.blue, Color.defaultColor, Color.cyan, Color.yellow, Color.black, Color.green, Color.white, Color.red, Color.blue, Color.defaultColor, Color.cyan, Color.yellow, Color.black, Color.green, Color.white]
    
    let placeholders: [String] = ["Work", "Family", "Sports club", "Hobbies", "Home", "Shopping list"]
    @State var randomPlaceholder = 0
    
    var appView: AppView?
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
              Spacer()
              RoundedRectangle(cornerRadius: 20)
                  .fill(Color.defaultColor.secondaryColor)
                  .frame(width: UIScreen.main.bounds.width*0.13, height: 3)
              Spacer()
            }
            .onAppear {
                randomPlaceholder = Int.random(in: 0..<placeholders.count)
            }
            .onChange(of: isViewOpen) { i in
                if i { OnAppear() }
            }


            Text("Create new list")
              .multilineTextAlignment(.center)
              .font(.headline)
              .padding(.horizontal)
              .frame(maxWidth: .infinity)

            Text("Title")
            TextField(placeholders[randomPlaceholder], text: $listName)
              .textFieldStyle(GreyTextFieldStyle())

            Text("Color")
            VStack {
                ForEach (0..<2) { rows in
                    HStack {
                        ForEach (0..<8) { columns in
                            ColorSwatch(color: colors[rows*8+columns], swatchSize: swatchSize, listColor: $newList.primaryColor, updater: $updater)
                            Spacer()
                        }
                    }
                }
            }


            Text("Icon")
            VStack {
                ForEach (0..<2) { rows in
                    HStack {
                        ForEach (0..<8) { columns in
                            IconSwatch(icon: icons[rows*8+columns], swatchSize: swatchSize, listIcon: $newList.systemIcon, updater: $updater)
                            Spacer()
                        }
                    }
                }
            }

            HStack {
                Button(
                  action: {
                      CloseView()
                  },
                  label: {
                      ZStack {
                          RoundedRectangle(cornerRadius: 6)
                              .foregroundColor(Color(uiColor: .systemGray2))
                          Text("Cancel")
                              .foregroundColor(.white)
                      }
                      .frame(height: 40, alignment: .center)
                  })
                Button(
                  action: {
                      CreateNewList()
                  },
                  label: {
                      ZStack {
                          RoundedRectangle(cornerRadius: 6)
                              .foregroundColor(.defaultColor)
                          Text("Confirm")
                              .foregroundColor(.white)
                      }
                      .frame(height: 40, alignment: .center)
                  })
                    .opacity(listName.isEmpty ? 0.5 : 1)
                    .disabled(listName.isEmpty)
            }
            .padding(.top, 20)
        }
        .foregroundColor(.white)
        .padding()
        .padding(.bottom, 50)
        .background(
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.defaultColor.thirdColor)
                    .onAppear {
                        panelHeight = geo.size.height
                        OnAppear()
                    }
                    .shadow(radius: 10)
            }
        )
        .offset(x: 0, y: 0.5*(UIScreen.main.bounds.height-panelHeight) + (appView?.isAddListOpen ?? true ? 0 : 1) * panelHeight)
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
    
    func CreateNewList () {
        newList.name = listName
        appView?.userTaskLists.taskLists.append(newList)
        CloseView()
    }
    
    func OnAppear() {
        newList = TaskList(name: "", primaryColor: Color.red, systemIcon: "folder")
        listName = ""
    }
    
    func CloseView () {
        withAnimation(.easeOut(duration: 0.2)) {
            appView?.isAddListOpen = false
            listName = ""
        }
        UIApplication.shared.endEditing()
    }
}

struct ColorSwatch: View {
    var color: Color
    var swatchSize: CGFloat
    @Binding var listColor: Color
    @Binding var updater: Int
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: swatchSize, height: swatchSize)
            .overlay {
                if listColor == color {
                    Circle()
                        .strokeBorder(Color.defaultColor.thirdColor, lineWidth: 4)
                    Circle()
                        .strokeBorder(Color.white, lineWidth: 2)
                }
            }
            .onTapGesture {
                listColor = color
                updater += 1
                UIApplication.shared.endEditing()
            }
            .onChange(of: updater) { i in }
    }
}

struct IconSwatch: View {
    var icon: String
    var swatchSize: CGFloat
    @Binding var listIcon: String
    @Binding var updater: Int
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.defaultColor)
//                .fill(Color(uiColor: UIColor.systemGray2))
                .overlay {
                    if listIcon == icon {
                        Circle()
                            .strokeBorder(Color.defaultColor.thirdColor, lineWidth: 5)
                        Circle()
                            .strokeBorder(Color.white, lineWidth: 2)
                    }
                }
                .onTapGesture {
                    listIcon = icon
                    updater += 1
                    UIApplication.shared.endEditing()
                }
                .onChange(of: updater) { i in }
            Image(systemName: icon)
        }
        .frame(width: swatchSize, height: swatchSize)
    }
}

struct GreyTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(8)
            .background(Color.defaultColor.secondaryColor)
            .cornerRadius(10)
            .foregroundColor(.white)
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct AddListView_Previews: PreviewProvider {
    static var previews: some View {
        AddListView(isViewOpen: .constant(true))
    }
}
