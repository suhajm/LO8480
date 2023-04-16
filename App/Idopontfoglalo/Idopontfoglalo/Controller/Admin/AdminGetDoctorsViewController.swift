//
//  AdminViewController.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2022. 08. 04..
//
/*ß*/
import UIKit
import Firebase

class AdminGetDoctorsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var doctors = [GetUser]()
    private var addresses: [GetAddress] = []
    private var contacts: [Contact] = []
    private var doctorIndex: Int?
    private var addressIndex: Int?
    private var contantIndex: Int?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.tintColor = .white
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.navigationItem.setHidesBackButton(true, animated: true)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "DoctorCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")

        initializeDoctors()
        
    }
    
}

extension AdminGetDoctorsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return doctors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! DoctorCell
        cell.name.text = doctors[indexPath.row].lastname! + " " + doctors[indexPath.row].firstname!
        cell.spec.text = doctors[indexPath.row].spec_ill
        if let url = URL(string: doctors[indexPath.row].profilePicURL!) {
            cell.profilePicture.kf.setImage(with: url, options: [.transition(.flipFromLeft(0.5))])
            cell.profilePicture?.layer.cornerRadius = (cell.profilePicture?.frame.size.width ?? 0.0) / 2
            cell.profilePicture?.clipsToBounds = true
            cell.profilePicture?.layer.borderWidth = 3.0
            cell.profilePicture?.layer.borderColor = UIColor.red.cgColor
        }
        return cell
        
    }

}

extension AdminGetDoctorsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        doctorIndex = indexPath.row
        let uid = doctors[doctorIndex!].uid
        addressIndex = addresses.firstIndex(where: {$0.uid == uid})
        contantIndex = contacts.firstIndex(where: {$0.uid == uid})
        self.performSegue(withIdentifier: "adminSeeDoctor", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "adminSeeDoctor" {
            let destinationVC = segue.destination as! DoctorProfileViewController
            destinationVC.setDoctor(doctor: doctors[doctorIndex!])
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
            DBHelper.shared.adminDeleteUser(userUID: self.doctors[indexPath.row].uid!) {
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
                        self.doctors.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        tableView.endUpdates()
                    }
                }
            }
            
        }
    }
    
}

extension AdminGetDoctorsViewController {
    
    private func initializeDoctors() {
        
        ActivityIndicator.shared.setupActivityIndicator(view: self.view)
        DBHelper.shared.loadUsers(viewController: self, userType: "doctor") { users, userAddresses, contact in
            self.doctors = users
            self.addresses = userAddresses
            self.contacts = contact
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
