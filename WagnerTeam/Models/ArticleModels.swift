//
//  ArticleModels.swift
//  WagnerTeam
//
//  Created by Сергей Кудинов on 08.11.2023.
//

import Foundation

struct APIReponse: Codable {
    let articles: [Article]
    
}

struct Article: Codable {
    let source: Source?
    let title: String
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
    let content: String?
    var isSaved: Bool? = false
}

struct Source: Codable {
    let name: String
}
