//
//  DoctorGetRatingsViewController.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2023. 02. 12..
//

import UIKit

class DoctorGetRatingsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var ratings: [Rating] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "RatingsTableViewCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        
        initializeRatings()
    }
    
    
    @IBAction func seeDiagramBtnPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "seeDiagram", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "seeDiagram" {
            let destinationVC = segue.destination as! PieChartViewController
            destinationVC.setRatings(ratings: self.ratings)
        }
    }
    
}

extension DoctorGetRatingsViewController: UITableViewDataSource {
    
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

extension DoctorGetRatingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension DoctorGetRatingsViewController {
    
    private func initializeRatings() {
        ActivityIndicator.shared.setupActivityIndicator(view: self.view)
        DBHelper.shared.userGetRatings(viewController: self, idType: "doctorID", id: UD.shared.getUID()) { ratings in
            if ratings.count == 0 {
                self.tableView.isHidden = true
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
                label.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2)
                    label.textAlignment = .center
                    label.text = "Nincs értékelése."

                    self.view.addSubview(label)
            }
            self.ratings = ratings
            ActivityIndicator.shared.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            self.tableView.reloadData()
        }
    }
    
}
