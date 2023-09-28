//
//  ComicImageView.swift
//  Xkcd
//
//  Created by Rajeev R Menon on 9/28/23.
//

import Foundation
import SwiftUI
import Kingfisher

struct LikeButtonView: View {
    // Comic for which the like button is showed
    var comic: XkcdComic
    
    // DataSource for the favorites feed
    @ObservedObject var favoritesViewModel: FavoritesViewModel
    
    // State variable for the like button
    @State var isFavorite: Bool = false
    
    var body: some View {
        Image(systemName: isFavorite ? "heart.fill": "heart")
            .imageScale(.large)
            .onAppear(perform: {
                // Update the like button status real time
                isFavorite = favoritesViewModel.isFavorite(comicNumber: comic.num)
            })
            .onTapGesture {
                // Handle add/remove to favorites
                if favoritesViewModel.isFavorite(comicNumber: comic.num) {
                    isFavorite = false
                    favoritesViewModel.deleteFavorite(comicNumber: comic.num)
                } else {
                    isFavorite = true
                    favoritesViewModel.addFavorite(comic: comic)
                }
            }
    }
}
