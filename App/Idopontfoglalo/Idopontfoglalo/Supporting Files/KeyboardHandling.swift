//
//  KeyboardHandling.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2023. 02. 10..
//

import Foundation
import UIKit

// https://nqaze.medium.com/keyboard-handling-in-ios-swift-5-8b60d602a8f

extension UIViewController {
    
    func initializeHideKeyboard(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissMyKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissMyKeyboard(){
        view.endEditing(true)
    }
    
}
