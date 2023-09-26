//
//  XkcdApiHelper.swift
//  Xkcd
//
//  Created by Rajeev R Menon on 9/21/23.
//

import Foundation
import Combine

// Helper class to make the API calls to XKCD
class XkcdApiHelper {
    
    // Since the comics don't change, we can cache most of the requests
    static let urlCache: URLCache = {
        let cache = URLCache(memoryCapacity: 10 * 1024 * 1024, diskCapacity: 50 * 1024 * 1024, diskPath: "xkcd_cache")
        return cache
    }()
    
    // URL Session for the app set to use the above cache
    static var urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.urlCache = urlCache
        return URLSession(configuration: config)
    }()
    
    // Function to clear the cache
    static func clearCache() {
        urlCache.removeAllCachedResponses()
    }
    
    // Basic function to make a GET request
    private static func getRequest(comicUrl: String, useCache: Bool = true) -> AnyPublisher<XkcdComic?, Error> {
        guard let url = URL(string: comicUrl) else {
            fatalError("Wrong URL")
        }
        
        // Choose the cache policy
        let cachePolicy: URLRequest.CachePolicy = {
            if useCache {
                return .returnCacheDataElseLoad
            } else {
                return .reloadIgnoringLocalCacheData
            }
        }()
        
        // Create the request with the specified cache policy
        var request = URLRequest(url: url)
        request.cachePolicy = cachePolicy
        
        return urlSession.dataTaskPublisher(for: request)
            .map({$0.data})
            .decode(type: XkcdApiResponse.self, decoder: JSONDecoder())
            .map({XkcdComic(num: $0.num, title: $0.title, imgUrl: $0.img)})
            .eraseToAnyPublisher()
    }
    
    // Function to return comic with a specific number
    static func getComic(num: Int) -> AnyPublisher<XkcdComic?, Error> {
        return self.getRequest(comicUrl: "https://xkcd.com/\(num)/info.0.json")
    }
    
    // Function to return the latest comic. By default we don't cache this as new comics come out
    static func getLatestComic(useCache: Bool = false) -> AnyPublisher<XkcdComic?, Error> {
        return self.getRequest(comicUrl: "https://xkcd.com/info.0.json", useCache: useCache)
    }
}
