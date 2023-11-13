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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.showsVerticalScrollIndicator.toggle()
        fetchSavedArticlesFromCoredata()
       
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    

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

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell") as! NewsCell
        if articles.count >= indexPath.row {
            let currentArticle = articles[indexPath.row]
            if let url = currentArticle.urlToImage {
                let url = URL(string: url) ?? URL(string: "https://api.nsn.fm/storage/medialib/377901/mobile_image-4cb7d95d0088984440b9294193cd85d4.jpg")!
                cell.newsTitle.text = currentArticle.title
                ImageManager.shared.loadImageData(from: url) { data in
                    guard let data = data, let imageData = UIImage(data: data) else { return}
                    DispatchQueue.main.async {
                        
                        cell.articleImage.image = imageData
                        cell.articleImage.clipsToBounds.toggle()
                    }
                }
                ((indexPath.row + 1) % 2 == 0) ? (cell.backgroundColor = .black) : (cell.backgroundColor = .systemGray5)
              
            }
        }
        
        return cell
    }
    
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
    
 


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
    private func makeCompleteContextualAction(forRowAt indexPath: IndexPath) -> UIContextualAction {
        
     
        let actionTap =  UIContextualAction(style: .normal, title: nil) { (action, swipeButtonView, completion) in
            
            
            self.deleteSavedBible(at: indexPath)
            
            completion(true)
        }
      
                actionTap.image = UIImage(systemName: "trash")
                actionTap.backgroundColor = .red
                actionTap.image?.withTintColor(.green)
            
        

        
        return actionTap
    }
    
    internal func deleteSavedBible(at indexPath: IndexPath) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        guard let articleEntity = convertToBibleEntity(articles[indexPath.row], managedContext: managedContext) else { return }
        
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
    
    private func convertToBibleEntity(_ article: Article, managedContext: NSManagedObjectContext) -> Articles? {
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
