//
//  FeedView.swift
//  Xkcd
//
//  Created by Rajeev R Menon on 9/21/23.
//

import SwiftUI

// View for a single item in the feed
struct FeedItemView: View {
    // Comic in the feed item
    var comic: XkcdComic
    
    // DataSource for the favorites feed
    @ObservedObject var favoritesViewModel: FavoritesViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text("#\(comic.num)")
                    .bold()
                Spacer()
            }.padding(.top)
            
            // KF Image of the comic
            XkcdApiService.getComicImage(comic: comic)
                .resizable()
                .scaledToFit()
                .background(
                    // Link hidden in background to hide the arrow
                    NavigationLink("", destination: SingleComicView(comic: comic, favoritesViewModel: favoritesViewModel))
                        .opacity(0)
                )
            
            HStack {
                LikeButtonView(comic: comic, favoritesViewModel: favoritesViewModel)
                
                Text(comic.title)
                    .font(.subheadline)
                Spacer()
            }.padding(.top)
        }.padding(.bottom)
    }
}

// Main view for the feed
struct FeedView: View {
    // View models
    @StateObject var feedViewModel = FeedViewModel()
    @ObservedObject var favoritesViewModel: FavoritesViewModel
    
    var body: some View {
        NavigationStack {
            List {
                // Show each comic as they are loaded
                ForEach(feedViewModel.comics) { comic in
                    FeedItemView(comic: comic, favoritesViewModel: favoritesViewModel)
                        .onAppear(perform: {
                            // Function to load more comics as you scroll
                            feedViewModel.loadMoreContentIfNeeded(comic: comic)
                        })
                }
                
                // Progress bar to show while loading comics
                // An ID is added to it for showing it in a list
                if (feedViewModel.isLoading) {
                    HStack {
                        Spacer()
                        ProgressView().id(UUID())
                        Spacer()
                    }
                    
                }
            }
            .refreshable {
                // Reload the feed to load any new comics
                feedViewModel.reload()
            }
            .listStyle(.plain) // No background for the list elements
            .scrollIndicators(.hidden) // Hide scroll bar
            .navigationTitle("Feed")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    FeedView(favoritesViewModel: FavoritesViewModel())
}
