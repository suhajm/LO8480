//
//  ActivityIndicator.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2023. 02. 06..
//

import Foundation
import UIKit

class ActivityIndicator {
    
    static let shared = ActivityIndicator()
    
    let activityIndicator = UIActivityIndicatorView()
    
    func setupActivityIndicator(view: UIView) {
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        activityIndicator.color = UIColor.red
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
    }
    
    func setupActivityIndicatorForLogin(view: UIView) {
        activityIndicator.center = CGPoint(x:view.frame.size.width / 2, y: view.frame.size.height - view.frame.size.height / 6)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        activityIndicator.color = UIColor.red
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
    }
    
    func setupActivityIndicatorForRegister(view: UIView) {
        activityIndicator.center = CGPoint(x:view.frame.size.width / 2, y: view.frame.size.height - view.frame.size.height / 12)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        activityIndicator.color = UIColor.red
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
    }
    
    func setupActivityIndicatorForMyProfile(view: UIView) {
        activityIndicator.center = CGPoint(x:view.frame.size.width / 2, y: view.frame.size.height - view.frame.size.height / 6)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        activityIndicator.color = UIColor.red
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
    }
    
}
