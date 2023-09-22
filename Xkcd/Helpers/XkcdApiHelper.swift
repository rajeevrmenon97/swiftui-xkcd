//
//  XkcdApiHelper.swift
//  Xkcd
//
//  Created by Rajeev R Menon on 9/21/23.
//

import Foundation

class XkcdApiHelper {
    static func getRequest(api_url: String) async -> XkcdApiResponse? {
        do {
            let url = URL(string: api_url)!
            let (data, _) = try await URLSession.shared.data(from: url)
            let result = try JSONDecoder().decode(XkcdApiResponse.self, from: data)
            return result
        } catch {
            print("Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func getComic(num: Int) async -> XkcdApiResponse? {
        var result: XkcdApiResponse?
        await result = getRequest(api_url: "https://xkcd.com/" + String(num) + "/info.0.json")
        return result
    }
}
