//
//  LoginViewController.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2022. 08. 03..
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var emailText: UITextField!
    
    @IBOutlet weak var passwordText: UITextField!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var eyeButton: UIButton!
    
    var reAuth = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeHideKeyboard()
        infoLabel.text = ""
        navigationController?.navigationBar.tintColor = UIColor(named: "White")
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        self.infoLabel.text = ""
        
        ActivityIndicator.shared.setupActivityIndicatorForLogin(view: self.view)
        
        let email = self.emailText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = self.passwordText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if email == "" && password == "" {
            ActivityIndicator.shared.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            self.infoLabel.text = "Kérem, töltse ki a mezőket!"
        } else {
            
            if !reAuth {
                DBHelper.shared.login(viewController: self, email: email, password: password) {
                    (res) in
                    
                    switch res {
                    case .failure(let error):
                        ActivityIndicator.shared.activityIndicator.stopAnimating()
                        self.view.isUserInteractionEnabled = true
                        self.firebaseErrorTranslate(error: error.localizedDescription)
                        
                    case .success(let res):
                        ActivityIndicator.shared.activityIndicator.stopAnimating()
                        self.view.isUserInteractionEnabled = true
                        if res == "admin" {
                            self.performSegue(withIdentifier: "adminTabBar", sender: self)
                        } else if res == "doctor" {
                            self.performSegue(withIdentifier: "loggedinDoctor", sender: self)
                        } else if res == "patient" {
                            self.performSegue(withIdentifier: "loggedinPatient", sender: self)
                        }
                    }
                }
            } else {
                DBHelper.shared.auth(email: email, password: password) { (res) in
                    switch res {
                    case .failure(_):
                        ActivityIndicator.shared.activityIndicator.stopAnimating()
                        self.view.isUserInteractionEnabled = true
                        Alerts.resultThenDismiss(viewController: self, title: "Sikertelen művelet!", message: "Hiba történt!")
                    case .success(_):
                        ActivityIndicator.shared.activityIndicator.stopAnimating()
                        self.view.isUserInteractionEnabled = true
                        Alerts.authSuccessPostObserver(viewController: self, title: "Sikeres művelet!", message: "Sikeresen igazolta magát!")
                    }
                }
            }
            
        }
       
    }
    
    @IBAction func forgottenPasswordBtnPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "resetPassword", sender: self)
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func eyeButtonPressed(_ sender: UIButton) {
        
        if passwordText.isSecureTextEntry == true {
            passwordText.isSecureTextEntry = false
            eyeButton.setImage(UIImage(systemName: "eye"), for: .normal)
        } else {
            passwordText.isSecureTextEntry = true
            eyeButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        }
    }
}

extension LoginViewController {
    
    private func firebaseErrorTranslate(error: String) {
        if error == "The email address is badly formatted." {
            self.infoLabel.text = "Az email cím formátuma nem megfelelő."
        } else if error == "The password is invalid or the user does not have a password." {
            self.infoLabel.text = "Helytelen jelszó."
        } else if error == "There is no user record corresponding to this identifier. The user may have been deleted." {
            self.infoLabel.text = "Felhasználó nem létezik a megadott adatokkal."
        }
    }
    
}
