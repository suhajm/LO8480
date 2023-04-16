//
//  DoctorProfileViewController.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2022. 08. 18..
//  Email: https://www.youtube.com/watch?v=J-pn5V2jcfo&list=LL&index=2
//

import UIKit
import MessageUI

class DoctorProfileViewController: UIViewController {
    
    @IBOutlet weak var profilePicture: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var spec: UILabel!
        
    @IBOutlet weak var phone: UILabel!
    
    @IBOutlet weak var email: UILabel!
    
    @IBOutlet weak var country: UILabel!
    
    @IBOutlet weak var postcode_city: UILabel!
    
    @IBOutlet weak var street: UILabel!
    
    @IBOutlet weak var house: UILabel!
    
    @IBOutlet weak var appButton: UIButton!
    
    @IBOutlet weak var emailButton: UIButton!
    
    @IBOutlet weak var rateButton: UIButton!
        
    private var doctor: GetUser?
    private var address: GetAddress?
    private var contact: Contact?

    override func viewWillAppear(_ animated: Bool) {
        
        let role = UD.shared.getRole()
        
        if role == "admin" {
            appButton.isHidden = true
            rateButton.isHidden = true
            emailButton.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadInfo()
    }
    
    @IBAction func appointmentButtonPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: "patientBookAppointment", sender: self)
        
    }
    
    @IBAction func rateButtonPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: "rateDoctor", sender: self)
        
    }

    @IBAction func emailBtnPressed(_ sender: UIButton) {
        self.showMailComposer()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "patientBookAppointment" {
            let destinationVC = segue.destination as! PatientBookAppointmentViewController
            destinationVC.setNeededName(name: name.text!)
            destinationVC.setDoctorID(doctorID: doctor!.uid!)
        } else if segue.identifier == "rateDoctor" {
            let destinationVC = segue.destination as! PatientRateDoctorViewController
            destinationVC.setDoctorID(doctorID: doctor!.uid!)
            destinationVC.setDoctorName(name: name.text!)
            destinationVC.setProfilePic(URL: doctor!.profilePicURL!)
        }
    }
    
    private func loadInfo() {
        
        if let url = URL(string: doctor!.profilePicURL!) {
            profilePicture.kf.indicatorType = .activity
            profilePicture?.kf.setImage(with: url, options: [.transition(.flipFromLeft(0.5))])
            profilePicture?.layer.cornerRadius = (profilePicture?.frame.size.width ?? 0.0) / 2
            profilePicture?.clipsToBounds = true
            profilePicture?.layer.borderWidth = 3.0
            profilePicture?.layer.borderColor = UIColor.red.cgColor
        }
        name.text = doctor!.title! + ". " + doctor!.lastname! + " " + doctor!.firstname!
        
        if doctor!.spec_ill == nil {
            spec.text = "Nincs megjeleníthető adat."
        } else {
            spec.text = doctor!.spec_ill!
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
    
}

extension DoctorProfileViewController {
    
    func setDoctor(doctor: GetUser) {
        self.doctor = doctor
    }
    
    func setAddress(address: GetAddress) {
        self.address = address
    }
    
    func setContact(contact: Contact) {
        self.contact = contact
    }
}

extension DoctorProfileViewController: MFMailComposeViewControllerDelegate {
    
    private func showMailComposer() {
            
        guard MFMailComposeViewController.canSendMail() else {
            Alerts.unsuccess(title: "Hiba!", message: "Az appon belüli email küldéshez először be kell állítania a Mail appot! Kérem, jelentkezzen be email fiókjával a Mail appba és próbálja meg újra!", viewController: self)
            return
        }
            
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients([contact!.email!])
        composer.setSubject("")
        composer.setMessageBody("Tisztelt \(doctor!.lastname ?? "") \( doctor!.firstname ?? "")!", isHTML: false)
            
        present(composer, animated: true)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            
            if let _ = error {
                Alerts.unsuccess(title: "Hiba!", message: "Hiba történt!", viewController: self)
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
