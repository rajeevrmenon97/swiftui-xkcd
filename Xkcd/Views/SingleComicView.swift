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
            .border(Color.black, width: 3)
    }
}

// Single comic view
struct SingleComicView: View {
    // Set this value to display a particular comic
    var comic: XkcdComic?
    
    // View Model for single comic view
    @StateObject var singleComicViewModel = SingleComicViewModel()
    
    // View Model for the favorites data
    @ObservedObject var favoritesViewModel: FavoritesViewModel
    
    // Scale factor for pinch zoom
    @State var scale: CGFloat = 1.0
    
    // Navbar title
    @State var navBarTitle = "Loading.."
    
    // Show controls or not
    var showControls = false
    
    
    var body: some View {
        // Main navigation stack
        NavigationStack {
            VStack {
                if singleComicViewModel.isComicSet {
                    HStack {
                        Text("#\(singleComicViewModel.currentComic!.num)")
                            .bold()
                        Spacer()
                        LikeButtonView(comic: singleComicViewModel.currentComic!, favoritesViewModel: favoritesViewModel)
                    }
                    
                    Spacer()
                    
                    XkcdApiService.getComicImage(comic: singleComicViewModel.currentComic!)
                        .placeholder({ProgressView()})
                        .resizable()
                        .scaledToFit()
                        .padding(5)
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
                        .onAppear(perform: {
                            navBarTitle = singleComicViewModel.currentComic!.title
                        })
                } else {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                
                Spacer()
                
                if showControls {
                    HStack {
                        Button("|<", action: singleComicViewModel.setFirstComic)
                        Button("< PREV", action: singleComicViewModel.setPreviousComic)
                        Button("RANDOM", action: singleComicViewModel.setRandomComic)
                        Button("NEXT >", action: singleComicViewModel.setNextComic)
                        Button(">|", action: singleComicViewModel.setLatestComic)
                    }.buttonStyle(XkcdButtonStyle())
                }
            }
            .padding()
            .onAppear(perform: {
                if let comic = comic {
                    singleComicViewModel.setComic(comic: comic)
                } else {
                    singleComicViewModel.setComic()
                }
            })
            .navigationTitle(navBarTitle)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    NavigationStack {
        SingleComicView(favoritesViewModel: FavoritesViewModel(), showControls: true)
    }
}
