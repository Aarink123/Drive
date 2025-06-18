//
//  StudentMainTabView.swift
//  DriveQuest
//
//  Created by Aarin Karamchandani on 6/18/25.
//


import SwiftUI

struct StudentMainTabView: View {
    let username: String

    private let deepBlue = Color(red: 23/255, green: 77/255, blue: 133/255)
    private let secondaryBlue = Color(red: 40/255, green: 91/255, blue: 144/255)

    init(username: String) {
        self.username = username
        
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = UIColor(secondaryBlue)
        appearance.stackedLayoutAppearance.normal.iconColor = .lightGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.lightGray]
        
        appearance.stackedLayoutAppearance.selected.iconColor = .white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView {
            // Dashboard Tab
            StudentDashboardView(username: username)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Dashboard")
                }
            
            // Courses Tab
            CoursesView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Courses")
                }

            // History Tab
            StudentHistoryView()
                .tabItem {
                    Image(systemName: "list.star")
                    Text("History")
                }

            // Settings Tab
            StudentSettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
        .accentColor(.white)
    }
}


// MARK: - Student-Specific Tab Views

struct StudentHistoryView: View {
    @EnvironmentObject var appData: AppData
    
    private var student: Kid? {
        appData.kids.first { $0.name == "Aarin" } ?? appData.kids.first
    }
    
    var body: some View {
        if let student = student {
            // Re-uses the DriveHistoryMasterView from the parent's side
            DriveHistoryMasterView(driveHistory: student.driveHistory)
        } else {
            Text("Could not load student data.")
        }
    }
}


struct StudentSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showingSignOutAlert = false
    
    // Preference states
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = true

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account")) {
                    HStack {
                        Text("Username")
                        Spacer()
                        Text("TeenLogin").foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Name")
                        Spacer()
                        Text("Aarin").foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Preferences")) {
                    Toggle("Driving Tip Notifications", isOn: $notificationsEnabled)
                    Toggle("Use Dark Mode", isOn: $darkModeEnabled)
                }
                
                Section(header: Text("Support")) {
                    Button("Help & FAQ") {}
                    Button("Contact Support") {}
                }
                
                Section {
                    Button(role: .destructive) {
                        showingSignOutAlert = true
                    } label: {
                        Text("Sign Out")
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Sign Out", isPresented: $showingSignOutAlert) {
                Button("Sign Out", role: .destructive) {
                    // This will dismiss the entire student view stack
                    // In a real app, you'd have a more robust session manager
                    if let window = UIApplication.shared.windows.first {
                        window.rootViewController = UIHostingController(rootView: LoginView1().environmentObject(AppData()))
                        window.makeKeyAndVisible()
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
}


struct StudentMainTabView_Previews: PreviewProvider {
    static var previews: some View {
        StudentMainTabView(username: "TeenLogin")
            .environmentObject(AppData())
    }
}