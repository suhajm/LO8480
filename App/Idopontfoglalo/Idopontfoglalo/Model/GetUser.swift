//
//  GetUser.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2022. 10. 21..
//

import Foundation

struct GetUser: Codable, Equatable {
    
    var uid: String?
    var role: String?
    var gender: String?
    var title: String?
    var firstname: String?
    var lastname: String?
    var spec_ill: String?
    var taj: String?
    var profilePicURL: String?
}
