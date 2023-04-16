//
//  DoctorCreateAppointmentViewController.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2022. 08. 22..
//

import UIKit
import Firebase

class DoctorCreateAppointmentViewController: UIViewController {
    
    @IBOutlet weak var datepicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeHideKeyboard()
        datepicker.date = selectedDate.addingTimeInterval(3600)
        datepicker.timeZone = TimeZone.init(identifier: "UTC+1")
        
        UserNotificationHandler.shared.notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) {
                    (permissionGranted, error) in
                }
    }

    @IBAction func saveButtonPressed(_ sender: UIButton) {

        var newAppointment = Appointment()
        newAppointment._id = randomString(length: 8)
        newAppointment.name = "Szabad időpont."
        newAppointment.date = datepicker.date.addingTimeInterval(3600)
        
        let uID = Auth.auth().currentUser?.uid
        addAppointment(doctorID: uID!, Name: "Szabad időpont.", Date: newAppointment.date, uid: newAppointment._id)
                
    }
    
    private func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    private func addAppointment(doctorID: String, Name: String, Date: Date, uid: String) {
        
        DBHelper.shared.doctorAddAppointment(doctorID: doctorID, Name: Name, Date: Date, uid: uid) {
            (res) in
            
            switch res {
            case .failure(_):
                Alerts.unsuccess(title: "Sikertelen!", message: "Sikertelen hozzáadás!" ,viewController: self)
            case .success(_):
                DispatchQueue.main.async {
                    UserNotificationHandler.shared.scheduleNotification(identifier: uid, date: self.datepicker.date.addingTimeInterval(-3600), title: "Időpont", message: "Ön holnap ekkorra időpontot írt ki. Kérem, ellenőrizze az appban, hogy egy páciens lefoglalta-e!", viewController: self)
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
        }
        
    }
    
}
