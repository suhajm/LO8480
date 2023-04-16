//
//  PatientHomeViewController.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2022. 08. 18..
//  https://icons8.com/icon/4948/tooth
//

import UIKit
import Lottie

class PatientHomeViewController: UIViewController {
    
    @IBOutlet weak var allAppointment: UILabel!
    @IBOutlet weak var todayAppointment: UILabel!
    
    @IBOutlet weak var animationView: UIView!
    private var animation: LottieAnimationView?
    
    private var appointments: [Appointment] = []
    
    private var filter: [String: UIImage?] = ["Háziorvos": UIImage(systemName: "house.fill"), "Szív": UIImage(systemName: "heart.fill"), "Fül": UIImage(systemName: "ear.fill"), "Száj": UIImage(systemName: "mouth.fill"), "Fog": UIImage(named: "tooth"), "Szem": UIImage(systemName: "eye.fill"), "Tüdő": UIImage(systemName: "lungs.fill"), "Arc": UIImage(systemName: "face.smiling.fill"), "Orr": UIImage(systemName: "nose.fill"), "Sport": UIImage(systemName: "figure.run")]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.tintColor = .white
        initializeAppointments()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setAnimation()
    }
    
}

extension PatientHomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filter.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReuseableCell", for: indexPath) as! PatientFilterDoctors
        cell.image.image = filter[filter.index(filter.startIndex, offsetBy: indexPath.row)].value
        cell.spec.text = filter[filter.index(filter.startIndex, offsetBy: indexPath.row)].key
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let filterBy = filter[filter.index(filter.startIndex, offsetBy: indexPath.row)].key
        let navVC = tabBarController?.viewControllers![1] as! PatientGetDoctorsViewController
        navVC.setFilterDoctorFromHome(criteria: filterBy)
        self.tabBarController?.selectedIndex = 1
    }
    
}

extension PatientHomeViewController {
    
    private func initializeAppointments() {
        ActivityIndicator.shared.setupActivityIndicatorForMyProfile(view: self.view)
        DBHelper.shared.patientGetAppointments(viewController: self) {
            (appointments, doctors, addresses, contacts) in
            
            self.appointments = appointments.filter({
                let components = Calendar.current.dateComponents([.year, .month, .day], from: $0.date)
                let currentComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date().addingTimeInterval(3600))
                if components == currentComponents {
                    return true
                }
                return false
            })
            
            self.allAppointment.text = "\(appointments.count)"
            self.todayAppointment.text = "\(self.appointments.count)"
            
            ActivityIndicator.shared.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            
        }
    }
    
    private func setAnimation() {
        animation = .init(name: "heartrate")
        animation?.frame = animationView.bounds
        animation?.animationSpeed = 1.0
        animation?.loopMode = .playOnce
        animationView.addSubview(animation!)
        animation?.play()
    }
    
}
