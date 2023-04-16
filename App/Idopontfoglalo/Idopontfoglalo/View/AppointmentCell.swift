//
//  AppointmentCell.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2022. 08. 23..
//

import UIKit

class AppointmentCell: UITableViewCell {
    
    @IBOutlet weak var time: UILabel!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var profilePicture: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
