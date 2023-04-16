//
//  PatientSeeOwnRatingsViewController.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2023. 02. 13..
//

import UIKit

class PatientSeeOwnRatingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var ratings: [Rating] = []
    
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

}

extension PatientSeeOwnRatingsViewController: UITableViewDataSource {
    
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

extension PatientSeeOwnRatingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            DBHelper.shared.delete(role: UD.shared.getRole(), table:"ratings", uid: self.ratings[indexPath.row].uid!) { (res) in
                switch res {
                case .failure(_):
                    DispatchQueue.main.sync {
                        Alerts.unsuccess(title: "Sikertelen törlés!", message: "Értékelését nem sikerült törölnie! Kérem, próbálja meg újra!", viewController: self)
                    }
                case .success(_):
                    tableView.beginUpdates()
                    self.ratings.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    tableView.endUpdates()
                }
            }
        }
    }
    
}

extension PatientSeeOwnRatingsViewController {
    
    private func initializeRatings() {
        ActivityIndicator.shared.setupActivityIndicator(view: self.view)
        DBHelper.shared.userGetRatings(viewController: self, idType: "patientID", id: UD.shared.getUID()) { ratings in
            self.ratings = ratings
            ActivityIndicator.shared.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            self.tableView.reloadData()
            
            if self.ratings.count == 0 {
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
                label.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2)
                    label.textAlignment = .center
                    label.text = "Még nem értékelt egyetlen orvost sem."
                    label.lineBreakMode = .byWordWrapping
                    label.numberOfLines = 3
                    self.view.addSubview(label)
            }
        }
    }
    
}

