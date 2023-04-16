//
//  AdminManageAdminsViewController.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2023. 03. 25..
//

import UIKit

class AdminManageAdminsViewController: ViewController {
    
    @IBOutlet weak var tableview: UITableView!
    
    private var filteredAdmins = [GetUser]()
    private var addresses: [GetAddress] = []
    private var contacts: [Contact] = []
    private var adminIndex: Int?
    private var addressIndex: Int?
    private var contantIndex: Int?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.tintColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true)
        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(UINib(nibName: "PatientCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        
        initializeAdmins()
    }
    

}

extension AdminManageAdminsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredAdmins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! PatientCell
        cell.name.text = filteredAdmins[indexPath.row].lastname! + " " + filteredAdmins[indexPath.row].firstname!
        if let url = URL(string: filteredAdmins[indexPath.row].profilePicURL!) {
            cell.profilePicture.kf.setImage(with: url, options: [.transition(.flipFromLeft(0.5))])
            cell.profilePicture?.layer.cornerRadius = (cell.profilePicture?.frame.size.width ?? 0.0) / 2
            cell.profilePicture?.clipsToBounds = true
            cell.profilePicture?.layer.borderWidth = 3.0
            cell.profilePicture?.layer.borderColor = UIColor.red.cgColor
        }
        return cell
        
    }
}

extension AdminManageAdminsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        adminIndex = indexPath.row
        let uid = filteredAdmins[adminIndex!].uid
        addressIndex = addresses.firstIndex(where: {$0.uid == uid})
        contantIndex = contacts.firstIndex(where: {$0.uid == uid})
        self.performSegue(withIdentifier: "adminSeeAdmin", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! PatientProfileViewController
        destinationVC.setPatient(patient: filteredAdmins[adminIndex!])
        destinationVC.setAddress(address: addresses[addressIndex!])
        destinationVC.setContact(contact: contacts[contantIndex!])
        destinationVC.setBackButtonVisible()
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            ActivityIndicator.shared.setupActivityIndicator(view: self.view)
            print(self.filteredAdmins[indexPath.row])
            DBHelper.shared.adminDeleteUser(userUID: self.filteredAdmins[indexPath.row].uid!) {
                (res) in
                switch res {
                case .failure(let error):
                    DispatchQueue.main.async {
                        print(error.localizedDescription)
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
                        self.filteredAdmins.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        tableView.endUpdates()
                    }
                }
            }
            
        }
    }
}

extension AdminManageAdminsViewController {
    private func initializeAdmins() {
        
        ActivityIndicator.shared.setupActivityIndicator(view: self.view)
        DBHelper.shared.loadUsers(viewController: self, userType: "admin") { users, userAddresses, contact in

            self.filteredAdmins = users.filter({
                !$0.uid!.contains("QDwim2rVIIaANv9Tt34a1nd9c1b2") &&
                !$0.uid!.contains(UD.shared.getUID())
                
            })
            if self.filteredAdmins.count == 0 {
                ActivityIndicator.shared.activityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
                self.tableview.isHidden = true
                
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
                label.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2)
                    label.textAlignment = .center
                    label.text = "Nincs listázható felhasználó."
                    label.numberOfLines = 3
                    self.view.addSubview(label)
            }
            self.addresses = userAddresses
            self.contacts = contact
            ActivityIndicator.shared.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            self.tableview.reloadData()
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
