//
//  RatingsTableViewCell.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2023. 02. 12..
//

import UIKit

class RatingsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var ratingText: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet var starImageCollection: [UIImageView]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setStars(rating: Int) {
        for starImage in starImageCollection {
            let imageName = (starImage.tag < rating ? "star.fill" : "star")
            starImage.image = UIImage(systemName: imageName)
            starImage.tintColor = (starImage.tag < rating ? .systemRed : .systemRed)
        }
    }
}
