//
//  FeedView.swift
//  Xkcd
//
//  Created by Rajeev R Menon on 9/21/23.
//

import SwiftUI

struct SingleComicView: View {
    var comic: XkcdApiResponse
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: comic.img)) { phase in
                switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image.resizable().scaledToFit()
                    case .failure:
                        ProgressView()
                    @unknown default:
                        EmptyView()
                }
            }
            Text(comic.safe_title)
        }.navigationBarTitle(comic.safe_title, displayMode: .inline)
    }
}

struct FeedItemView: View {
    var comic: XkcdApiResponse
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: comic.img)) { phase in
                switch phase {
                    case .empty:
                        Image(systemName: "photo")
                    case .success(let image):
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure:
                        Image(systemName: "photo")
                    @unknown default:
                        EmptyView()
                }
            }
            Text("\(comic.title)")
        }.padding()
        
    }
}

struct FeedView: View {
    @State var comics = [XkcdApiResponse]()
    @State var offset = 1
    
    func getComics(start: Int = 1) async -> () {
        var comic: XkcdApiResponse?
        let limit: Int = 10
        if offset == start {
            for i in start...(start + limit - 1) {
                await comic = XkcdApiHelper.getComic(num: i)
                if comic != nil {
                    comics.append(comic!)
                }
                offset += 1
            }
        }
    }
    
    var body: some View {
        List(comics) { comic in
            NavigationLink(destination: SingleComicView(comic: comic)) {
                FeedItemView(comic: comic)
            }.padding()
        }
        .task {
            await getComics()
        }
    }
}

#Preview {
    FeedView()
}
