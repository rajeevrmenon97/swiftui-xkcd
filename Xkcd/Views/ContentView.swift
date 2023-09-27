//
//  ContentView.swift
//  Xkcd
//
//  Created by Rajeev R Menon on 9/21/23.
//

import SwiftUI

struct ContentView: View {
    @State var selectedTab = 1
    
    // Dictionary holding the tab names
    let tabNames = Dictionary<Int, String>(uniqueKeysWithValues: [
        (1, "Feed"), (2, "Settings")
    ])
    
    var body: some View {
        // Navigation view for the feed
        NavigationStack {
            // Main tab view
            TabView(selection: $selectedTab) {
                FeedView()
                    .toolbarBackground(.visible, for: .navigationBar, .tabBar)
                .tabItem {
                    Label("Feed", systemImage: "list.dash")
                }.tag(1)
                
                SettingsView().tabItem {
                    Label("Settings", systemImage: "gear")
                }.tag(2)
            }.navigationBarTitle(tabNames[selectedTab]!, displayMode: .inline)
        }
    }
}

#Preview {
    ContentView()
}
