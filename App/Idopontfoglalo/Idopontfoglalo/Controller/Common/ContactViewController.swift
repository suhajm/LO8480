//
//  ContactViewController.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2023. 02. 17..
//  Observer: https://www.youtube.com/watch?v=srqiDnLEocA
//

import UIKit
import Lottie
import Firebase

class ContactViewController: UIViewController {
    
    private var contact: Contact?
    
    private var previousEmail: String?
    private var previousPhone: String?
    private var name = Notification.Name("authSuccess")
    private var isEmailVerified: Bool?
    private var animation: LottieAnimationView?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBOutlet weak var emailVerifiedImage: UIImageView!
    
    @IBOutlet weak var resendVerificationBtn: UIButton!
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var phone: UITextField!
    
    @IBOutlet weak var animationView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phone.delegate = self
        initializeContact()
        createObservers()
        setAnimation()
    }

    @IBAction func saveBtnPressed(_ sender: UIButton) {
        
        ActivityIndicator.shared.setupActivityIndicatorForMyProfile(view: self.view)
        
        if previousEmail != email.text! && previousPhone != phone.text! {

            DBHelper.shared.myProfileUpdatePhoneNumber(email: email.text!, phone: "+36\(phone.text!)") {
                (res) in
                
                switch res {
                case .failure(_):
                    Alerts.unsuccess(title: "Hiba történt!", message: "Hiba történt az adatok módosításakor! Kérem, próbálja meg újra!", viewController: self)
                    ActivityIndicator.shared.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                case .success(_):
                    Alerts.warningThenSegue(viewController: self, title: "Figyelem!", message: "Az email cím módosítása előtt igazolnia kell magát! Az email cím mezőbe az előző email címét írja be, ne azt, amire módosítani kívánja!", segueIdentifier: "toAuth")
                }
                
            }
        } else if previousPhone != "+36\(phone.text!)" || previousPhone != nil {
            
            DBHelper.shared.myProfileUpdatePhoneNumber(email: email.text!, phone: "+36\(phone.text!)") {
                (res) in
                
                switch res {
                case .failure(_):
                    Alerts.unsuccess(title: "Hiba történt!", message: "Hiba történt az adatok módosításakor! Kérem, próbálja meg újra!", viewController: self)
                    ActivityIndicator.shared.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                case .success(_):
                    ActivityIndicator.shared.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    Alerts.success(title: "Sikeres módosítás!", message: "Adatait sikeresen frissítette.", viewController: self)
                }
                
            }
        } else if previousEmail != email.text! {
            Alerts.warningThenSegue(viewController: self, title: "Figyelem!", message: "Az email cím módosítása előtt igazolnia kell magát! Az email cím mezőbe az előző email címét írja be, ne azt, amire módosítani kívánja!", segueIdentifier: "toAuth")
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAuth" {
            let destinationVC = segue.destination as! LoginViewController
            destinationVC.reAuth = true
        }
    }
    
    @IBAction func resendVerificationBtnPressed(_ sender: UIButton) {
        
        DBHelper.shared.verifyEmail() {
            (res) in
            
            switch res {
            case .failure(_):
                Alerts.unsuccess(title: "Hiba történt!", message: "A megerősítő email küldése nem sikerült!", viewController: self)
            case .success(_):
                Alerts.success(title: "Sikeres megerősítő email igénylés!", message: "A megerősítő email küldése sikeres volt! Megerősítés után jelentkezzen be újra!", viewController: self)
            }
            
        }
        
    }
    
}

extension ContactViewController {
    
    private func setAnimation() {
        animation = .init(name: "contact")
        animation?.frame = animationView.bounds
        animation?.animationSpeed = 1.0
        animation?.loopMode = .loop
        animationView.addSubview(animation!)
        animation?.play()
    }
    
    private func createObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(ContactViewController.updateEmail(notification:)), name: name, object: nil)
        
    }
    
    @objc
    private func updateEmail(notification: NSNotification) {
        if notification.name == name {
            DBHelper.shared.myProfileUpdateEmail(email: email.text!) {
                (res) in
                switch res {
                case .failure(_):
                    Alerts.unsuccess(title: "Hiba történt!", message: "Hiba történt az adatok módosításakor! Kérem, próbálja meg újra!", viewController: self)
                case .success(_):
                    ActivityIndicator.shared.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    Alerts.success(title: "Sikeres módosítás!", message: "Adatait sikeresen frissítette.", viewController: self)
                }
            }
        }
    }
    
    private func initializeContact() {
        ActivityIndicator.shared.setupActivityIndicatorForMyProfile(view: self.view)
        DBHelper.shared.patientGetContact() { res in
            switch res {
            case .failure(_):
                Alerts.unsuccess(title: "Hiba történt!", message: "Hiba történt adatai betöltése során! Kérem, próbálja meg újra!", viewController: self)
            case .success(let contact):
                self.contact = contact
                self.isEmailVerified = Auth.auth().currentUser?.isEmailVerified
                self.updateTextfields()
                ActivityIndicator.shared.activityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
            }
        }
    }
    
    private func updateTextfields() {
        if isEmailVerified! {
            self.resendVerificationBtn.isHidden = true
            self.emailVerifiedImage.image = UIImage(systemName: "checkmark.shield")
        } else {
            self.resendVerificationBtn.isHidden = false
            self.emailVerifiedImage.image = UIImage(systemName: "xmark.shield")
        }
        email.text = contact?.email
        self.previousEmail = contact?.email
        self.previousPhone = contact?.phone
        if var phoneNumber = contact?.phone {
            phoneNumber = String(phoneNumber.dropFirst(3))
            phone.text = phoneNumber
        }
    }
    
}

extension ContactViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let allowedCharacters = CharacterSet(charactersIn:"0123456789")
        let characterSet = CharacterSet(charactersIn: string)
        
        let maxLength = 9
        
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        
        return newString.count <= maxLength && allowedCharacters.isSuperset(of: characterSet)
    }
    
}
