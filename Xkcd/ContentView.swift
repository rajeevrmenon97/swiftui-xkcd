//
//  ContentView.swift
//  Xkcd
//
//  Created by Rajeev R Menon on 9/21/23.
//

import SwiftUI

struct ContentView: View {
    @State var selectedTab = 1
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                FeedView()
                    .tabItem {
                        Label("Feed", systemImage: "heart")
                    }.tag(1)
            }.navigationTitle(selectedTab == 1 ? "Feed" : "")
            
        }
    }
}

#Preview {
    ContentView()
}
