//
//  SettingsView.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/2/22.
//

import SwiftUI

struct SettingsView: View {
    
    @Binding var settings: Settings
    @ObservedObject var userTaskLists: TaskListContainer
    
    @State var panelHeight = 0.0
    @State var showDefaultFolderToolTip = false
    
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


            Text("Settings")
              .multilineTextAlignment(.center)
              .font(.headline)
              .padding(.horizontal)
              .frame(maxWidth: .infinity)
            
            HStack {
                Text("Greeting")
                Spacer()
                TextField("name", text: $settings.userName)
                    .textFieldStyle(GreyTextFieldStyle())
                    .multilineTextAlignment(.center)
                    .frame(width: UIScreen.main.bounds.width*0.4)
            }

            HStack {
                Text("Default folder")
                Button(action: {
                    withAnimation(.easeOut(duration: 0.25)) {
                        showDefaultFolderToolTip.toggle()
                    }
                }, label: {
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(showDefaultFolderToolTip ? .gray : .white)
                })
                    .overlay{
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .foregroundStyle(.ultraThinMaterial)
                            Text("New tasks created from the 'home' page will be added to this folder.")
                                .font(.system(size: 15))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(12)
                        }
                        .frame(width: UIScreen.main.bounds.width*0.6, height: UIScreen.main.bounds.width*0.21)
                        .offset(x: UIScreen.main.bounds.width*0.25, y: -UIScreen.main.bounds.width*0.17)
                        .opacity(showDefaultFolderToolTip ? 1 : 0)
                        .scaleEffect(showDefaultFolderToolTip ? 1 : 0.1)
                    }
                Spacer()
                DefaultFolderPicker(settings: $settings, userTaskLists: userTaskLists)
                    .frame(width: UIScreen.main.bounds.width*0.4)
            }

            HStack {
                Text("Theme")
                Spacer()
                ThemePicker(settings: $settings)
                    .frame(width: UIScreen.main.bounds.width*0.7)
            }
        }
        .foregroundColor(.white)
        .padding()
        .padding(.bottom, 100)
        .background(
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.defaultColor.thirdColor)
                    .onAppear {
                        panelHeight = geo.size.height
                    }
                    .shadow(radius: 10)
            }
        )
        .offset(x: 0, y: 0.5*(UIScreen.main.bounds.height-panelHeight) + (appView?.isSettingsOpen ?? true ? 0 : 1) * (panelHeight+50) )
        .onTapGesture {
            UIApplication.shared.endEditing()
            withAnimation(.easeOut(duration: 0.25)) {
                showDefaultFolderToolTip = false
            }
        }
    }
}

struct DefaultFolderPicker: View {

    @Binding var settings: Settings
    @State var selection = "Main"
    @ObservedObject var userTaskLists: TaskListContainer
    
   var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .frame(height: 30)
                .opacity(0.05)

            Picker("Default folder", selection: $selection) {
                Text("Mainhh")
                ForEach(userTaskLists.taskLists) { i in
                    Text(i.name)
                }
            }
            .pickerStyle(.menu)
        }
    }
}

struct ThemePicker: View {

    @Binding var settings: Settings
    
    init(settings: Binding<Settings>) {
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(.defaultColor)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        
        self._settings = settings
    }

    var body: some View {
        Picker("Theme", selection: $settings.theme) {
            ForEach(Theme.allCases) { theme in
                Text(theme.rawValue.capitalized)
            }
        }
        .pickerStyle(.segmented)
    }
}

class Settings: Codable {
    var userName: String
    var theme: Theme
    var defaultFolder: String
    
    init (userName: String, theme: Theme, defaultFolder: String) {
        self.userName = userName
        self.theme = theme
        self.defaultFolder = defaultFolder
    }
    
    init () {
        self.userName = "Friend"
        self.theme = .system
        self.defaultFolder = "Main"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: SettingstCodingKeys.self)
        userName = try container.decode(String.self, forKey: .userName)
        theme = try container.decode(Theme.self, forKey: .theme)
        defaultFolder = try container.decode(String.self, forKey: .defaultFolder)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: SettingstCodingKeys.self)
        try container.encode(userName, forKey: .userName)
        try container.encode(theme, forKey: .theme)
        try container.encode(defaultFolder, forKey: .defaultFolder)
    }
}

enum SettingstCodingKeys: CodingKey {
    case userName
    case theme
    case defaultFolder
}

enum Theme: String, CaseIterable, Identifiable, Codable {
    case light
    case dark
    case system
    
    var id: Self { self }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let settings = Settings(userName: "Grant", theme: .system, defaultFolder: "Main")
        SettingsView(settings: .constant(settings), userTaskLists: TaskListContainer())
    }
}
