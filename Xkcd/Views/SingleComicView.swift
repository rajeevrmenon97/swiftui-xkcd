//
//  SingleComicView.swift
//  Xkcd
//
//  Created by Rajeev R Menon on 9/25/23.
//

import SwiftUI

// Xkcd button style
struct XkcdButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .bold()
            .font(.caption)
            .padding()
            .background(Color("XkcdColor"))
            .foregroundColor(.white)
            .border(Color.black)
    }
}

// Single comic view
struct SingleComicView: View {
    var comic: XkcdComic?
    
    // View Model for single comic view
    @StateObject var singleComicViewModel = SingleComicViewModel()
    
    // View Model for the favorites data
    @ObservedObject var favoritesViewModel: FavoritesViewModel
    
    @State var isFavorite: Bool = false
    @State private var scale: CGFloat = 1.0
    
    
    var body: some View {
        VStack {
            if singleComicViewModel.isComicSet {
                HStack {
                    Text("#\(singleComicViewModel.currentComic!.num)")
                        .bold()
                    Spacer()
                    Image(systemName: isFavorite ? "heart.fill": "heart")
                        .imageScale(.large)
                        .onAppear(perform: {
                            // Update the like button status real time
                            isFavorite = favoritesViewModel.isFavorite(comicNumber: singleComicViewModel.currentComic!.num)
                        })
                        .onTapGesture {
                            // Handle add/remove to favorites
                            if favoritesViewModel.isFavorite(comicNumber: singleComicViewModel.currentComic!.num) {
                                isFavorite = false
                                favoritesViewModel.deleteFavorite(comicNumber: singleComicViewModel.currentComic!.num)
                            } else {
                                isFavorite = true
                                favoritesViewModel.addFavorite(comic: singleComicViewModel.currentComic!)
                            }
                        }
                }
                
                Spacer()
                
                XkcdApiService.getComicImage(comic: singleComicViewModel.currentComic!)
                    .resizable()
                    .scaledToFit()
                    .border(Color("XkcdColor"), width: 5)
                    .scaleEffect(scale)
                    .gesture(MagnificationGesture()
                        .onChanged { value in
                            if value.magnitude < 1.0 {
                                self.scale = 1.0
                            } else {
                                self.scale = value.magnitude
                            }
                        }
                        .onEnded { _ in
                            self.scale = 1.0
                        }
                    )
            } else {
                ProgressView()
            }
            
            Spacer()
            
            HStack {
                Button("|<", action: singleComicViewModel.setFirstComic)
                Button("< PREV", action: singleComicViewModel.setPreviousComic)
                Button("RANDOM", action: singleComicViewModel.setRandomComic)
                Button("NEXT >", action: singleComicViewModel.setNextComic)
                Button(">|", action: singleComicViewModel.setLatestComic)
            }.buttonStyle(XkcdButtonStyle())
        }
        .padding()
        .onAppear(perform: {
            if let comic = comic {
                singleComicViewModel.setComic(comic: comic)
            } else {
                singleComicViewModel.setComic()
            }
        })
    }
}

#Preview {
    NavigationStack {
        SingleComicView(favoritesViewModel: FavoritesViewModel())
    }
}
