//
//  TopNewsTableVC.swift
//  WagnerTeam
//
//  Created by Сергей Кудинов on 08.11.2023.
//

import CoreData
import UIKit

class TopNewsTableVC: UITableViewController {
  
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var articles: [Article] = []
    var articlesCopy: [Article] = []
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.showsVerticalScrollIndicator.toggle()
        fetchTopStories()
        setupSearchController()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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

   //выводим ячейку по заранее созданному классу ячейки
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell") as! NewsCell
        if articles.count >= indexPath.row {
            var currentArticle = articles[indexPath.row]
            cell.newsTitle.text = currentArticle.title
            
            if let imageData = currentArticle.image  { cell.articleImage.image = UIImage(data: imageData) }
            
            else {
            if let url = currentArticle.urlToImage {
                let url = URL(string: url) ?? URL(string: "https://api.nsn.fm/storage/medialib/377901/mobile_image-4cb7d95d0088984440b9294193cd85d4.jpg")!
                //получение картинки
                ImageManager.shared.loadImageData(from: url) { data in
                    guard let data = data, let imageData = UIImage(data: data) else { return}
                    
                    DispatchQueue.main.async {
                     
                   
                        cell.articleImage.image = imageData
                        cell.articleImage.clipsToBounds.toggle()
                        currentArticle.image = data
                        if indexPath.row < self.articles.count {
                            self.articles[indexPath.row] = currentArticle
                        }
                        }
                }
                //че то типо дизайна черно бели
                ((indexPath.row + 1) % 2 == 0) ? (cell.backgroundColor = .black) : (cell.backgroundColor = .systemGray5)
               
            }
        }
        }
        
        return cell
    }
    

    //рассчитываем высоту ячейки
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = UITableView.automaticDimension
        if height > 100 {
            return height
        } else {
            return 126
        }
       // UITableView.automaticDimension
    }
    //мин высота
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        114
    }
    
 
    //вообще тут тупо для селекта, но сделал вызов алерта с кнопочками выбрать или сохранить
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        index = indexPath.row
        singleTapped(index: indexPath.row)
        
    }


    
}
// MARK: - Network funcs
extension TopNewsTableVC {
    //загрузка историй с апихи
     func fetchTopStories() {
        NetworkManager.shared.getTopStories { [weak self ] result in
            switch result {
            case .success(let articles):
                //функционалкой прогоняем ответ и пихаем его в массив таких же артиклов
                self?.articles = articles.compactMap({
                    Article(source: nil, title: $0.title, description: $0.content, url: nil, urlToImage: $0.urlToImage, publishedAt: $0.publishedAt, content: $0.content, image: nil)
                })
                self?.articlesCopy = self?.articles ?? []
                //по загрузке перегружаем вьюху для вывода
                DispatchQueue.main.async {
               
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    //поиск почти то еж самое что загрузка
    func searchBarSearchButtonClicked(_ searchBarText: String) {
        if searchBarText.isEmpty  {
            return
        }
        
        NetworkManager.shared.search(with: searchBarText) { [weak self] result in
            switch result {
            case .success(let articles):
                
               // self?.articles = articles
                
                    self?.articles = articles.compactMap({
                        Article(source: nil, title: $0.title, description: $0.content, url: nil, urlToImage: $0.urlToImage, publishedAt: $0.publishedAt, content: $0.content, image: nil)
                    })
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                  //  self?.searchVC.dismiss(animated: true, completion: nil)
                }
                
            case .failure(let error):
                print(error)
            }
        }
        
    }
}

// - MARK: Tab bar config
// расширка для конфигурации
extension TopNewsTableVC: UISearchResultsUpdating {
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search news"
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text ?? ""
        if text.isEmpty {
            articles = articlesCopy
            tableView.reloadData()
        } else {
            searchBarSearchButtonClicked(searchController.searchBar.text ?? "")
        }
    }
}


extension TopNewsTableVC {
    //тот самый метод с алертом и кнопками
    func singleTapped(index: Int) {
       
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            CoreDataManager.shared.SaveArticleToCoreData(article: self.articles[index])
        }
        
        let openAction = UIAlertAction(title: "Open", style: .default) { action in
            self.performSegue(withIdentifier: "NetworkSegue", sender: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
       
        alertController.addAction(openAction)
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)

    }
    

   //загрузка кордаты
    public func fetchSavedArticlesFromCoredata() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Articles> = Articles.fetchRequest()
        
        do {
            let results = try managedContext.fetch(fetchRequest)
           

                   for article in results {
                       let currentArticle = Article(source: nil, title: article.title ?? "", description: article.subtitle ?? "", url: nil, urlToImage: article.imageURL, publishedAt: nil, content: article.content, image: nil)
                       print(currentArticle.title)
                       
//                       DispatchQueue.main.async {
//                           self.tableView.reloadData()
//                       }
                       
                   }
        } catch {
            print("Failed to fetch articles: \(error)")
        }
    }
}


extension TopNewsTableVC {
    //переход к деталке с передачей статьи
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                if segue.identifier == "NetworkSegue" {
                    let vc = segue.destination as! ArticleDetailsVC
                    vc.article = articles[index]
                }
    }
    
    

}

