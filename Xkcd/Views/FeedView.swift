//
//  FeedView.swift
//  Xkcd
//
//  Created by Rajeev R Menon on 9/21/23.
//

import SwiftUI

// View for a single item in the feed
struct FeedItemView: View {
    // State variable for the like button
    @State var isFavorite: Bool = false
    
    // Comic in the feed item
    var comic: XkcdComic
    
    // DataSource for the favorites feed
    @ObservedObject var favoritesDataSource: FavoritesDataSource
    
    var body: some View {
        VStack {
            HStack {
                Text("#\(comic.num)")
                    .bold()
                Spacer()
            }.padding(.top)
            
            // KF Image of the commic
            XkcdApiHelper.getComicImage(comic: comic)
                .resizable()
                .scaledToFit()
                .padding()
                .border(Color.primary)
                .background(
                    // Link hidden in background to hide the arrow
                    NavigationLink("", destination: SingleComicView(comic: comic))
                        .opacity(0)
                )
            
            HStack {
                Image(systemName: isFavorite ? "heart.fill": "heart")
                    .imageScale(.large)
                    .onAppear(perform: {
                        // Update the like button status real time
                        isFavorite = favoritesDataSource.isFavorite(comicNumber: comic.num)
                    })
                    .onTapGesture {
                        // Handle add/remove to favorites
                        if favoritesDataSource.isFavorite(comicNumber: comic.num) {
                            isFavorite = false
                            favoritesDataSource.deleteFavorite(comicNumber: comic.num)
                        } else {
                            isFavorite = true
                            favoritesDataSource.addFavorite(comic: comic)
                        }
                    }
                Text(comic.title)
                    .font(.subheadline)
                Spacer()
            }.padding(.top)
        }.padding(.bottom)
    }
}

// Main view for the feed
struct FeedView: View {
    // API data source
    @StateObject var dataSource = FeedDataSource()
    @ObservedObject var favoritesDataSource: FavoritesDataSource
    
    var body: some View {
        List {
            // Show each comic as they are loaded
            ForEach(dataSource.comics) { comic in
                FeedItemView(comic: comic, favoritesDataSource: favoritesDataSource)
                    .onAppear(perform: {
                        // Function to load more comics as you scroll
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
        .refreshable {
            // Reload the feed to load any new comics
            dataSource.reload()
        }
        .listStyle(.plain) // No background for the list elements
        .scrollIndicators(.hidden) // Hide scroll bar
    }
}

#Preview {
    FeedView(favoritesDataSource: FavoritesDataSource())
}
