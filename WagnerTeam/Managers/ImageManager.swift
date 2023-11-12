//
//  ImageManager.swift
//  News
//
//  Created by Андрей Азябин on 22.10.2023.
//
import Foundation


final class ImageManager {
    static let shared = ImageManager()
    
    public func loadImageData(from url: URL, completion: @escaping (Data?) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: url) { (data, _, _) in
            completion(data)
        }
        dataTask.resume()
    }
    
    private init(){}
}
