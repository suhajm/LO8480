//
//  DeleteAccountViewController.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2023. 02. 23..
//

import UIKit
import Lottie

class DeleteAccountViewController: UIViewController {
    
    @IBOutlet weak var animationView: UIView!
    private var name = Notification.Name("authSuccess")
    private var animation: LottieAnimationView?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createObservers()
        setAnimation()
    }
    
    @IBAction func deleteButton(_ sender: UIButton) {
        
        Alerts.warningThenSegue(viewController: self, title: "Figyelem!", message: "A fiók törlése előtt igazolnia kell magát!", segueIdentifier: "toAuth")
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAuth" {
            let destinationVC = segue.destination as! LoginViewController
            destinationVC.reAuth = true
        }
    }
    
    private func setAnimation() {
        animation = .init(name: "deleteUser")
        animation?.frame = animationView.bounds
        animation?.animationSpeed = 1.0
        animation?.loopMode = .playOnce
        animationView.addSubview(animation!)
        animation?.play()
    }
    
    private func createObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(DeleteAccountViewController.deleteAccount(notification:)), name: name, object: nil)
        
    }
    
    @objc
    private func deleteAccount(notification: NSNotification) {
        
        DBHelper.shared.deleteAccount() {
            (res) in
            switch res {
            case .failure(_):
                Alerts.unsuccess(title: "Hiba történt!", message: "Hiba történt fiókja törlése során! Kérem, próbálja meg újra!", viewController: self)
            case .success(_):
                let deleteName = Notification.Name("userDeletedSuccessfully")
                NotificationCenter.default.post(name: deleteName, object: nil)
                self.dismiss(animated: true)
            }
            
        }
        
    }
    
}
