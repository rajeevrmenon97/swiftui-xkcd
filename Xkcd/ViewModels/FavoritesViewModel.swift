//
//  FavoritesViewModel.swift
//  Xkcd
//
//  Created by Rajeev R Menon on 9/26/23.
//

import Foundation
import Combine

class FavoritesViewModel: ObservableObject {
    // Comics displayed on the favorites feed
    @Published var comics = [XkcdComic]()
    
    // Boolean state for the loading progress bar
    @Published var isLoading = false
    
    // Boolean state for the no favorites placeholder
    @Published var noFavorites = false
    
    // Numbers of all the liked comics
    var favorites = [Int]()
    
    // Index of the next comic to load from favorites array
    var nextFavoritesIndex: Int = 0
    
    // Are there anymore comics left to load?
    var canLoadMoreFavorites = true
    
    // Number of comics to load at once
    var batchSize = 5
    
    // Cancellables
    var cancellables: Set<AnyCancellable> = []
    
    // Key used for saving data in UserDefaults
    let userDefaultsKey = "favorites"
    
    init() {
        // Assume there are no favorites
        noFavorites = true
        
        // Try to read favorites
        if let comicNumbers = readFavorites() {
            if comicNumbers.count > 0 {
                // Load the favorites array
                favorites = Array(comicNumbers)
                noFavorites = false
                isLoading = true
                
                // Load the first favorite comic
                XkcdApiService.getComic(num: comicNumbers[0])
                    .replaceError(with: nil)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveValue: { comic in
                        guard let comic = comic else {return}
                        self.comics.append(comic)
                        self.nextFavoritesIndex = 1
                        self.isLoading = false
                        self.loadFavorites()
                    }).store(in: &cancellables)
            }
        }
        
    }
    
    // Function read the list of favorite comic numbers from UserDefaults
    func readFavorites() -> [Int]? {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let comicNumbers = try? JSONDecoder().decode([Int].self, from: data) {
                return comicNumbers
        }
        return nil
    }
    
    // Function to write a list of favorite comic numbers to UserDefaults
    func writeFavorites(comicNumbers: [Int]) {
        if let data = try? JSONEncoder().encode(comicNumbers) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
    
    // Function to add a new comic as favorite
    func addFavorite(comic: XkcdComic) {
        favorites.insert(comic.num, at: 0)
        writeFavorites(comicNumbers: favorites)
        DispatchQueue.main.async {
            // Add the new comic to the top of the feed
            self.comics.insert(comic, at: 0)
            self.noFavorites = self.favorites.count == 0
        }
    }
    
    // Function to delete a comic from favorites
    func deleteFavorite(comicNumber: Int) {
        favorites.removeAll(where: {$0 == comicNumber})
        writeFavorites(comicNumbers: favorites)
        DispatchQueue.main.async {
            // Remove the comic from favorites feed
            self.comics.removeAll(where: {$0.num == comicNumber})
            self.noFavorites = self.favorites.count == 0
        }
    }
    
    // Check if a given comic number is favorited
    func isFavorite(comicNumber: Int) -> Bool {
        return favorites.contains(comicNumber)
    }
    
    // Function to clear all favorites
    func clearFavorites() {
        favorites.removeAll()
        writeFavorites(comicNumbers: favorites)
        DispatchQueue.main.async {
            // Remove all comics from favorites feed
            self.comics.removeAll()
            self.noFavorites = true
        }
    }
    
    // This function is called when a favorite listing appears on the feed
    public func loadMoreFavoritesIfNeeded(comic: XkcdComic?) {
        guard let comic = comic else {
            return
        }
        
        // Reached the last favorite, don't load anymore
        if (nextFavoritesIndex >= favorites.count) {
            canLoadMoreFavorites = false
            return
        }
        
        // If the favorite that appeared is the last one loaded, get more comics
        if (comic.num == comics.last?.num) {
            loadFavorites()
        }
    }
    
    // Function to load favorites on to the feed
    func loadFavorites() {
        guard !isLoading && canLoadMoreFavorites else {
            return
        }
        
        // Set loading status
        isLoading = true
        
        // List of comic numbers to load
        let endIndex = ((nextFavoritesIndex + batchSize) < favorites.count) ? (nextFavoritesIndex + batchSize) : favorites.count
        let comicNumbers = Array(favorites[nextFavoritesIndex..<endIndex])
        
        // Load the comics using combine API
        Publishers.Sequence(sequence: comicNumbers)
            .flatMap { number in
                XkcdApiService.getComic(num: number).replaceError(with: nil)
            }
            .compactMap { $0 }
            .collect()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] newComics in
                self?.comics.append(contentsOf: newComics.sorted(by: {$0.num > $1.num}))
                self?.isLoading = false
                self?.nextFavoritesIndex += self!.batchSize + 1
            })
            .store(in: &cancellables)
    }
}
