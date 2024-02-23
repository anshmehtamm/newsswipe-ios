//
//  NewsData.swift
//  newsswipe
//
//  Created by Ansh Mehta on 2/9/24.
//

import Foundation

struct NewsItem: Codable {
    var article_id: String
    var article_type: String
    var image_url: String
    var published_datetime: String
    var region: String
    var summary: String
    var title: String
    var url: String
}
