//
//  Personal_InfoViewController.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2023. 02. 17..
//

import UIKit
import Firebase
import Lottie

class Personal_InfoViewController: UIViewController {
    
    private var previousUserInfo: GetUser?
    private var tajNumberCount = 0
    private var animation: LottieAnimationView?
    private var titleValue: String?
    
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var userTitle: UISegmentedControl!
    
    @IBOutlet weak var lastname: UITextField!
    
    @IBOutlet weak var firstname: UITextField!
    
    @IBOutlet weak var ill_specs: UITextField!
    
    @IBOutlet weak var taj: UITextField!
    
    @IBOutlet weak var animationView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taj.delegate = self
        initializeHideKeyboard()
        getUserInfo()
        setAnimation()
    }
    
    @IBAction func saveBtnPressed(_ sender: UIButton) {
        
        let newUserInfo = GetUser(uid: UD.shared.getUID(), role: UD.shared.getRole(), gender: previousUserInfo?.gender!, title: titleValue!, firstname: firstname.text!, lastname: lastname.text!, spec_ill: ill_specs.text!, taj: taj.text!, profilePicURL: previousUserInfo?.profilePicURL!)
        
        self.infoLabel.text = ""
        
        if newUserInfo != previousUserInfo {
            
            if !checkTextFields() {
                self.infoLabel.text = "Kérem, töltse ki az összes mezőt!"
            }
            else if (tajCheck(taj: taj.text!) == false) {
                invalidTAJ()
            } else {
                ActivityIndicator.shared.setupActivityIndicatorForMyProfile(view: self.view)
                DBHelper.shared.myProfileUpdate(title: self.titleValue!, firstname: firstname.text!, lastname: lastname.text!, spec_ill: ill_specs.text!, taj: taj.text!) {
                    (res) in
                    
                    switch res {
                    case .failure(_):
                        Alerts.unsuccess(title: "Hiba történt!", message: "Hiba történt adatai frissítése során! Kérem, próbálja meg újra!", viewController: self)
                        ActivityIndicator.shared.activityIndicator.stopAnimating()
                        self.view.isUserInteractionEnabled = true
                    case .success(_):
                        Alerts.success(title: "Sikeres módosítás!", message: "Adatait sikeresen frissítette.", viewController: self)
                        ActivityIndicator.shared.activityIndicator.stopAnimating()
                        self.view.isUserInteractionEnabled = true
                        self.previousUserInfo = newUserInfo
                    }
                    
                }
                
            }
            
        }
    }
    
    @IBAction func titlePickerValueChanged(_ sender: UISegmentedControl) {
        
        if let titleText = userTitle.titleForSegment(at: userTitle.selectedSegmentIndex) {
            
            if titleText == "Dr" {
                self.titleValue = "Dr"
            } else if titleText == "Ifj" {
                self.titleValue = "Ifj"
            } else if titleText == "" {
                self.titleValue = ""
            }
            
        }
        
    }
    
}

extension Personal_InfoViewController {
    
    private func checkTextFields() -> Bool {
        if (firstname.text! == "" || lastname.text! == "" || ill_specs.text! == "" || taj.text! == "") {
            return false
        }
        
        return true
    }
    
    private func getUserInfo() {
        
        ActivityIndicator.shared.setupActivityIndicator(view: self.view)
        DBHelper.shared.myProfileGetUserInfo() {
            (res) in
            switch res {
            case .failure(_):
                Alerts.unsuccess(title: "Hiba történt!", message: "Hiba történt adatai lekérdezése közben! Kérem, próbálja meg újra!", viewController: self)
            case .success(let user):
                self.previousUserInfo = user
                ActivityIndicator.shared.activityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
                self.updateTextFields()
            }
        }
        
    }
    
    private func setAnimation() {
        animation = .init(name: "userInfo")
        animation?.frame = animationView.bounds
        animation?.animationSpeed = 1.0
        animationView.addSubview(animation!)
        animation?.play()
    }
    
    private func updateTextFields() {
        if let userInfo = previousUserInfo {
            if userInfo.title == "Dr" {
                self.userTitle.selectedSegmentIndex = 0
                self.titleValue = "Dr"
            } else if userInfo.title == "Ifj" {
                self.userTitle.selectedSegmentIndex = 1
                self.titleValue = "Ifj"
            } else {
                self.userTitle.selectedSegmentIndex = 2
                self.titleValue = ""
            }
            lastname.text = userInfo.lastname
            firstname.text = userInfo.firstname
            ill_specs.text = userInfo.spec_ill
            taj.text = userInfo.taj
            if userInfo.role == "patient" {
                ill_specs.placeholder = "Betegségek"
            } else if userInfo.role == "doctor" {
                ill_specs.placeholder = "Szakterület"
            }
        }
    }
    
    private func invalidTAJ() {
        let alert = UIAlertController(title: "Helytelen TAJ!", message: "Kérem, ellenőrizze a megadott adatot!", preferredStyle: .alert)
        let action = UIAlertAction(title: "Rendben", style: .destructive)
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func tajCheck(taj: String) -> Bool {
        
        var sum = 0
        
        for i in 0..<taj.count-1 {
            if (i % 2 == 0) {
                let num = taj[taj.index(taj.startIndex, offsetBy: i)]
                sum = sum + (num.wholeNumberValue! * 7)
            } else {
                let num = taj[taj.index(taj.startIndex, offsetBy: i)]
                sum = sum + (num.wholeNumberValue! * 3)
            }
        }
        
        let cdv = sum % 10
        let lastNum = taj[taj.index(taj.startIndex, offsetBy: taj.count-1)].wholeNumberValue
        
        if (cdv == lastNum) {
            return true
        }
        
        return false
    }
    
}

extension Personal_InfoViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        //https://stackoverflow.com/questions/30973044/how-to-restrict-uitextfield-to-take-only-numbers-in-swift
        //https://stackoverflow.com/questions/31363216/set-the-maximum-character-length-of-a-uitextfield-in-swift
        
        let allowedCharacters = CharacterSet(charactersIn:"0123456789")
        let characterSet = CharacterSet(charactersIn: string)
        
        let maxLength = 9
        
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        
        return newString.count <= maxLength && allowedCharacters.isSuperset(of: characterSet)
    }
}
