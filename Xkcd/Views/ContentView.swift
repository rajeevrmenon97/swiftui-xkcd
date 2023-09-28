//
//  ContentView.swift
//  Xkcd
//
//  Created by Rajeev R Menon on 9/21/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var favoritesViewModel = FavoritesViewModel()
    @State var selectedTab = 1
    
    var body: some View {
        // Main tab view
        TabView(selection: $selectedTab) {
            SingleComicView(favoritesViewModel: favoritesViewModel, showControls: true)
                .tabItem {
                    Label("Xkcd", systemImage: "figure.walk")
                }.tag(1)
            
            // The full Xkcd feed
            FeedView(favoritesViewModel: favoritesViewModel)
                .toolbarBackground(.visible, for: .navigationBar, .tabBar)
                .tabItem {
                    Label("Feed", systemImage: "list.dash")
                }.tag(2)
            
            // Favorites feed
            FavoritesView(favoritesViewModel: favoritesViewModel)
                .tabItem {
                    Label("Favorites", systemImage: "heart")
                }.tag(3)
            
            // Settings
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }.tag(4)
        }
    }
}

#Preview {
    ContentView()
}
