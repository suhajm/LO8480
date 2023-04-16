//
//  PatientSeeAppointmentsViewController.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2023. 02. 05..
//

import UIKit
import Firebase
import Kingfisher

class PatientSeeAppointmentsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var appointmentType: UISegmentedControl!
    
    private let db = Firestore.firestore()
    private var appointments: [Appointment] = []
    private var filteredAppointments: [Appointment] = []
    private var doctors: [GetUser] = []
    private var addresses: [GetAddress] = []
    private var contacts: [Contact] = []
    private var profilePictures: [UIImage] = []
    private let dateFormatter = DateFormatter()
    private var doctorIndex: Int?
    private var addressIndex: Int?
    private var contantIndex: Int?

    let currentDate = Date().addingTimeInterval(3600)
    private var appointmentTypeToShow = "Közelgő"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "BookedAppointmentCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tableView.isHidden = false
        initializeAppointments()
    }
    
    @IBAction func appointmentTypeChanged(_ sender: UISegmentedControl) {
        
        let type = appointmentType.titleForSegment(at: appointmentType.selectedSegmentIndex)
        
        if type == "Közelgő" {
            self.appointmentTypeToShow = "Közelgő"
            self.filteredAppointments = appointments.filter({$0.date > currentDate})
            tableView.reloadData()
        } else if type == "Korábbi" {
            self.appointmentTypeToShow = "Korábbi"
            self.filteredAppointments = appointments.filter({$0.date < currentDate})
            tableView.reloadData()
        }
        
    }
}

extension PatientSeeAppointmentsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredAppointments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! BookedAppointmentCell
        var date = CalendarHelper().timeString(date: filteredAppointments[indexPath.row].date)
        if !date.isEmpty {
            date = date.replacingOccurrences(of: "-", with: ".")
        }
        
        let yearMonth = CalendarHelper().dateString(date: filteredAppointments[indexPath.row].date)
        let day = CalendarHelper().dayOfMonth(date: filteredAppointments[indexPath.row].date)
        let fullDate = yearMonth + " " + String(day) + ". " + date
        cell.date.text = fullDate
        
        cell.doctorName.text = "\(doctors[indexPath.row].lastname!) \(doctors[indexPath.row].firstname!)"
        cell.doctorProfilePic.kf.indicatorType = .activity
        if let url = URL(string: doctors[indexPath.row].profilePicURL!) {
            cell.doctorProfilePic.kf.setImage(with: url, options: [.transition(.flipFromLeft(0.5))])
        }
        
        return cell
    }
    
}

extension PatientSeeAppointmentsViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        doctorIndex = indexPath.row
        let uid = doctors[doctorIndex!].uid
        addressIndex = addresses.firstIndex(where: {$0.uid == uid})
        contantIndex = contacts.firstIndex(where: {$0.uid == uid})
        performSegue(withIdentifier: "seeDoctorFromAppointments", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "seeDoctorFromAppointments" {
            let destinationVC = segue.destination as! DoctorProfileViewController
            destinationVC.setDoctor(doctor: self.doctors[doctorIndex!])
            destinationVC.setAddress(address:  addresses[addressIndex!])
            destinationVC.setContact(contact: contacts[contantIndex!])
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return.delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {

            let appRef = db.collection("appointments").document(appointments[indexPath.row]._id!)

            DBHelper.shared.patientDeleteAppointment(appRef: appRef) {
                (res) in
                
                switch res {
                case .failure(_):
                    Alerts.unsuccess(title: "Hiba történt!", message: "Sikertelen lekérdezés! Kérem, próbálja meg újra!", viewController: self)
                case .success(_):
                    UserNotificationHandler.shared.notificationCenter.removePendingNotificationRequests(withIdentifiers: [self.appointments[indexPath.row]._id])
                    self.initializeAppointments()
                    self.tableView.reloadData()
                }
                
            }
            
        }
    }
    
}

extension PatientSeeAppointmentsViewController {
    
    private func initializeAppointments() {
        ActivityIndicator.shared.setupActivityIndicator(view: self.view)
        DBHelper.shared.patientGetAppointments(viewController: self) {
            (appointments, doctors, addresses, contacts) in
            
            if appointments.count > 0 {
                self.appointments = appointments
                self.filteredAppointments = appointments
                if self.appointmentTypeToShow == "Közelgő" {
                    self.filteredAppointments = self.appointments.filter({$0.date > self.currentDate})
                } else if self.appointmentTypeToShow == "Korábbi" {
                    self.filteredAppointments = self.appointments.filter({$0.date < self.currentDate})
                }
                self.doctors = doctors
                self.addresses = addresses
                self.contacts = contacts
                ActivityIndicator.shared.activityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
                self.tableView.reloadData()
            } else {
                ActivityIndicator.shared.activityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
                self.tableView.isHidden = true
            }
            
        }
    }
    
}
