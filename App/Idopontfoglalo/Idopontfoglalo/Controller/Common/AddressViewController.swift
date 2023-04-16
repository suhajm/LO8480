//
//  AddressViewController.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2023. 02. 17..
//  Keyboard: https://stackoverflow.com/questions/26070242/move-view-with-keyboard-using-swift
//

import UIKit
import Lottie

class AddressViewController: UIViewController {
    
    private var prevoiusAddress: GetAddress?
    private var animation: LottieAnimationView?
    
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var animationView: UIView!
    
    @IBOutlet weak var country: UITextField!
    
    @IBOutlet weak var state: UITextField!
    
    @IBOutlet weak var zipcode: UITextField!
    
    @IBOutlet weak var city: UITextField!
    
    @IBOutlet weak var street: UITextField!
    
    @IBOutlet weak var house: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        initializeAddress()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeHideKeyboard()
        zipcode.delegate = self
        house.delegate = self

        setAnimation()
    }
    
    @IBAction func saveBtnPressed(_ sender: UIButton) {
        
        self.infoLabel.text = ""
        
        let newAddress = GetAddress(city: self.city.text!, country: self.country.text!, house: self.house.text!, state: self.state.text!, street: self.street.text!, uid: UD.shared.getUID(), postcode: self.zipcode.text!)
        
        if !checkTextFields() {
            self.infoLabel.text = "Kérem, töltse ki az összes mezőt!"
        } else if newAddress != prevoiusAddress {
            
            ActivityIndicator.shared.setupActivityIndicatorForRegister(view: self.view)
            DBHelper.shared.myProfileUpdateAddresses(country: country.text!, state: state.text!, zipcode: zipcode.text!, city: city.text!, street: street.text!, house: house.text!) {
                (res) in
                
                switch res {
                case .failure(_):
                    Alerts.unsuccess(title: "Hiba történt!", message: "Hiba történt adatai frissítése során! Kérem, próbálja meg újra!", viewController: self)
                    ActivityIndicator.shared.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                case .success(_):
                    Alerts.success(title: "Sikeres módosítás!", message: "Adatait sikeresen módosította!", viewController: self)
                    ActivityIndicator.shared.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    self.prevoiusAddress = newAddress
                }
                
            }
            
        }
        
    }
    
}

extension AddressViewController {
    
    private func checkTextFields() -> Bool {
        if (self.country.text! == "" || self.state.text! == "" || self.zipcode.text! == "" || self.city.text! == "" || self.street.text! == "" || self.house.text! == "") {
            return false
        }
        
        return true
    }
    
    private func setAnimation() {
        animation = .init(name: "address")
        animation?.frame = animationView.bounds
        animation?.loopMode = .loop
        animation?.animationSpeed = 1.0
        animationView.addSubview(animation!)
        animation?.play()
    }
    
    private func updateTextFields() {
        country.text = prevoiusAddress?.country
        state.text = prevoiusAddress?.state
        zipcode.text = prevoiusAddress?.postcode
        city.text = prevoiusAddress?.city
        street.text = prevoiusAddress?.street
        house.text = prevoiusAddress?.house
    }
    
    private func initializeAddress() {
        
        ActivityIndicator.shared.setupActivityIndicator(view: self.view)
        DBHelper.shared.myProfileGetAddress() {
            (res) in
            
            switch res {
            case .failure(_):
                Alerts.unsuccess(title: "Hiba történt!", message: "Hiba történt adatai lekérdezése során! Kérem, próbálja meg újra!", viewController: self)
            case .success(let address):
                self.prevoiusAddress = address
                ActivityIndicator.shared.activityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
                self.updateTextFields()
            }
            
        }
        
    }
    
}

extension AddressViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let allowedCharacters = CharacterSet(charactersIn:"0123456789 ")
        let characterSet = CharacterSet(charactersIn: string)
        
        var maxLength = 0
        
        if textField == zipcode {
            maxLength = 4
        } else if textField == house {
            maxLength = 3
        }
        
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        
        return newString.count <= maxLength && allowedCharacters.isSuperset(of: characterSet)
    }
}
