//
//  XkcdApiResponse.swift
//  Xkcd
//
//  Created by Rajeev R Menon on 9/22/23.
//

import Foundation

// Model to parse the API response from XKCD
struct XkcdApiResponse: Codable, Identifiable {
    var id: Int { num }
    var num: Int
    var day: String
    var month: String
    var year: String
    var news: String
    var safe_title: String
    var transcript: String
    var alt: String
    var img: String
    var title: String
}
