//
//  NewsCell.swift
//  WagnerTeam
//
//  Created by Сергей Кудинов on 08.11.2023.
//

import UIKit

class NewsCell: UITableViewCell {

    @IBOutlet weak var newsTitle: UILabel!
   
    @IBOutlet weak var articleImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 12;
        articleImage.layer.cornerRadius = 12
     //   self.layer.MaskToBounds = YES;
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
