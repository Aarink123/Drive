//
//  ParentMainTabView.swift
//  DriveQuest
//
//  Created by Aarin Karamchandani on 6/17/25.
//

import SwiftUI

struct ParentMainTabView: View {
    let username: String

    // Define the primary color scheme to pass to tab bar
    private let deepBlue = Color(red: 23/255, green: 77/255, blue: 133/255)
    private let secondaryBlue = Color(red: 40/255, green: 91/255, blue: 144/255)

    init(username: String) {
        self.username = username
        
        // --- Tab Bar Appearance --- //
        let appearance = UITabBarAppearance()
        // Use the secondary blue for the tab bar background
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
            ParentDashboardView1(username: username)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Dashboard")
                }
            
            // Routes Tab (Placeholder)
            RoutesView()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Routes")
                }

            // Location Tab
            MapsView()
                .tabItem {
                    Image(systemName: "location.fill")
                    Text("Location")
                }

            // Settings Tab
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
        .accentColor(.white) // Sets the color for the selected tab item
    }
}

// Placeholder View for the new "Routes" tab
struct RoutesView: View {
    private let deepBlue = Color(red: 23/255, green: 77/255, blue: 133/255)

    var body: some View {
        ZStack {
            deepBlue.edgesIgnoringSafeArea(.all)
            VStack {
                Image(systemName: "signpost.right.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white.opacity(0.5))
                Text("Routes")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("The UI for this screen has not been implemented yet.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.7))
                    .padding()
            }
        }
    }
}


struct ParentMainTabView_Previews: PreviewProvider {
    static var previews: some View {
        ParentMainTabView(username: "ParentLogin")
            .environmentObject(AppData())
    }
}
