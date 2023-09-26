//
//  FeedView.swift
//  Xkcd
//
//  Created by Rajeev R Menon on 9/21/23.
//

import SwiftUI

// View for a single item in the feed
struct FeedItemView: View {
    var comic: XkcdComic
    
    var body: some View {
        // Navigation link is added to the background to hide
        // the arrow that shows up
        VStack {
            Text("\(comic.num) \(comic.title)")
        }.background(
            NavigationLink("", destination: SingleComicView(comic: comic)).opacity(0)
        )
    }
}

// Main view for the feed
struct FeedView: View {
    // API data source
    @StateObject var dataSource = FeedDataSource()
    
    var body: some View {
        List {
            // Show each comic as they appear
            ForEach(dataSource.comics) { comic in
                FeedItemView(comic: comic)
                    .onAppear(perform: {
                        // Function to load more comics
                        dataSource.loadMoreContentIfNeeded(comic: comic)
                    })
            }
            
            // Progress bar to show while loading comics
            // An ID is added to it for showing it in a list
            if (dataSource.isLoading) {
                HStack {
                    Spacer()
                    ProgressView().id(UUID())
                    Spacer()
                }
                
            }
        }
        .listStyle(.plain) // No background for the list elements
        .scrollIndicators(.hidden) // Hide scroll bar
    }
}

#Preview {
    FeedView()
}
