//
//  FavoritesView.swift
//  Xkcd
//
//  Created by Rajeev R Menon on 9/27/23.
//

import SwiftUI

// View for a single favorite
struct FavoriteItemView: View {
    var comic: XkcdComic
    var width: CGFloat
    var height: CGFloat
    
    var body: some View {
        HStack {
            HStack {
                Text("#\(comic.num)")
                    .bold()
                    .multilineTextAlignment(.center)
                Text(comic.title)
                Spacer()
            }.frame(width: width * 0.5)
            
            Spacer()
            
            VStack {
                XkcdApiHelper.getComicImage(comic: comic)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .background(
                        NavigationLink("", destination: SingleComicView(comic: comic))
                            .opacity(0)
                    )
            }
        }.frame(height: height)
    }
}

// Main view for the favorites feed
struct FavoritesView: View {
    // Favorites data source
    @ObservedObject var dataSource: FavoritesDataSource
    
    var body: some View {
        // Placeholder to display when there are no favorites
        if dataSource.noFavorites {
            Text("No favorites")
        } else {
            GeometryReader { geometry in
                List {
                    // Show favorites as they are loaded
                    ForEach(dataSource.comics) { comic in
                        FavoriteItemView(comic: comic, width: geometry.size.width, height: geometry.size.height * 0.15)
                            .onAppear(perform: {
                                // Function to load more favorites as you scroll
                                dataSource.loadMoreFavoritesIfNeeded(comic: comic)
                            })
                    }.onDelete { indexSet in
                        // Handle swipe left to remove favorites
                        indexSet.forEach { index in
                            dataSource.deleteFavorite(comicNumber: dataSource.comics[index].num)
                        }
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
    }
}

#Preview {
    FavoritesView(dataSource: FavoritesDataSource())
}
