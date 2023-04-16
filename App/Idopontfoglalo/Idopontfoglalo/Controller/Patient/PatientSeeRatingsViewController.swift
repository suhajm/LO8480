//
//  PatientSeeRatingsViewController.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2023. 02. 13..
//

import UIKit

class PatientSeeRatingsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var ratings: [Rating] = []
    private var doctorID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "RatingsTableViewCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        initializeRatings()
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    
    @IBAction func seeChartBtnPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "seePieChart", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "seePieChart" {
            let destinationVC = segue.destination as! PieChartViewController
            destinationVC.setRatings(ratings: self.ratings)
        }
    }
    
}

extension PatientSeeRatingsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ratings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! RatingsTableViewCell
        cell.title.text = ratings[indexPath.row].rateTitle
        cell.ratingText.text = ratings[indexPath.row].rateText
        cell.name.text = ratings[indexPath.row].patientName
        cell.setStars(rating: ratings[indexPath.row].rate!)

        return cell
    }
    
}

extension PatientSeeRatingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension PatientSeeRatingsViewController {
    
    private func initializeRatings() {
        ActivityIndicator.shared.setupActivityIndicator(view: self.view)
        DBHelper.shared.userGetRatings(viewController: self, idType: "doctorID", id: doctorID!) { ratings in
            self.ratings = ratings
            ActivityIndicator.shared.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            self.tableView.reloadData()
            if self.ratings.count == 0 {
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
                label.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2)
                    label.textAlignment = .center
                    label.text = "Az orvosnak még nincs értékelése."
                    label.numberOfLines = 3
                    self.view.addSubview(label)
            }
        }
    }
    
    func setDoctorID(doctorID: String) {
        self.doctorID = doctorID
    }
    
}
