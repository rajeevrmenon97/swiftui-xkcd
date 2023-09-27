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
        Form {
            Section(header: Text("Appearance")) {
                Toggle("Dark Mode", isOn: $isDarkMode)
            }
            
            Section(header: Text("Storage")) {
                Button("Clear Cache", role: .destructive, action: {
                    showClearCacheAlert = true
                }).alert(isPresented: $showClearCacheAlert) {
                    Alert(
                        title: Text("Clear Cache"),
                        message: Text("Are you sure?"),
                        primaryButton: .destructive(Text("Yes"), action: XkcdApiHelper.clearCache),
                        secondaryButton: .default(Text("No"))
                    )
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
