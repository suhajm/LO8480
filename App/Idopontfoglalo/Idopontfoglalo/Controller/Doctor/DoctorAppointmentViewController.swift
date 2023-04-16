//
//  DoctorAppointmentViewController.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2022. 08. 22..
//

import UIKit
import Firebase
import FirebaseStorage

var selectedDate = Date()

class DoctorAppointmentViewController: UIViewController {
    
    private var patients: [GetUser] = []
    private var addresses: [GetAddress] = []
    private var appointments: [Appointment] = []
    private var contacts: [Contact] = []
    private var filterAppointments: [Appointment] = []
    private var patientIndex: Int?
    private var addressIndex: Int?
    private var contantIndex: Int?
    private var appointmentTypeForPics = "Szabad"
    
    @IBOutlet weak var appointmentType: UISegmentedControl!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var monthLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    private var totalSquares = [Date]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "AppointmentCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        
        setCellsView()
        setWeekView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        initializeAppointments()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    @IBAction func appointmentTypeChanged(_ sender: UISegmentedControl) {
        
        let type = appointmentType.titleForSegment(at: appointmentType.selectedSegmentIndex)
        
        if type == "Szabad" {
            self.appointmentTypeForPics = "Szabad"
            self.filterAppointments = appointments.filter({$0.name.contains("Szabad időpont.")})
            tableView.reloadData()
        } else if type == "Foglalt" {
            self.appointmentTypeForPics = "Foglalt"
            self.filterAppointments = appointments.filter({$0.patientID.count > 0})
            tableView.reloadData()
        }
    }
    
    @IBAction func previousWeek(_ sender: UIButton) {
        
        selectedDate = CalendarHelper().addDays(date: selectedDate, days: -7)
        setWeekView()
        
    }
    
    @IBAction func nextWeek(_ sender: UIButton) {
        
        selectedDate = CalendarHelper().addDays(date: selectedDate, days: 7)
        setWeekView()
        
    }
    
    @IBAction func plusButtonPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: "doctorCreateAppointment", sender: self)
        
    }
    
}
    
    
extension DoctorAppointmentViewController: UICollectionViewDelegate, UICollectionViewDataSource {
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReuseableCell", for: indexPath) as! CalendarCell
            
            let date = totalSquares[indexPath.item]
            cell.dayOfMonth.text = String(CalendarHelper().dayOfMonth(date: date))
            
            if(date == selectedDate)
            {
                cell.backgroundColor = UIColor.systemRed
            }
            else
            {
                cell.backgroundColor = UIColor.white
            }
            
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
        {
            selectedDate = totalSquares[indexPath.item]
            collectionView.reloadData()
            tableView.reloadData()
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return totalSquares.count
        }
        
    }
    
extension DoctorAppointmentViewController: UITableViewDelegate, UITableViewDataSource {
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return Appointment().appointmentToDate(date: selectedDate, list: filterAppointments).count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! AppointmentCell
            let appointment = Appointment().appointmentToDate(date: selectedDate, list: filterAppointments)[indexPath.row]
            cell.name.text = appointment.name
            cell.time.text = CalendarHelper().timeString(date: appointment.date)
            cell.profilePicture.kf.indicatorType = .activity
            if self.appointmentTypeForPics == "Foglalt" {
                let patientIndex = patients.firstIndex(where: {$0.uid == appointment.patientID})!
                if let url = URL(string: patients[patientIndex].profilePicURL!) {
                    cell.profilePicture.kf.setImage(with: url, options: [.transition(.flipFromLeft(0.5))])
                    
                }
            } else {
                cell.profilePicture.image = UIImage(named: "UserDefaultProfilePic")
            }
            
            cell.profilePicture.layer.cornerRadius = (cell.profilePicture.frame.size.width ) / 2
            cell.profilePicture.clipsToBounds = true
            cell.profilePicture.layer.borderWidth = 3.0
            cell.profilePicture.layer.borderColor = UIColor.red.cgColor
            
            return cell
        }
    
        func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
            return .delete
        }
        
        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                
                let index = Appointment().appointmentToDate(date: selectedDate, list: filterAppointments)[indexPath.row]
                
                DBHelper.shared.delete(role: UD.shared.getRole(), table:"appointments", uid: index._id) { (res) in
                    switch res {
                    case .failure(_):
                        DispatchQueue.main.sync {
                            Alerts.unsuccess(title: "Hiba történt!", message: "Sikertelen törlés! Kérem, próbálja meg újra!", viewController: self)
                        }
                    case .success(_):
                        UserNotificationHandler.shared.notificationCenter.removePendingNotificationRequests(withIdentifiers: [index._id])
                        self.filterAppointments.removeAll(where:  {$0._id == index._id})
                        self.appointments.removeAll(where:  {$0._id == index._id})
                        tableView.beginUpdates()
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        tableView.endUpdates()
                    }
                }
            }
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let appointment = Appointment().appointmentToDate(date: selectedDate, list: filterAppointments)[indexPath.row]
            if (appointment.name != "Szabad időpont.") {
                patientIndex = patients.firstIndex(where: {$0.uid == appointment.patientID})
                addressIndex = addresses.firstIndex(where: {$0.uid == appointment.patientID})
                contantIndex = contacts.firstIndex(where: {$0.uid == patients[patientIndex!].uid})
                performSegue(withIdentifier: "seePatient", sender: self)
            }
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if (segue.identifier == "seePatient") {
                let destinationVC = segue.destination as! PatientProfileViewController
                destinationVC.setPatient(patient: patients[patientIndex!])
                destinationVC.setAddress(address: addresses[addressIndex!])
                destinationVC.setContact(contact: contacts[contantIndex!])
                
            } else if segue.identifier == "doctorCreateAppointment" {
                self.appointments.removeAll()
            }
        }
}

extension DoctorAppointmentViewController {
    
    func initializeAppointments() {
        
        ActivityIndicator.shared.setupActivityIndicator(view: self.view)
        DBHelper.shared.doctorLoadAppointments(viewController: self) { users, appointments, userAddresses, contacts in
            self.patients = users
            self.addresses = userAddresses
            self.appointments = appointments
            self.contacts = contacts
            if self.appointmentTypeForPics == "Szabad" {
                self.filterAppointments = self.appointments.filter({$0.name.contains("Szabad időpont.")})
            } else {
                self.filterAppointments = self.appointments.filter({$0.patientID.count > 0})
            }
            
            ActivityIndicator.shared.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            self.tableView.reloadData()
        }
        
    }
    
    private func setCellsView() {
        
        let width = 40
        let height = 40
        
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: width, height: height)
        
    }
    
    private func setWeekView()
    {
        totalSquares.removeAll()
        
        var current = CalendarHelper().mondayForDate(date: selectedDate)
        let nextSunday = CalendarHelper().addDays(date: current, days: 7)
        
        while (current < nextSunday)
        {
            totalSquares.append(current)
            current = CalendarHelper().addDays(date: current, days: 1)
        }
        
        monthLabel.text = CalendarHelper().dateString(date: selectedDate)
        collectionView.reloadData()
        tableView.reloadData()
    }
    
}
