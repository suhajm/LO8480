//
//  ViewController.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2022. 08. 03..
//

import UIKit
import Firebase

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var welcomeLabel1: UILabel!
    @IBOutlet weak var welcomeLabel2: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        welcomeLabel1.text = ""
        var charIndex1 = 0.0
        let titleText1 = K.welcomeString1
        for letter in titleText1 {
            Timer.scheduledTimer(withTimeInterval: 0.08 * charIndex1, repeats: false) { timer in
                self.welcomeLabel1.text?.append(letter)
            }
            charIndex1 += 1
        }
        
        welcomeLabel2.text = ""
        var charIndex2 = 0.0
        let titleText2 = K.welcomeString2
        for letter in titleText2 {
            Timer.scheduledTimer(withTimeInterval: 0.05 * charIndex2, repeats: false) { timer in
                self.welcomeLabel2.text?.append(letter)
            }
            charIndex2 += 1
        }
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: "loginSegue", sender: self)
        
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: "registerSegue", sender: self)
        
    }
}

