//
//  PatientGetDoctorsViewController.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2022. 08. 18..
//

import UIKit
import Firebase
import FirebaseStorage

class PatientGetDoctorsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchCriteria: UISegmentedControl!

    private var doctors: [GetUser] = []
    private var searchedDoctors: [GetUser] = []
    private var addresses: [GetAddress] = []
    private var searchedAddresses: [GetAddress] = []
    private var contacts: [Contact] = []
    private var doctorIndex: Int?
    private var addressIndex: Int?
    private var contantIndex: Int?
    private var filterDoctorFromHome: String?
            
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "DoctorCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        self.searchBar.searchTextField.backgroundColor = UIColor(named: "LightRed")
        
        initializeDoctors()
        searchBar.placeholder = "Keresés..."

    }
    
    @IBAction func searchCriteriaChanged(_ sender: UISegmentedControl) {
        
        if let criteria = searchCriteria.titleForSegment(at: searchCriteria.selectedSegmentIndex) {
            if criteria == "Név" {
                searchBar.placeholder = "Keresés név alapján..."
            } else if criteria == "Specializáció" {
                searchBar.placeholder = "Keresés specializáció alapján..."
            } else if criteria == "Város" {
                searchBar.placeholder = "Keresés város alapján..."
            } else if criteria == "-" {
                searchBar.placeholder = "Keresés..."
                self.searchedDoctors = self.doctors
                self.tableView.reloadData()
            }
        }
        
    }
    
    
    
}

extension PatientGetDoctorsViewController: UITableViewDataSource, UISearchBarDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedDoctors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! DoctorCell
        cell.name.text = searchedDoctors[indexPath.row].lastname! + " " + searchedDoctors[indexPath.row].firstname!
        cell.spec.text = searchedDoctors[indexPath.row].spec_ill
        cell.profilePicture.kf.indicatorType = .activity
        let url = URL(string: searchedDoctors[indexPath.row].profilePicURL!)
        cell.profilePicture.kf.setImage(with: url, options: [.transition(.flipFromLeft(0.5))])
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText != "") {
            if let criteria = searchCriteria.titleForSegment(at: searchCriteria.selectedSegmentIndex) {
                if criteria == "Név" {
                    searchedDoctors = self.doctors.filter({
                        $0.lastname!.contains(searchText) ||
                        $0.firstname!.contains(searchText)
                    })
                } else if criteria == "Specializáció" {
                    searchedDoctors = self.doctors.filter({
                        if $0.spec_ill != nil {
                            return $0.spec_ill!.contains(searchText)
                        }
                        return false
                    })
                } else if criteria == "Város" {
                    searchedAddresses = self.addresses.filter{ address in
                        if address.city != nil {
                            return address.city!.contains(searchText)
                        }
                        return false
                    }
                    
                    var neededDoctors = [GetUser]()
                    for addresses in searchedAddresses {
                        neededDoctors.append(doctors.first(where: {$0.uid == addresses.uid})!)
                    }
                    self.searchedDoctors = neededDoctors
                    
                } else if criteria == "-" {
                    searchedDoctors = self.doctors
                }
            }
            tableView.reloadData()
        } else {
            searchedDoctors = self.doctors
            tableView.reloadData()
        }
    }
    
}

extension PatientGetDoctorsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        doctorIndex = indexPath.row
        let uid = searchedDoctors[doctorIndex!].uid
        addressIndex = addresses.firstIndex(where: {$0.uid == uid})
        contantIndex = contacts.firstIndex(where: {$0.uid == uid})
        performSegue(withIdentifier: "seeDoctor", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "seeDoctor" {
            let destinationVC = segue.destination as! DoctorProfileViewController
            destinationVC.setDoctor(doctor: self.doctors[doctorIndex!])
            destinationVC.setAddress(address:  addresses[addressIndex!])
            destinationVC.setContact(contact: contacts[contantIndex!])
        }
    }
}

extension PatientGetDoctorsViewController {
    
    func setFilterDoctorFromHome(criteria: String) {

        self.filterDoctorFromHome = criteria
        initializeDoctors()
    }

    private func filterDoctorsFromHome() {

        searchedDoctors = self.doctors.filter({
            if $0.spec_ill != nil {
                return $0.spec_ill!.contains("")
            }
            return false
        })
        self.searchCriteria.selectedSegmentIndex = 1
        self.searchBar.placeholder = "Keresés specializáció alapján..."
    }
    
    private func initializeDoctors() {

        ActivityIndicator.shared.setupActivityIndicator(view: self.view)
        DBHelper.shared.loadUsers(viewController: self, userType: "doctor") { users, userAddresses, contact in
            self.doctors = users
            self.searchedDoctors = users
            self.addresses = userAddresses
            if self.filterDoctorFromHome != nil {
                self.searchedDoctors = self.doctors.filter({
                    if $0.spec_ill != nil {
                        if $0.spec_ill!.contains(self.filterDoctorFromHome!) {
                            return $0.spec_ill!.contains(self.filterDoctorFromHome!)
                        }
                        else {
                            return false
                        }
                    }
                    return false
                })
                self.searchCriteria.selectedSegmentIndex = 2
                self.searchBar.placeholder = "Keresés specializáció alapján..."
            } else {
                self.searchedDoctors = users
            }
            self.searchedAddresses = userAddresses
            self.contacts = contact
            ActivityIndicator.shared.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            self.tableView.reloadData()
            
            if self.doctors.count == 0 {
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
                label.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2)
                    label.textAlignment = .center
                    label.text = "Nincs regisztrált orvos az adatbázisban."
                    label.numberOfLines = 3
                    self.view.addSubview(label)
            }
        }
        
    }
    
}
