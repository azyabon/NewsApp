//
//  NetworkManager.swift
//  News
//
//  Created by Андрей Азябин on 22.10.2023.
//

import Foundation

final class NetworkManager {
    static let shared = NetworkManager()
    
    struct Constants {
        
        static let topHeadlinesURL = URL(string: "https://newsapi.org/v2/top-headlines?country=us&apiKey=cdbc1ae8bb6846afa3a71a306d1829a9")
        static let searchUrlString =  "https://newsapi.org/v2/everything?sortBy=popularity&apiKey=cdbc1ae8bb6846afa3a71a306d1829a9&q="
    }
    
    private init() {
        
    }
    
    public func getTopStories(completion: @escaping (Result<[Article], Error>) -> Void) {
        guard let url = Constants.topHeadlinesURL else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
            }
            else if let data = data {
                
                do {
                    let result = try JSONDecoder().decode(APIReponse.self, from: data)
                    
                    print(result.articles.count)
                    completion(.success(result.articles))
                }
                catch {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    public func search(with query: String, completion: @escaping (Result<[Article], Error>) -> Void) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        let urlstring = Constants.searchUrlString + query
        guard let url = URL(string: urlstring) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
            }
            else if let data = data {
                
                do {
                    let result = try JSONDecoder().decode(APIReponse.self, from: data)
                    
                    completion(.success(result.articles))
                }
                catch {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
}

