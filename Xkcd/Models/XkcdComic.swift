//
//  XkcdComic.swift
//  Xkcd
//
//  Created by Rajeev R Menon on 9/22/23.
//

import Foundation

// Model that holds a single Comic
struct XkcdComic: Identifiable {
    var id: Int { num }
    var num: Int
    var title: String
    var imgUrl: String
}
