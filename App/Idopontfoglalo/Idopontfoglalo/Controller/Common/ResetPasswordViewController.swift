//
//  ResetPasswordViewController.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2023. 02. 23..
//

import UIKit
import Lottie

class ResetPasswordViewController: UIViewController {
    
    @IBOutlet weak var animationView: UIView!
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    private var animation: LottieAnimationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAnimation()
    }
    
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        
        self.infoLabel.text = ""
        
        ActivityIndicator.shared.setupActivityIndicatorForLogin(view: self.view)
        
        if checkEmailTxtField() {
            DBHelper.shared.resetPassword(email: email.text!) {
                (res) in
                
                switch res {
                case .failure(let error):
                    ActivityIndicator.shared.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    print(error.localizedDescription)
                    self.firebaseErrorTranslate(error: error.localizedDescription)
                case .success(_):
                    ActivityIndicator.shared.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    Alerts.success(title: "Sikeres jelszómódosítási kérelem!", message: "Kérem, ellenőrizze bejövő emailjeit!", viewController: self)
                }
                
            }
        }
        
    }
    
}

extension ResetPasswordViewController {
    
    private func setAnimation() {
        animation = .init(name: "forgotten_password")
        animation?.frame = animationView.bounds
        animation?.loopMode = .loop
        animation?.animationSpeed = 1.0
        animationView.addSubview(animation!)
        animation?.play()
    }
    
    private func checkEmailTxtField() -> Bool {
        if self.email.text! == "" {
            self.infoLabel.text = "Az email cím mező nem lehet üres!"
            return false
        }
        
        return true
    }
    
    private func firebaseErrorTranslate(error: String) {
        
        if error == "The email address is badly formatted." {
            self.infoLabel.text = "Az email cím formátuma nem megfelelő."
        } else if error == "There is no user record corresponding to this identifier. The user may have been deleted." {
            self.infoLabel.text = "A megadott email címmel nem létezik felhasználó."
        }
        
    }
    
}
