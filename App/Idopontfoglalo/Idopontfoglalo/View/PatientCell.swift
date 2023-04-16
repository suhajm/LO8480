//
//  PatientCell.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2022. 08. 11..
//

import UIKit

class PatientCell: UITableViewCell {
    
    @IBOutlet weak var profilePicture: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        profilePicture?.layer.cornerRadius = (profilePicture?.frame.size.width ?? 0.0) / 2
        profilePicture?.clipsToBounds = true
        profilePicture?.layer.borderWidth = 3.0
        profilePicture?.layer.borderColor = UIColor.red.cgColor

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
