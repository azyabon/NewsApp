//
//  CoreDataManager.swift
//  News
//
//  Created by Андрей Азябин on 22.10.2023.
//
import CoreData
import Foundation
import UIKit


final class CoreDataManager {
    static let shared = CoreDataManager()
    
    public  func SaveArticleToCoreData(article: Article) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchReq = NSFetchRequest<Articles>(entityName: "Articles")
        
        fetchReq.predicate = NSPredicate(format: "title == %@",  article.title)
        do {
            let results = try managedContext.fetch(fetchReq)
            
            if let existingArticleEntity = results.first {
                existingArticleEntity.title = article.title
                existingArticleEntity.subtitle = article.description
                existingArticleEntity.imageURL = article.urlToImage
                
                
                try managedContext.save()
                
            } else {
                let newArticleEntity = Articles(context: managedContext)
                newArticleEntity.title = article.title
                newArticleEntity.subtitle = article.description
                newArticleEntity.imageURL = article.urlToImage
                
                try managedContext.save()
                
            }
            
            
        } catch {
            print("Failed to save Article: \(error)")
        }
    }
    
    
    private init(){}
}
