//
//  AdminAddAdminViewController.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2023. 03. 25..
//

import UIKit

class AdminAddAdminViewController: ViewController {
    
    @IBOutlet weak var eyeButton: UIButton!
    @IBOutlet weak var lastnameText: UITextField!
    @IBOutlet weak var firstnameText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var genderPicker: UISegmentedControl!
    @IBOutlet weak var titlePicker: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeHideKeyboard()
        
        infoLabel.text = ""
        navigationController?.navigationBar.tintColor = UIColor(named: "White")
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        
        self.infoLabel.text = ""
        
        ActivityIndicator.shared.setupActivityIndicatorForMyProfile(view: self.view)
        
        let gender = self.genderPickerCheck()
        let title = titlePickerCheck()
        let error = validateTextfields()
        
        let firstname = self.firstnameText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastname = self.lastnameText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = self.emailText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = self.passwordText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if gender == "" {
            ActivityIndicator.shared.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            self.infoLabel.text = "Kérem, válassza ki a nemét!"
        }
        else if error != nil {
            ActivityIndicator.shared.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            infoLabel.text = error
        }
        else {
            
            DBHelper.shared.adminAddAdmin(gender: gender, title: title, firstname: firstname, lastname: lastname, email: email, password: password) {
                (res) in
                
                switch res {
                case .failure(let error):
                    DispatchQueue.main.async {
                        ActivityIndicator.shared.activityIndicator.stopAnimating()
                        self.view.isUserInteractionEnabled = true
                        self.firebaseErrorTranslate(error: error.localizedDescription)
                    }
                case .success(_):
                    DispatchQueue.main.async {
                        ActivityIndicator.shared.activityIndicator.stopAnimating()
                        self.view.isUserInteractionEnabled = true
                        self.success()
                    }
                }
                
            }
        }
        
    }
    
    @IBAction func manageAdminsBtnPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "manageAdmins", sender: self)
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

extension AdminAddAdminViewController {
    
    private func titlePickerCheck() -> String {
        return titlePicker.titleForSegment(at: titlePicker.selectedSegmentIndex)!
    }
    
    private func genderPickerCheck() -> String {
        if var gender = genderPicker.titleForSegment(at: genderPicker.selectedSegmentIndex) {
            if gender == "Férfi" {
                gender = "male"
            } else if gender == "Nő" {
                gender = "female"
            }
            else {
                gender = ""
            }
            
            return gender
        }
        
        return ""
    }
    
    private func validateTextfields() -> String? {
        
        if lastnameText.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || firstnameText.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailText.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordText.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Kérem, töltse ki az összes mezőt!"
            
        }
        
        if let password = passwordText.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            if password.count < 8 {
                return "A jelszó legalább 8 karakter!"
            }
        }
        
        return nil
    }
    
    private func firebaseErrorTranslate(error: String) {
        
        if error == "There is no user who has the given uid!" {
            self.infoLabel.text = "Nem létezik felhasználó a megadott uid-val!"
        } else if error == "Error creating new user" {
            self.infoLabel.text = "Felhasználó létrehozása sikertelen!"
        } else if error == "Invalid token!" {
            self.infoLabel.text = "Helytelen token!"
        }
        
    }
    
    private func success() {
        Alerts.success(title: "Sikeres hozzáadás!", message: "Admin sikeresen hozzáadva!", viewController: self)
        self.genderPicker.selectedSegmentIndex = 2
        self.titlePicker.selectedSegmentIndex = 2
        self.lastnameText.text = ""
        self.firstnameText.text = ""
        self.emailText.text = ""
        self.passwordText.text = ""
    }
    
}
