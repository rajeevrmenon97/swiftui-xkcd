//
//  SettingsView.swift
//  Xkcd
//
//  Created by Rajeev R Menon on 9/26/23.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showClearCacheAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                // Appearance section
                Section(header: Text("Appearance")) {
                    // Dark mode toggle
                    Toggle("Dark Mode", isOn: $isDarkMode)
                }
                
                // Storage section
                Section(header: Text("Storage")) {
                    // Clear cache button
                    Button("Clear Cache", role: .destructive, action: {
                        showClearCacheAlert = true
                    }).alert(isPresented: $showClearCacheAlert) {
                        Alert(
                            title: Text("Clear Cache"),
                            message: Text("Are you sure?"),
                            primaryButton: .destructive(Text("Yes"), action: XkcdApiService.clearCache),
                            secondaryButton: .default(Text("No"))
                        )
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
}

#Preview {
    SettingsView()
}
