//
//  FeedViewModel.swift
//  Xkcd
//
//  Created by Rajeev R Menon on 9/22/23.
//

import Foundation
import Combine
import SwiftUI

// Class holding the business logic of the app
class FeedViewModel: ObservableObject {
    // Comics displayed on the feed
    @Published var comics = [XkcdComic]()
    
    // Boolean state of the loading progress view
    @Published var isLoading = false
    
    // Number of the next comic to load
    private var nextComic = 0
    
    // Boolean stating if more comics can be loaded
    private var canLoadMoreComics = true
    
    // Number of comics to be loaded at once
    private var batchSize = 5
    
    // Cancellables
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        loadLatestComic()
    }
    
    // Try to load the latest comic
    private func loadLatestComic() {
        XkcdApiService.getLatestComic()
            .catch({ error -> AnyPublisher<XkcdComic?, Error> in
                // Failed to load the latest comic. Try to load the latest comic from cache
                return XkcdApiService.getLatestComic(useCache: true)
            })
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { comic in
                guard let comic = comic else {return}
                self.comics.append(comic)
                // Set the current comic to the one before latest
                self.nextComic = comic.num - 1
                // Load the previous comics in descending order of comic number
                self.loadContent()
            }).store(in: &cancellables)
    }
    
    // Function to reload the feed when there is a new comic
    public func reload() {
        DispatchQueue.main.async {
            self.comics.removeAll()
            self.canLoadMoreComics = true
            self.loadLatestComic()
        }
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
        let comicNumbers = Array((((nextComic - batchSize) > 0 ? (nextComic - batchSize) : 0)...nextComic).reversed())
        
        // Load the comics using combine API
        Publishers.Sequence(sequence: comicNumbers)
            .flatMap { number in
                XkcdApiService.getComic(num: number).replaceError(with: nil)
            }   
            .compactMap { $0 }
            .collect()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] newComics in
                self?.comics.append(contentsOf: newComics.sorted{ $0.num > $1.num })
                self?.isLoading = false
                self?.nextComic -= self!.batchSize + 1
            })
            .store(in: &cancellables)
    }
    
}
