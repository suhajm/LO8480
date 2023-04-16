//
//  PatientProfileViewController.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2023. 01. 30..
//

import UIKit
import MessageUI

class PatientProfileViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var profilePicture: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var spec: UILabel!
        
    @IBOutlet weak var phone: UILabel!
    
    @IBOutlet weak var email: UILabel!
    
    @IBOutlet weak var country: UILabel!
    
    @IBOutlet weak var postcode_city: UILabel!
    
    @IBOutlet weak var street: UILabel!
    
    @IBOutlet weak var house: UILabel!
    
    @IBOutlet weak var emailBtn: UIButton!
    
    private var patient: GetUser?
    private var address: GetAddress?
    private var contact: Contact?
    private var backButtonisHidden = true

    override func viewDidLoad() {
        super.viewDidLoad()
        loadInfo()
        if backButtonisHidden {
            self.backButton.isHidden = true
        } else {
            self.backButton.isHidden = false
        }
        
        if UD.shared.getRole() == "admin" {
            emailBtn.isHidden = true
        }
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    private func loadInfo() {
        
        if let url = URL(string: patient!.profilePicURL!) {
            profilePicture.kf.indicatorType = .activity
            profilePicture.kf.setImage(with: url, options: [.transition(.flipFromLeft(0.5))])
        }
        profilePicture?.layer.cornerRadius = (profilePicture?.frame.size.width ?? 0.0) / 2
        profilePicture?.clipsToBounds = true
        profilePicture?.layer.borderWidth = 3.0
        profilePicture?.layer.borderColor = UIColor.red.cgColor
        if let title = patient!.title {
            name.text = title + " " + patient!.lastname! + " " + patient!.firstname!
        } else {
            name.text = patient!.lastname! + " " + patient!.firstname!
        }
        
        
        if patient!.spec_ill == nil {
            spec.text = "Nincs megjeleníthető adat."
        } else {
            spec.text = " " + patient!.spec_ill!
        }
        
        if let contactPhone = contact?.phone {
            phone.text = contactPhone
            email.text = contact?.email
        } else {
            phone.isHidden = true
            email.text = contact?.email
        }
        
        if let addressCountry = address?.country, let addressCity = address?.city,
           let addressPostCode = address?.postcode, let addressStreet = address?.street,
           let addressHouse = address?.house {
            country.text = addressCountry
            postcode_city.text = addressPostCode
            postcode_city.text = postcode_city.text! + ", " + addressCity
            street.text = addressStreet
            house.text = addressHouse
        } else {
            country.text = "Nincs megjeleníthető adat."
            postcode_city.isHidden = true
            street.isHidden = true
            house.isHidden = true
        }
        
    }

    @IBAction func emailBtnPressed(_ sender: UIButton) {
        self.showMailComposer()
    }
    
}

extension PatientProfileViewController {
    func setPatient(patient: GetUser) {
        self.patient = patient
    }
    
    func setAddress(address: GetAddress) {
        self.address = address
    }
    
    func setContact(contact: Contact) {
        self.contact = contact
    }
    
    func setBackButtonVisible() {
        self.backButtonisHidden = false
    }
}

extension PatientProfileViewController: MFMailComposeViewControllerDelegate {
    
    private func showMailComposer() {
            
        guard MFMailComposeViewController.canSendMail() else {
            Alerts.unsuccess(title: "Hiba!", message: "A Mail app nem nyitható meg!", viewController: self)
            return
        }
            
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients([contact!.email!])
        composer.setSubject("")
        composer.setMessageBody("Tisztelt \(patient!.lastname ?? "") \( patient!.firstname ?? "")!", isHTML: false)
            
        present(composer, animated: true)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            
            if let _ = error {
                Alerts.unsuccess(title: "Hiba!", message: "Az appon belüli email küldéshez először be kell állítania a Mail appot! Kérem, jelentkezzen be email fiókjával a Mail appba és próbálja meg újra!", viewController: self)
                controller.dismiss(animated: true)
                return
            }
            
            switch result {
            case .cancelled:
                Alerts.unsuccess(title: "Figyelem!", message: "Az emailt visszavonta!", viewController: self)
            case .failed:
                Alerts.unsuccess(title: "Sikertelen email küldés!", message: "Az emailt nem sikerült elküldeni!", viewController: self)
            case .saved:
                Alerts.success(title: "Email mentve!", message: "Az email sikeresen elmentve!", viewController: self)
            case .sent:
                Alerts.success(title: "Email elküldve!", message: "Az email sikeresen elküldve.", viewController: self)
            @unknown default:
                break
            }
            
            controller.dismiss(animated: true)
        }
    
}
