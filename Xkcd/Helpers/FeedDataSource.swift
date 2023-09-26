//
//  FeedDataSource.swift
//  Xkcd
//
//  Created by Rajeev R Menon on 9/22/23.
//

import Foundation
import Combine
import SwiftUI

// Class holding the business logic of the app
class FeedDataSource: ObservableObject {
    // Stores the comics and the loading status
    @Published var comics = [XkcdComic]()
    @Published var isLoading = false
    
    private var cancellables: Set<AnyCancellable> = []
    private var currentComic = 0
    private var canLoadMoreComics = true
    private var batchSize = 5
    
    init() {
        // Try to load the latest comic
        XkcdApiHelper.getLatestComic()
            .catch({ error -> AnyPublisher<XkcdComic?, Error> in
                // Failed to load the latest comic. Try to load the latest comic from cache
                return XkcdApiHelper.getLatestComic(useCache: true)
            })
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { comic in
                guard let comic = comic else {return}
                self.comics.append(comic)
                // Set the current comic to the one before latest
                self.currentComic = comic.num - 1
                // Load the previous comics in descending order of comic number
                self.loadContent()
            }).store(in: &cancellables)
    }
    
    // This function is called when a comic listing appears on the feed
    public func loadMoreContentIfNeeded(comic: XkcdComic?) {
        guard let comic = comic else {
            return
        }
        
        // Reached the first comic, don't load anymore
        if (comic.num <= 1) {
            canLoadMoreComics = false
            return
        }
        
        // If the comic that appeared is the last one loaded, get more comics
        if (comic.num == comics.last?.num) {
            loadContent()
        }
    }
    
    
    public func loadContent() {
        // If loading or all comics are loaded, don't do anything
        guard !isLoading && canLoadMoreComics else {
            return
        }
        
        // Set loading status
        isLoading = true
        
        // List of comics to load (in descending order)
        let comicNumbers = Array((((currentComic - batchSize) > 0 ? (currentComic - batchSize) : 0)...currentComic).reversed())
        
        // Load the comics using combine API
        Publishers.Sequence(sequence: comicNumbers)
            .flatMap { number in
                XkcdApiHelper.getComic(num: number).replaceError(with: nil)
            }
            .compactMap { $0 }
            .collect()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] newComics in
                self?.comics.append(contentsOf: newComics.sorted{ $0.num > $1.num })
                self?.isLoading = false
                self?.currentComic -= self!.batchSize + 1
            })
            .store(in: &cancellables)
    }
    
}
