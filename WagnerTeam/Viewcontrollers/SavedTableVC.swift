//
//  TopNewsTableVC.swift
//  WagnerTeam
//
//  Created by Сергей Кудинов on 08.11.2023.
//

import CoreData
import UIKit

class SavedTableVC: UITableViewController {
  
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var articles: [Article] = []
    var articlesCopy: [Article] = []
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.showsVerticalScrollIndicator.toggle()
        fetchSavedArticlesFromCoredata()
       
        
    }
    
    //позволяет подтягивать новые сохраненные статьи после сохранения на первом экране
    override func viewWillAppear(_ animated: Bool) {
        articles = []
        fetchSavedArticlesFromCoredata()
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return articles.count
    }

    //настройка ячейки
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell") as! NewsCell
        if articles.count >= indexPath.row {
            var currentArticle = articles[indexPath.row]
            cell.newsTitle.text = currentArticle.title
            
            if let imageData = currentArticle.image  { cell.articleImage.image = UIImage(data: imageData) }
            
            else {
                
              
                if let url = currentArticle.urlToImage {
                    let url = URL(string: url) ?? URL(string: "https://api.nsn.fm/storage/medialib/377901/mobile_image-4cb7d95d0088984440b9294193cd85d4.jpg")!
                    cell.newsTitle.text = currentArticle.title
                    ImageManager.shared.loadImageData(from: url) { data in
                        guard let data = data, let imageData = UIImage(data: data) else { return}
                        DispatchQueue.main.async {
                            currentArticle.image = data
                            self.articles[indexPath.row] = currentArticle
                            cell.articleImage.image = imageData
                            cell.articleImage.clipsToBounds.toggle()
                        }
                    }
                    ((indexPath.row + 1) % 2 == 0) ? (cell.backgroundColor = .black) : (cell.backgroundColor = .systemGray5)
                    
                }
            }
        }
        
        return cell
    }
    // действие по свайпу(удаление)
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: [
            makeCompleteContextualAction(forRowAt: indexPath)
        ])
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = UITableView.automaticDimension
        if height > 100 {
            return height
        } else {
            return 126
        }
       // UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        114
    }
    
 


  
    //переход к деталке

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        index = indexPath.row
        performSegue(withIdentifier: "NewsSegue", sender: nil)
    }
}



extension SavedTableVC {
    
   
    
    public func fetchSavedArticlesFromCoredata() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Articles> = Articles.fetchRequest()

        do {
            let results = try managedContext.fetch(fetchRequest)
            
            
            for article in results {
                let currentArticle = Article(source: nil, title: article.title ?? "", description: article.subtitle ?? "", url: nil, urlToImage: article.imageURL, publishedAt: nil, content: article.content)
                print(currentArticle.title)
                articles.append(currentArticle)
                
                
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("Failed to fetch articles: \(error)")
        }
        
        
        
        

    }
    
}

extension SavedTableVC {
    //свайп на удаление
    private func makeCompleteContextualAction(forRowAt indexPath: IndexPath) -> UIContextualAction {
        
     
        let actionTap =  UIContextualAction(style: .normal, title: nil) { (action, swipeButtonView, completion) in
            
            
            self.deleteSavedArticle(at: indexPath)
            
            completion(true)
        }
      
                actionTap.image = UIImage(systemName: "trash")
                actionTap.backgroundColor = .red
                actionTap.image?.withTintColor(.green)
            
        

        
        return actionTap
    }
    //удаление статьи с кордаты и экрана
    internal func deleteSavedArticle(at indexPath: IndexPath) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        guard let articleEntity = convertToArticleEntity(articles[indexPath.row], managedContext: managedContext) else { return }
        
        managedContext.perform {
            managedContext.delete(articleEntity)
            
            do {
                try managedContext.save()
                
                DispatchQueue.main.async {
                    self.articles.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }
            } catch {
                print("Failed to delete Bible: \(error)")
            }
        }
    }
    //перевод с типа объекта статьи в тип объекта кордаты хз зачем можно было и без него но как есть
    private func convertToArticleEntity(_ article: Article, managedContext: NSManagedObjectContext) -> Articles? {
        let fetchRequest: NSFetchRequest<Articles> = Articles.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", article.title)
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            return results.first
        } catch {
            print("Failed to fetch BibleEntity: \(error)")
            return nil
        }
    }
}

extension SavedTableVC {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                if segue.identifier == "NewsSegue" {
                    let vc = segue.destination as! ArticleDetailsVC
                    vc.article = articles[index]
                }
    }
}
