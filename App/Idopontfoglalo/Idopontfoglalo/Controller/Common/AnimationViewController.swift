//
//  Animation1ViewController.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2023. 03. 01..
//

import UIKit
import Lottie
import Hero
import Firebase

class AnimationViewController: ViewController {
    
    @IBOutlet weak var animationView: UIView!
    
    private var animation: LottieAnimationView?
    
    private var timer = Timer()
    private var totalTime = 2
    private var secondsPassed = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        let role = UD.shared.getRole()
        if Auth.auth().currentUser != nil {
            if role == "admin" {
                performSegue(withIdentifier: "admin", sender: self)
            } else if role == "doctor" {
                performSegue(withIdentifier: "doctor", sender: self)
            } else if role == "patient" {
                performSegue(withIdentifier: "patient", sender: self)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAnimation()
        
        if Auth.auth().currentUser == nil || UD.shared.getRole() == "" {
            timer.invalidate()
            UD.shared.defaults.removeObject(forKey: "uid")
            UD.shared.defaults.removeObject(forKey: "role")
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    @objc func updateCounter() {
        if secondsPassed < totalTime {
            secondsPassed += 1
        } else {
            timer.invalidate()
            performSegue(withIdentifier: "toWelcome", sender: self)
        }
    }
    
    private func setAnimation() {
        animation = .init(name: "clock")
        animation?.frame = animationView.bounds
        animation?.loopMode = .loop
        animation?.animationSpeed = 1.0
        animationView.addSubview(animation!)
        animation?.play()
    }
    
}
