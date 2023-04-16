//
//  DoctorHomeViewController.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2022. 08. 18..
//

import UIKit
import Lottie

class DoctorHomeViewController: UIViewController {
    
    @IBOutlet weak var animationView: UIView!
    
    @IBOutlet weak var allAppointment: UILabel!
    @IBOutlet weak var freeAppointment: UILabel!
    @IBOutlet weak var bookedAppointment: UILabel!
    
    private var animation: LottieAnimationView?
    
    private var appointments: [Appointment] = []
    
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

extension DoctorHomeViewController {
    
    private func setAnimation() {
        animation = .init(name: "heartrate")
        animation?.frame = animationView.bounds
        animation?.animationSpeed = 1.0
        animation?.loopMode = .playOnce
        animationView.addSubview(animation!)
        animation?.play()
    }
    
    private func initializeAppointments() {
        
        ActivityIndicator.shared.setupActivityIndicator(view: self.view)
        DBHelper.shared.doctorLoadAppointments(viewController: self) { users, appointments, userAddresses, contacts in
            self.appointments = appointments.filter({
                let components = Calendar.current.dateComponents([.year, .month, .day], from: $0.date)
                let currentComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date().addingTimeInterval(3600))
                if components == currentComponents {
                    return true
                }
                return false
            })
            self.allAppointment.text = "\(self.appointments.count)"
            self.freeAppointment.text = "\(self.getFreeAppointments())"
            self.bookedAppointment.text = "\(self.getBookedAppointment())"
            ActivityIndicator.shared.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true

        }
        
    }
    
    private func getFreeAppointments() -> Int {
        var cnt = 0
        for app in appointments {
            if app.name == "Szabad időpont." {
                cnt = cnt + 1
            }
        }
        
        return cnt
    }
    
    private func getBookedAppointment() -> Int {
        var cnt = 0
        for app in appointments {
            if app.patientID != "" {
                cnt = cnt + 1
            }
        }
        
        return cnt
    }
    
}
