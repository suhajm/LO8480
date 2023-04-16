//
//  UD.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2022. 11. 14..
//

import Foundation

class UD {
    
    static let shared = UD()
    
    let defaults = UserDefaults.standard
    
    func getUID() -> String {
        
        if let role = defaults.string(forKey: "uid")
        {
            return role
        }
        
        return ""
    }
    
    func getRole() -> String {
        
        if let role = defaults.string(forKey: "role")
        {
            return role
        }
        
        return ""
    }
}
