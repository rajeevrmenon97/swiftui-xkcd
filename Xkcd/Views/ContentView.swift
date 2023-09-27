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
        (1, "Feed")
    ])
    
    var body: some View {
        // Main tab view
        TabView(selection: $selectedTab) {
            // Navigation view for the feed
            NavigationStack {
                FeedView()
                    .navigationBarTitle(tabNames[selectedTab] ?? "", displayMode: .inline)
                    .toolbarBackground(.visible, for: .navigationBar, .tabBar)
            }
            .tabItem {
                Label("Feed", systemImage: "list.dash")
            }.tag(1)
        }
    }
}

#Preview {
    ContentView()
}
