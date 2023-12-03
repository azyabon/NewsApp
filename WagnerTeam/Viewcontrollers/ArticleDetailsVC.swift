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
    //вывод всего
    func setupUI() {
        guard let article = article else {
            return
        }
        if let imageData = article.image {
            articleImage.image = UIImage(data: imageData)
        }
        
        var str = article.content ?? "WGNR"
        str = removeTextAfterBracket(text: str)
        descriptionLabel.text = str
        titleLabel.text = article.title
        titleLabel.sizeToFit()
      
    }
    
    //убираем мусор
    func removeTextAfterBracket(text: String) -> String {
        if let range = text.range(of: "[") {
            let index = text.distance(from: text.startIndex, to: range.lowerBound)
            return String(text.prefix(upTo: text.index(text.startIndex, offsetBy: index)))
        }
        return text
    }

    
}
