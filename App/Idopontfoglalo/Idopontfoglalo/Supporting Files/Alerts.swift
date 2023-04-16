//
//  Alerts.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2023. 02. 05..
//

import Foundation
import UIKit

class Alerts {
    static func unsuccess(title: String, message: String, viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Rendben", style: .destructive)
        
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    static func success(title: String, message: String, viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Rendben", style: .destructive)
        
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    static func fillIn(viewController: UIViewController) {
        let alert = UIAlertController(title: "Kérem, töltse ki az összes mezőt!", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Rendben", style: .destructive)
        
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    static func resultThenDismiss(viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Rendben", style: .destructive) { (action) in
            viewController.dismiss(animated: true)
        }
        
        alert.addAction(action)
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    static func warningThenSegue(viewController: UIViewController, title: String, message: String, segueIdentifier: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Rendben", style: .destructive) { (action) in
            
            viewController.performSegue(withIdentifier: segueIdentifier, sender: self)
            
        }
        alert.addAction(action)
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    static func authSuccessPostObserver(viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Rendben", style: .destructive) { (action) in
            
            let name = Notification.Name("authSuccess")
            NotificationCenter.default.post(name: name, object: nil)
            viewController.dismiss(animated: true)
        }
        
        alert.addAction(action)
        
        viewController.present(alert, animated: true, completion: nil)
    }

}
