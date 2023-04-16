//
//  PatientBookAppointmentViewController.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2022. 08. 26..
//

import UIKit
import Firebase

class PatientBookAppointmentViewController: UIViewController {

    @IBOutlet weak var doctorName: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var monthLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    private var appointments: [Appointment] = []
    private var totalSquares = [Date]()
    private var neededName: String?
    private var doctorID: String?
    private var neededAppointment: Appointment?
    private let db = Firestore.firestore()
    
    override func viewWillAppear(_ animated: Bool) {
        if (appointments.count == 0) {
            initializeAppointments()
        }
        doctorName.text = neededName!
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "AppointmentCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        
        UserNotificationHandler.shared.notificationCenter.requestAuthorization(options: [.alert, .sound]) {
                    (permissionGranted, error) in
                }
        
        setCellsView()
        setWeekView()
    }
    
    @IBAction func previousWeek(_ sender: UIButton) {
        
        selectedDate = CalendarHelper().addDays(date: selectedDate, days: -7)
        setWeekView()
        
    }
    
    @IBAction func nextWeek(_ sender: UIButton) {
        
        selectedDate = CalendarHelper().addDays(date: selectedDate, days: 7)
        setWeekView()
        
    }
    
}

extension PatientBookAppointmentViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
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

extension PatientBookAppointmentViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Appointment().appointmentToDate(date: selectedDate, list: self.appointments).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! AppointmentCell
        let appointment = Appointment().appointmentToDate(date: selectedDate, list: self.appointments)[indexPath.row]
        cell.name.text = appointment.name
        cell.time.text = CalendarHelper().timeString(date: appointment.date)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let appointment = Appointment().appointmentToDate(date: selectedDate, list: self.appointments)[indexPath.row]
        neededAppointment = appointment
        self.showAlert()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension PatientBookAppointmentViewController {
    
    func setNeededName(name: String) {
        self.neededName = name
    }
    
    func setDoctorID(doctorID: String) {
        self.doctorID = doctorID
    }
    
    private func initializeAppointments() {
        
        ActivityIndicator.shared.setupActivityIndicator(view: self.view)
        DBHelper.shared.patientGetFreeAppointments(viewController: self, doctorID: doctorID!) {
            (data) in
            
            self.appointments = data
            ActivityIndicator.shared.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            self.tableView.reloadData()
            
        }
        
    }
    
    private func showAlert() {
        
        let alert = UIAlertController(title: "Biztosan lefoglalja az időpontot?", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Nem", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Igen", style: .default, handler: {action
            in
            self.bookAppointment()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func bookAppointment()
    {
        let appRef = db.collection("appointments").document(neededAppointment!._id!)
        
        DBHelper.shared.patientBookAppointment(appRef: appRef) {
            (res) in
            
            switch res {
            case .failure(_):
                Alerts.unsuccess(title: "Hiba történt!", message: "Sikertelen időpont foglalás! Kérem, próbálja meg újra!", viewController: self)
            case .success(_):
                UserNotificationHandler.shared.scheduleNotification(identifier: self.neededAppointment!._id!, date: self.neededAppointment!.date.addingTimeInterval(-7200), title: "Időpont", message: "Önnek holnap ekkorra lefogalt időpontja van. Kérem, ne feledkezzen meg róla!", viewController: self)
                self.appointments.removeAll()
                self.initializeAppointments()
                self.tableView.reloadData()
            }
            
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
