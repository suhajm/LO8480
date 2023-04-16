//
//  AdminGetPatientsViewController.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2022. 08. 16..
//

import UIKit
import Firebase

class AdminGetPatientsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var patients: [GetUser] = []
    private var addresses: [GetAddress] = []
    private var contacts: [Contact] = []
    private var patientIndex: Int?
    private var addressIndex: Int?
    private var contantIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "PatientCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        
        initializePatients()
        
        
    }
}

extension AdminGetPatientsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return patients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! PatientCell
        cell.name.text = patients[indexPath.row].lastname! + " " + patients[indexPath.row].firstname!
        if let url = URL(string: patients[indexPath.row].profilePicURL!) {
            cell.profilePicture.kf.indicatorType = .activity
            cell.profilePicture.kf.setImage(with: url, options: [.transition(.flipFromLeft(0.5))])
            cell.profilePicture?.layer.cornerRadius = (cell.profilePicture?.frame.size.width ?? 0.0) / 2
            cell.profilePicture?.clipsToBounds = true
            cell.profilePicture?.layer.borderWidth = 3.0
            cell.profilePicture?.layer.borderColor = UIColor.red.cgColor
        }
        return cell
    }

}

extension AdminGetPatientsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        patientIndex = indexPath.row
        
        let uid = patients[patientIndex!].uid
        addressIndex = addresses.firstIndex(where: {$0.uid == uid})
        contantIndex = contacts.firstIndex(where: {$0.uid == uid})
        self.performSegue(withIdentifier: "adminSeePatient", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "adminSeePatient" {
            let destinationVC = segue.destination as! PatientProfileViewController
            destinationVC.setPatient(patient: patients[patientIndex!])
            destinationVC.setAddress(address: addresses[addressIndex!])
            destinationVC.setContact(contact: contacts[contantIndex!])
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            ActivityIndicator.shared.setupActivityIndicator(view: self.view)
            DBHelper.shared.adminDeleteUser(userUID: self.patients[indexPath.row].uid!) {
                (res) in
                switch res {
                case .failure(let error):
                    DispatchQueue.main.async {
                        ActivityIndicator.shared.activityIndicator.stopAnimating()
                        self.view.isUserInteractionEnabled = true
                        let translatedError = self.translateAPIresponse(response: error.localizedDescription)
                        Alerts.unsuccess(title: "Hiba történt!", message: translatedError, viewController: self)
                    }
                case .success(_):
                    DispatchQueue.main.async {
                        ActivityIndicator.shared.activityIndicator.stopAnimating()
                        self.view.isUserInteractionEnabled = true
                        tableView.beginUpdates()
                        self.patients.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        tableView.endUpdates()
                    }
                }
            }
            
        }
    }
}

extension AdminGetPatientsViewController {
    
    private func initializePatients() {
        
        ActivityIndicator.shared.setupActivityIndicator(view: self.view)
        DBHelper.shared.loadUsers(viewController: self, userType: "patient") { users, userAddresses, contacts in
            self.patients = users
            self.addresses = userAddresses
            self.contacts = contacts
            ActivityIndicator.shared.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            self.tableView.reloadData()
        }
        
    }
    
    private func translateAPIresponse(response: String) -> String {
        if response == "There is no user who has the given uid!" {
            return "Nincs ilyen felhasználó!"
        } else if response == "Delete failed" {
            return "Sikertelen törlés."
        } else if response == "You have no rights to delete!" {
            return "Felhasználó törléséhez nincs jogosultsága!"
        } else if response == "Invalid token!" {
            return "Helytelen token!"
        }
        
        return ""
    }
}
