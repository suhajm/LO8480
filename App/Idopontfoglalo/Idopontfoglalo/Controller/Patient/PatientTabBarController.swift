//
//  PatientTabBarController.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2022. 08. 05..
//

import UIKit
import Firebase

class PatientTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.setHidesBackButton(true, animated: true)
        
        if #available(iOS 15, *) {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.backgroundColor = .systemRed
            tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
            tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.black]
            tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.black
            tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
            tabBar.standardAppearance = tabBarAppearance
            tabBar.scrollEdgeAppearance = tabBarAppearance
        }
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIBarButtonItem) {
        
        UD.shared.defaults.removeObject(forKey: "uid")
        UD.shared.defaults.removeObject(forKey: "role")
        
        do {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "logoutPatient", sender: self)
        } catch {
            Alerts.unsuccess(title: "Hiba történt!", message: "A kijelentkezés nem sikerült!", viewController: self)
        }
        
    }
    
}
