//
//  AdminTabBarController.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2022. 08. 05..
//

import UIKit
import Firebase

class AdminTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.setHidesBackButton(true, animated: true)
        
        self.tabBar.unselectedItemTintColor = UIColor.black
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.tintColor = .white
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIBarButtonItem) {
        
        UD.shared.defaults.removeObject(forKey: "uid")
        UD.shared.defaults.removeObject(forKey: "role")
        
        do {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "adminLogout", sender: self)
        } catch {
            Alerts.unsuccess(title: "Hiba történt!", message: "Hiba történt a kijelentkezés során!", viewController: self)
        }
        
    }
    
}
