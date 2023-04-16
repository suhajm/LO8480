//
//  MyProfileViewController.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2022. 08. 09..
//  ImagePicker: https://www.youtube.com/watch?v=zT1mssBXCHw&t=944s
//  User avatar: https://www.flaticon.com/free-icon/user_332783
//  https://www.youtube.com/watch?v=rV3lGy1xdv4
//

import UIKit
import Firebase
import FirebaseStorage

class MyProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private var user: GetUser?
    private var tajNumberCount = 0
    let deleteName = Notification.Name("userDeletedSuccessfully")
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBOutlet weak var profilePicture: UIImageView!
    
    @IBOutlet weak var selectOperationButton: UIButton!
    
    @IBOutlet var operationBtnCollection: [UIButton]!
    
    @IBAction func selectOperationPressed(_ sender: UIButton) {
        
        operationBtnCollection.forEach { (btn) in
            UIView.animate(withDuration: 0.75) {
                btn.isHidden = false
                btn.alpha = btn.alpha == 0 ? 1 : 0
            }
        }
        
    }
    
    @IBAction func operationPressed(_ sender: UIButton) {
        if let btnLabel = sender.titleLabel?.text {
            if btnLabel == "Jelszó" {
                performSegue(withIdentifier: "changePassword", sender: self)
            } else if btnLabel == "Személyes adatok" {
                performSegue(withIdentifier: "personalInfo", sender: self)
            } else if btnLabel == "Cím" {
                performSegue(withIdentifier: "changeAddress", sender: self)
            } else if btnLabel == "Elérhetőség" {
                performSegue(withIdentifier: "changeContact", sender: self)
            } else if btnLabel == "Fiók törlése" {
                performSegue(withIdentifier: "deleteAccount", sender: self)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.profilePicture.kf.indicatorType = .activity
        initializeUserInfo()
        createObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeHideKeyboard()
        operationBtnCollection.forEach { (btn) in
            btn.isHidden = true
            btn.alpha = 0
        }
    }
    
    @IBAction func choosePhotoButtonPressed(_ sender: UIButton) {
        showPhotoAlert()
    }
    
}

extension MyProfileViewController {
    
    private func createObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(MyProfileViewController.segueToWelcome(notification:)), name: deleteName, object: nil)
        
    }
    
    @objc
    private func segueToWelcome(notification: NSNotification) {
        
        UD.shared.defaults.removeObject(forKey: "uid")
        UD.shared.defaults.removeObject(forKey: "role")
        performSegue(withIdentifier: "deletedAccount", sender: self)
        
    }
    
    //MARK: - Upload Profile Picture
    
    private func showPhotoAlert() {
        
        let alert = UIAlertController(title: "Fotó kiválasztása:", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Kamera", style: .default, handler: {action
            in
            self.getPhoto(type: .camera)
        }))
        
        alert.addAction(UIAlertAction(title: "Könyvtár", style: .default, handler: {action
            in
            self.getPhoto(type: .photoLibrary)
        }))
        
        alert.addAction(UIAlertAction(title: "Mégsem", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func getPhoto(type: UIImagePickerController.SourceType) {
        
        let picker = UIImagePickerController()
        picker.sourceType = type
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        dismiss(animated: true, completion: nil)
        
        guard let image = info[.editedImage] as? UIImage else {
            Alerts.unsuccess(title: "Hiba történt!", message: "A fényképet nem sikerült kiválasztani!", viewController: self)
            return
        }
        
        ActivityIndicator.shared.setupActivityIndicator(view: self.view)
        DBHelper.shared.uploadProfilePic(image: image, uid: UD.shared.getUID()) {
            (res) in
            switch res {
            case .failure(_):
                Alerts.unsuccess(title: "Sikertelen feltöltés!", message: "Profilképét nem sikerült frissíteni!", viewController: self)
            case .success(_):
                self.profilePicture.image = image
                ActivityIndicator.shared.activityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func initializeUserInfo() {
        
        DBHelper.shared.myProfileGetUserInfo() {
            (res) in
            
            switch res {
            case .failure(_):
                Alerts.unsuccess(title: "Hiba történt!", message: "Az adatait nem sikerült betölteni! Kérem, próbálja meg újra!", viewController: self)
            case .success(let user):
                self.user = user
                if let url = URL(string: user.profilePicURL!) {
                    self.profilePicture.kf.indicatorType = .activity
                    self.profilePicture.kf.setImage(with: url, options: [.transition(.flipFromLeft(0.5))])
                    self.profilePicture?.layer.cornerRadius = (self.profilePicture?.frame.size.width ?? 0.0) / 2
                    self.profilePicture?.clipsToBounds = true
                    self.profilePicture?.layer.borderWidth = 3.0
                    self.profilePicture?.layer.borderColor = UIColor.red.cgColor
                }
            }
            
        }
    }
}
