//
//  ViewController.swift
//  WagnerTeam
//
//  Created by Сергей Кудинов on 07.11.2023.
//

import UIKit

class ArticleDetailsVC: UIViewController {

   
    @IBOutlet weak var articleImage: UIImageView!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    var article: Article?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }


}

extension ArticleDetailsVC {
    func setupUI() {
        guard let article = article else {
            return
        }
        if let imageData = article.image {
            articleImage.image = UIImage(data: imageData)
        }
        descriptionLabel.text = article.description ?? "hello from E. Prigozhin"
        titleLabel.text = article.title
      
    }
}
