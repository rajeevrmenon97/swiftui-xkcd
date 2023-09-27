//
//  ContentView.swift
//  Xkcd
//
//  Created by Rajeev R Menon on 9/21/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var favoritesDataSource = FavoritesDataSource()
    @State var selectedTab = 1
    
    // Dictionary holding the tab names
    let tabNames = Dictionary<Int, String>(uniqueKeysWithValues: [
        (1, "Feed"), (2, "Favorites"), (3, "Settings")
    ])
    
    var body: some View {
        // Main navigation stack
        NavigationStack {
            // Main tab view
            TabView(selection: $selectedTab) {
                // The full Xkcd feed
                FeedView(favoritesDataSource: favoritesDataSource)
                    .toolbarBackground(.visible, for: .navigationBar, .tabBar)
                .tabItem {
                    Label("Feed", systemImage: "list.dash")
                }.tag(1)
                
                // Favorites feed
                FavoritesView(dataSource: favoritesDataSource).tabItem {
                    Label("Favorites", systemImage: "heart")
                }.tag(2)
                
                // Settings
                SettingsView().tabItem {
                    Label("Settings", systemImage: "gear")
                }.tag(3)
            }
            .navigationBarTitle(tabNames[selectedTab]!, displayMode: .inline)
        }
    }
}

#Preview {
    ContentView()
}
