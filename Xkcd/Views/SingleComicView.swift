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
            XkcdApiHelper.getComicImage(comic: comic)
                .resizable()
                .scaledToFit()
            Text(comic.title)
        }.navigationBarTitle(comic.title, displayMode: .inline)
    }
}

#Preview {
    // Hard coded comic for preview
    SingleComicView(comic: XkcdComic(num: 1, title: "Barrel - Part 1", imgUrl: "https://imgs.xkcd.com/comics/barrel_cropped_(1).jpg"))
}
