//
//  PatientRateDoctorViewController.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2023. 02. 11..
//

import UIKit

class PatientRateDoctorViewController: UIViewController {
    
    private var doctorID: String?
    private var doctorName: String?
    private var profilePicURL: String?
    private var patientName: String?
    
    @IBOutlet weak var nameSwitch: UISwitch!
    
    private var rating = 0 {
        didSet {
            for starButton in starButtonCollection {
                let imageName = (starButton.tag < rating ? "star.fill" : "star")
                starButton.setImage(UIImage(systemName: imageName), for: .normal)
                starButton.tintColor = (starButton.tag < rating ? .systemRed : .darkText)
            }
        }
    }
    
    @IBOutlet weak var doctorProfilePic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var rateTitle: UITextField!
    @IBOutlet weak var rateText: UITextView!
    @IBOutlet var starButtonCollection: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPatientName()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        name.text = doctorName!
        if let url = URL(string: profilePicURL!) {
            
            self.doctorProfilePic.kf.indicatorType = .activity
            self.doctorProfilePic.kf.setImage(with: url, options: [.transition(.flipFromLeft(0.5))])
            self.doctorProfilePic.layer.cornerRadius = (self.doctorProfilePic.frame.size.width ) / 2
            self.doctorProfilePic.clipsToBounds = true
            self.doctorProfilePic.layer.borderWidth = 3.0
            self.doctorProfilePic.layer.borderColor = UIColor.red.cgColor
        }
    }
    
    @IBAction func nameSwitchValueChanged(_ sender: UISwitch) {
        
        if nameSwitch.isOn {
            getPatientName()
        } else {
            self.patientName = "Névtelen értékelő."
        }
        
    }
    
    
    @IBAction func rateButtonPressed(_ sender: UIButton) {
        
        if (checkFields()) {
            DBHelper.shared.rateDoctor(uid: self.randomString(length: 10), rate: self.rating, doctorID: self.doctorID!, patientID: UD.shared.getUID(), patientName: patientName!, rateTitle: self.rateTitle.text!, rateText: self.rateText.text!) {
                (res) in
                
                switch res {
                case .failure(_):
                    Alerts.unsuccess(title: "Sikertelen értékelés!", message: "Az értékelését nem sikerült közzétenni! Kérem, próbálja meg újra!", viewController: self)
                case .success(_):
                    Alerts.resultThenDismiss(viewController: self, title: "Sikeres értékelés!", message: "Sikeresen értékelte az orvost!")
                }
            }
        }
    }
    
    @IBAction func starButtonPressed(_ sender: UIButton) {
        
        rating = sender.tag + 1
        
    }
    
    
    @IBAction func moreRatingPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "patientSeeRatings", sender: self)
    }
    
    
    @IBAction func manageRatingsPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "patientSeeOwnRatings", sender: self)
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "patientSeeRatings" {
            let destinationVC = segue.destination as! PatientSeeRatingsViewController
            destinationVC.setDoctorID(doctorID: doctorID!)
        }
    }
    
}

extension PatientRateDoctorViewController {
    
    func setDoctorID(doctorID: String) {
        self.doctorID = doctorID
    }
    
    func setDoctorName(name: String) {
        self.doctorName = name
    }
    
    func setProfilePic(URL: String) {
        self.profilePicURL = URL
    }
    
    private func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    private func getPatientName() {
        DBHelper.shared.patientGetName(viewController: self) {
            (response) in
            
            switch response {
            case .failure(_):
                Alerts.unsuccess(title: "Hiba történt!", message: "Adatai lekérdezése nem sikerült! Kérem, próbálja meg újra!", viewController: self)
            case .success(let getName):
                self.patientName = getName
            }
        }
        
    }
    
    private func checkFields() -> Bool {
        
        if rating == 0 || rateTitle.text!.isEmpty || rateText.text.isEmpty {
            Alerts.fillIn(viewController: self)
            return false
        }
        
        return true
        
    }
}
