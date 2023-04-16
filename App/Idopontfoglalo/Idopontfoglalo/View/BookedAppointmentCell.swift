//
//  BookedAppointmentCell.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2023. 02. 05..
//

import UIKit

class BookedAppointmentCell: UITableViewCell {
    
    @IBOutlet weak var doctorProfilePic: UIImageView!
    
    @IBOutlet weak var doctorName: UILabel!
    
    @IBOutlet weak var date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        doctorProfilePic?.layer.cornerRadius = (doctorProfilePic?.frame.size.width ?? 0.0) / 2
        doctorProfilePic?.clipsToBounds = true
        doctorProfilePic?.layer.borderWidth = 3.0
        doctorProfilePic?.layer.borderColor = UIColor.red.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
