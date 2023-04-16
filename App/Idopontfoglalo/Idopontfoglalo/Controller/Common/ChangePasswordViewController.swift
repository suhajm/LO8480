//
//  ChangePasswordViewController.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2022. 08. 10..
//

import UIKit
import Firebase
import Lottie

class ChangePasswordViewController: UIViewController {
    
    private var name = Notification.Name("authSuccess")
    private var password: String?
    @IBOutlet weak var infoLabel: UILabel!
    private var animation: LottieAnimationView?
    
    @IBOutlet weak var animationView: UIView!
    
    @IBOutlet weak var eyeButton: UIButton!
    
    @IBOutlet weak var newPassword: UITextField!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeHideKeyboard()
        createObservers()
        setAnimation()
    }
    
    @IBAction func changePasswordButtonPressed(_ sender: UIButton) {
        
        password = self.newPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if passwordCheck(password: password!) {
            Alerts.warningThenSegue(viewController: self, title: "Figyelem!", message: "A jelszó módosítása előtt igazolnia kell magát!", segueIdentifier: "toAuth")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAuth" {
            let destinationVC = segue.destination as! LoginViewController
            destinationVC.reAuth = true
        }
    }
    
    @IBAction func eyeButtonPressed(_ sender: UIButton) {
        
        if newPassword.isSecureTextEntry == true {
            newPassword.isSecureTextEntry = false
            eyeButton.setImage(UIImage(systemName: "eye"), for: .normal)
        } else {
            newPassword.isSecureTextEntry = true
            eyeButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        }
        
    }
    
}

extension ChangePasswordViewController {
    
    private func passwordCheck(password: String) -> Bool {
        if password == "" {
            self.infoLabel.text = "A jelszó mező nem lehet üres!"
            return false
        } else if password.count < 8 {
            self.infoLabel.text = "A jelszó legalább 8 karakter!"
            return false
        }
        
        return true
    }
    
    private func setAnimation() {
        animation = .init(name: "password")
        animation?.frame = animationView.bounds
        animation?.animationSpeed = 1.0
        animation?.loopMode = .loop
        animationView.addSubview(animation!)
        animation?.play()
    }
    
    private func createObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChangePasswordViewController.updatePassword(notification:)), name: name, object: nil)
        
    }
    
    @objc
    private func updatePassword(notification: NSNotification) {
        if notification.name == name {
            DBHelper.shared.updatePassword(password: password!) {
                (res) in
                switch res {
                case .failure(_):
                    Alerts.unsuccess(title: "Hiba történt!", message: "Jelszavát nem sikerült frisssíteni! Kérem, próbálja meg újra!", viewController: self)
                case .success(_):
                    Alerts.success(title: "Sikeres jelszócsere!", message: "Jelszavát sikeresen frissítette.", viewController: self)
                }
            }
        }
    }
    
}
