//
//  RegisterViewController.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2022. 08. 04..
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var eyeButton: UIButton!
    
    @IBOutlet weak var rolePicker: UISegmentedControl!
    
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
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        
        self.infoLabel.text = ""
        
        ActivityIndicator.shared.setupActivityIndicatorForRegister(view: self.view)
        
        let role = self.rolePickerCheck()
        let gender = self.genderPickerCheck()
        let title = titlePickerCheck()
        let error = validateTextfields()
        
        let firstname = self.firstnameText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastname = self.lastnameText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = self.emailText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = self.passwordText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if role == "" {
            ActivityIndicator.shared.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            self.infoLabel.text = "Kérem, válasszon szerepkört!"
        }
        else if gender == "" {
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
            
            DBHelper.shared.register(email: email, password: password, firstname: firstname, lastname: lastname, gender: gender, role: role, title: title) {
                (res) in
                
                switch res {
                case .failure(let error):
                    ActivityIndicator.shared.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    self.firebaseErrorTranslate(error: error.localizedDescription)
                case .success(_):
                    ActivityIndicator.shared.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    self.success()
                }
                
            }
        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loginAfterRegister" {
            let destinationVC = segue.destination as! LoginViewController
            destinationVC.navigationItem.hidesBackButton = true
        }
    }
    
}

extension RegisterViewController {
    
    private func titlePickerCheck() -> String {
        return titlePicker.titleForSegment(at: titlePicker.selectedSegmentIndex)!
    }
    
    private func rolePickerCheck() -> String {
        if var role = rolePicker.titleForSegment(at: rolePicker.selectedSegmentIndex) {
            if role == "Orvos" {
                role = "doctor"
            } else if role == "Páciens" {
                role = "patient"
            }
            else {
                role = ""
            }
            
            return role
        }
        
        return ""
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
        
        if error == "The email address is badly formatted." {
            self.infoLabel.text = "Az email cím formátuma nem megfelelő."
        }
        
    }
    
    private func success() {
        let alert = UIAlertController(title: "Sikeres regisztráció!", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Rendben", style: .default) { (action) in
            
            let role = UD.shared.getRole()
            if role == "admin" {
                self.performSegue(withIdentifier: "adminLogin", sender: self)
            } else if role == "patient" {
                self.performSegue(withIdentifier: "patientLogin", sender: self)
            } else if role == "doctor" {
                self.performSegue(withIdentifier: "doctorLogin", sender: self)
            }

        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
}
