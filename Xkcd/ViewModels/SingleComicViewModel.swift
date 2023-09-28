//
//  SingleComicViewModel.swift
//  Xkcd
//
//  Created by Rajeev R Menon on 9/27/23.
//

import Foundation
import Combine

class SingleComicViewModel: ObservableObject {
    @Published var currentComic: XkcdComic? = nil
    @Published var isComicSet = false
    
    var cancellables: Set<AnyCancellable> = []
    var latestComic: XkcdComic? = nil
    
    private func loadLatestComic(setCurrentComic: Bool = false) {
        if latestComic == nil {
            XkcdApiService.getLatestComic()
                .catch({ error -> AnyPublisher<XkcdComic?, Error> in
                    return XkcdApiService.getLatestComic(useCache: true)
                })
                .replaceError(with: nil)
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { comic in
                    guard let comic = comic else {return}
                    self.latestComic = comic
                    if setCurrentComic {
                        self.currentComic = comic
                        self.isComicSet = true
                    }
                }).store(in: &cancellables)
        }
    }
    
    func setComic() {
        loadLatestComic(setCurrentComic: true)
    }
    
    func setComic(comic: XkcdComic) {
        DispatchQueue.main.async {
            self.currentComic = comic
            self.isComicSet = true
        }
    }
    
    private func loadComic(comicNum: Int) {
        self.isComicSet = false
        XkcdApiService.getComic(num: comicNum)
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { comic in
                guard let comic = comic else {return}
                self.currentComic = comic
                self.isComicSet = true
            }).store(in: &cancellables)
    }
    
    func setNextComic() {
        loadLatestComic()
        if currentComic == nil || latestComic == nil{
            return
        }
        
        let nextComicNum = currentComic!.num + 1
        if nextComicNum <= latestComic!.num {
            loadComic(comicNum: nextComicNum)
        }
    }
    
    func setPreviousComic() {
        loadLatestComic()
        if currentComic == nil || latestComic == nil{
            return
        }
        
        let nextComicNum = currentComic!.num - 1
        if nextComicNum >= 1 {
            loadComic(comicNum: nextComicNum)
        }
    }
    
    func setFirstComic() {
        loadComic(comicNum: 1)
    }
    
    func setLatestComic() {
        loadLatestComic()
        DispatchQueue.main.async {
            self.currentComic = self.latestComic
        }
    }
    
    func setRandomComic() {
        loadLatestComic()
        if latestComic == nil{
            return
        }
        
        let randomInt = Int.random(in: 0..<latestComic!.num)
        loadComic(comicNum: randomInt)
    }
}
