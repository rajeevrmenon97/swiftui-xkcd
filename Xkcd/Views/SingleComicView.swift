//
//  SingleComicView.swift
//  Xkcd
//
//  Created by Rajeev R Menon on 9/25/23.
//

import SwiftUI

struct SingleComicView: View {
    var comic: XkcdComic
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: comic.imgUrl)) { phase in
                switch phase {
                case .empty: // While loading
                    ProgressView()
                case .success(let img): // After successful loading
                    img.resizable().scaledToFit()
                case .failure: // Failed to load image
                    Image(systemName: "photo")
                @unknown default: // Other cases
                    Image(systemName: "photo")
                }
            }
            Text(comic.title)
        }.navigationBarTitle(comic.title, displayMode: .inline)
    }
}

#Preview {
    // Hard coded comic for preview
    SingleComicView(comic: XkcdComic(num: 1, title: "Barrel - Part 1", imgUrl: "https://imgs.xkcd.com/comics/barrel_cropped_(1).jpg"))
}
