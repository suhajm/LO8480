//
//  Rating.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2023. 02. 12..
//

import Foundation

struct Rating: Codable {
    
    var uid: String?
    var rate: Int?
    var doctorID: String?
    var patientID: String?
    var patientName: String?
    var rateTitle: String?
    var rateText: String?
    
}
