//
//  DBHelper.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2023. 02. 06..
//

import Foundation
import Firebase
import FirebaseStorage
import UIKit

class DBHelper {
    
    static let shared = DBHelper()
    
    private let db = Firestore.firestore()
    
    func loadUsers(viewController: UIViewController, userType: String,
                     completion: @escaping ([GetUser], [GetAddress], [Contact]) -> Void ) {
        
        var users: [GetUser] = []
        var userAddresses: [GetAddress] = []
        var contact: [Contact] = []
        
        db.collection("users").whereField("role", isEqualTo: userType)
            .getDocuments() { (querySnapshot, err) in
                if err != nil {
                    Alerts.unsuccess(title: "Hiba történt!", message: "Sikertelen lekérdezés! Kérem, próbálja meg újra!", viewController: viewController)
                    completion(users, userAddresses, contact)
                } else {
                    if querySnapshot!.documents.count > 0 {
                        for document in querySnapshot!.documents {
                            let data = document.data()
                            let user = GetUser(uid: data["uid"] as? String, role: data["role"] as? String, gender: data["gender"] as? String, title: data["title"] as? String, firstname: data["firstname"] as? String, lastname: data["lastname"] as? String, spec_ill: data["spec_ill"] as? String, taj: data["taj"] as? String, profilePicURL: data["profilePicURL"] as? String)
                            users.append(user)
                            
                            self.db.collection("addresses").whereField("uid", isEqualTo: user.uid!)
                                .getDocuments() { (querySnapshot, err) in
                                    if err != nil {
                                        Alerts.unsuccess(title: "Hiba történt!", message: "Sikertelen lekérdezés! Kérem, próbálja meg újra!", viewController: viewController)
                                    } else {
                                        if querySnapshot!.documents.count > 0 {
                                            for document in querySnapshot!.documents {
                                                let data = document.data()
                                                let address = GetAddress(city: data["city"] as? String, country: data["country"] as? String, house: data["house"] as? String, state: data["state"] as? String, street: data["street"] as? String, uid: data["uid"] as? String, postcode: data["zipcode"] as? String)
                                                userAddresses.append(address)
                                                
                                                self.db.collection("contacts").whereField("uid", isEqualTo: user.uid!)
                                                    .getDocuments() { (querySnapshot, err) in
                                                        if err != nil {
                                                            Alerts.unsuccess(title: "Hiba történt!", message: "Sikertelen lekérdezés! Kérem, próbálja meg újra!", viewController: viewController)
                                                        } else {
                                                            if querySnapshot!.documents.count > 0 {
                                                                for document in querySnapshot!.documents {
                                                                    let contactData = document.data()
                                                                    let gotContact = Contact(uid:contactData["uid"] as? String, email: contactData["email"] as? String, phone: contactData["phone"] as? String)
                                                                    
                                                                    contact.append(gotContact)
                                                                    
                                                                    completion(users, userAddresses, contact)

                                                                }
                                                            } else {
                                                                completion(users, userAddresses, contact)

                                                            }
                                                        }
                                                    }
                                            }
                                        } else {
                                            completion(users, userAddresses, contact)
                                        }
                                    }
                                }
                        }
                    } else {
                        completion(users, userAddresses, contact)
                    }
                }
            }
    }
    
    func delete(role: String, table: String, uid: String, completion: @escaping (Result<String, Error>) -> Void) {
        let userRole = UD.shared.getRole()
        if userRole == role
        {
            self.db.collection(table).document(uid).delete() { (err) in
                if err != nil {
                    completion(.failure(err!))
                } else {
                    completion(.success("Success"))
                }
            }
        }
    }
    
    func login(viewController: UIViewController, email: String, password: String,
               completion: @escaping (Result<String, Error>) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) {(result, error) in
            if error != nil {
                completion(.failure(error!))
            }
            else {
                let db = Firestore.firestore()
                let docRef = db.collection("users").document(result!.user.uid)
                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let dataDescription = document.data()
                        let role = dataDescription?["role"] as! String
                        UD.shared.defaults.setValue(Auth.auth().currentUser?.uid, forKey: "uid")
                        UD.shared.defaults.setValue(role, forKey: "role")
                        completion(.success(role))
                    } else {
                        Alerts.unsuccess(title: "Sikertelen bejelentkezés!", message: "Kérem, próbálja meg újra!", viewController: viewController)
                    }
                }
            }
        }
        
    }
    
    func auth(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {

        let user = Auth.auth().currentUser
        var credential: AuthCredential
        
        credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        user?.reauthenticate(with: credential, completion: { (result, error) in
            if let err = error {
                completion(.failure(err))
            } else {
                completion(.success("Success"))
            }
        })
        
    }
    
    func register(email: String, password: String,
                  firstname: String, lastname: String, gender: String, role: String, title: String,
                  completion: @escaping (Result<String, Error>) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
            
            if err != nil {
                completion(.failure(err!))
            }
            else {

                let db = Firestore.firestore()
                
                db.collection("users").document(result!.user.uid).setData([
                    "firstname": firstname,
                    "gender": gender,
                    "lastname": lastname,
                    "role": role,
                    "title": title,
                    "uid": result!.user.uid,
                ]) {
                    (error) in
                    
                    if error != nil {
                        completion(.failure(error!))
                    }
                    else {
                        let userRef = db.collection("users").document(result!.user.uid)
                        userRef.updateData([
                            "profilePicURL": "https://firebasestorage.googleapis.com/v0/b/idopontfoglalo-5b900.appspot.com/o/profilePictures%2Fuser.jpg?alt=media&token=84694973-bb2c-40b8-86b0-b98796735674"
                        ]) { err in
                            if err != nil {
                                completion(.failure(err!))
                            } else {
                                self.db.collection("addresses").document(result!.user.uid).setData([
                                    "uid": result!.user.uid
                                ]) {
                                    (error) in
                                    if error != nil {
                                        completion(.failure(error!))
                                    } else {
                                        self.db.collection("contacts").document(result!.user.uid).setData([
                                            "uid": result!.user.uid,
                                            "email": email
                                        ]) {
                                            (error) in
                                            if error != nil {
                                                completion(.failure(error!))
                                            } else {
                                                
                                                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                                                changeRequest?.displayName = "\(lastname) \(firstname)"
                                                changeRequest?.commitChanges() { error in
                                                    if error != nil {
                                                        completion(.failure(error!))
                                                    }
                                                    else {
                                                        UD.shared.defaults.setValue(result!.user.uid, forKey: "uid")
                                                        UD.shared.defaults.setValue(role, forKey: "role")
                                                        completion(.success("Success."))
                                                    }
                                                }

                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
            
        }
        
    }
    
    func myProfileUpdate(title: String, firstname: String, lastname: String, spec_ill: String,
                         taj: String,
                         completion: @escaping (Result<String, Error>) -> Void) {
        
        db.collection("users").document(UD.shared.getUID()).updateData([
            "title": title,
            "firstname": firstname,
            "lastname": lastname,
            "spec_ill": spec_ill,
            "taj": taj,
            "uid": UD.shared.getUID(),
            "role": UD.shared.getRole(),
        ]) {
            (error) in
            
            if error != nil {
                completion(.failure(error!))
            }
            else {

                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = "\(lastname) \(firstname)"
                changeRequest?.commitChanges() { error in
                    if error != nil {
                        completion(.failure(error!))
                    }
                    else {
                        completion(.success("Success."))
                    }
                }
            }
        }
        
    }
    
    func myProfileUpdateAddresses(country: String, state: String, zipcode: String, city: String,
                                  street: String, house: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        db.collection("addresses").document(UD.shared.getUID()).updateData([
            "country": country,
            "state": state,
            "zipcode": zipcode,
            "city": city,
            "street": street,
            "house": house,
        ]) {
            (error) in
            
            if error != nil {
                completion(.failure(error!))
            }
            else {

                completion(.success("Success."))
                
            }
        }
    }
    
    func myProfileUpdatePhoneNumber(email: String, phone: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        db.collection("contacts").document(UD.shared.getUID()).updateData([
            "phone": phone
        ]) {
            (error) in
            
            if error != nil {
                completion(.failure(error!))
            }
            else {
                completion(.success("Success."))
                
            }
        }
        
    }
    
    func myProfileUpdateEmail(email: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        Auth.auth().currentUser?.updateEmail(to: email) { error in
            if error != nil {
                completion(.failure(error!))
            } else {
                self.db.collection("contacts").document(UD.shared.getUID()).updateData([
                    "email": email
                ]) {
                    (error) in
                    
                    if error != nil {
                        completion(.failure(error!))
                    }
                    else {
                        completion(.success("Success."))
                        
                    }
                }
            }
        }
        
    }
    
    func updatePassword(password: String, completion: @escaping (Result<String, Error>) -> Void) {
        Auth.auth().currentUser?.updatePassword(to: password) { error in
            
            if error != nil {
                completion(.failure(error!))
                }
            else {
                completion(.success("Success"))
            }
        }
    }
    
    func myProfileGetUserInfo(completion: @escaping (Result<GetUser, Error>) -> Void) {
        
        db.collection("users").whereField("uid", isEqualTo: UD.shared.getUID())
            .getDocuments() { (querySnapshot, err) in
                if err != nil {
                    completion(.failure(err!))
                } else {
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        let user = GetUser(uid: data["uid"] as? String, role: data["role"] as? String, gender: data["gender"] as? String, title: data["title"] as? String, firstname: data["firstname"] as? String, lastname: data["lastname"] as? String, spec_ill: data["spec_ill"] as? String, taj: data["taj"] as? String, profilePicURL: data["profilePicURL"] as? String)
                        completion(.success(user))
                    }
                }
            }
        
    }
    
    func myProfileGetAddress(completion: @escaping (Result<GetAddress, Error>) -> Void) {
        
        db.collection("addresses").whereField("uid", isEqualTo: UD.shared.getUID())
            .getDocuments() { (querySnapshot, err) in
                if err != nil {
                    completion(.failure(err!))
                } else {
                    if querySnapshot!.documents.count > 0 {
                        for document in querySnapshot!.documents {
                            let data = document.data()
                            let address = GetAddress(city: data["city"] as? String, country: data["country"] as? String, house: data["house"] as? String, state: data["state"] as? String, street: data["street"] as? String, uid: UD.shared.getUID(), postcode: data["zipcode"] as? String)
                            completion(.success(address))
                        }
                    } else {
                        let address = GetAddress()
                        completion(.success(address))
                    }
                    
                }
            }
        
    }
    
    func uploadProfilePic(image: UIImage, uid: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        let userRef = db.collection("users").document(uid)
        
        let uploadRef = Storage.storage().reference(withPath: "profilePictures/\(uid).jpg")
        uploadRef.delete { error in
            guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
            let uploadMetaData = StorageMetadata.init()
            uploadMetaData.contentType = "image/jpeg"
            
            uploadRef.putData(imageData, metadata: uploadMetaData) { (downloadMetaData, error) in
                if error != nil {
                    completion(.failure(error!))
                }
                else {
                    uploadRef.downloadURL(completion: { (url, error) in
                        guard let url = url else {
                            return
                        }

                        userRef.updateData([
                            "profilePicURL": url.absoluteString
                        ]) { err in
                            if err != nil {
                                completion(.failure(err!))
                            } else {
                                completion(.success("Success"))
                            }
                        }
                    })
                }
            }
        }
        
    }
    
    func doctorLoadAppointments(viewController: UIViewController, completion: @escaping ([GetUser], [Appointment], [GetAddress], [Contact]) -> Void) {
        
        var patients: [GetUser] = []
        var addresses: [GetAddress] = []
        var appointments: [Appointment] = []
        var contacts: [Contact] = []
        
        let uid = UD.shared.getUID()
        db.collection("appointments").whereField("doctorID", isEqualTo: uid)
            .getDocuments() { (querySnapshot, err) in
                if err != nil {
                    Alerts.unsuccess(title: "Hiba történt!", message: "Az időpontok betöltése sikertelen volt! Kérem, próbálja meg újra!", viewController: viewController)
                    completion(patients, appointments, addresses, contacts)
                } else {
                    if (querySnapshot!.documents.count > 0) {
                        for document in querySnapshot!.documents {
                            let data = document.data()
                            if (data["name"] as! String == "Foglalt időpont.") {
                                
                                self.db.collection("users").whereField("uid", isEqualTo: data["patientID"] as! String)
                                    .getDocuments() { (querySnapshot, err) in
                                        if err != nil {
                                            Alerts.unsuccess(title: "Hiba történt!", message: "Sikertelen lekérdezés! Kérem, próbálja meg újra!", viewController: viewController)
                                            completion(patients, appointments, addresses, contacts)
                                        } else {
                                            for document in querySnapshot!.documents {
                                                let patientData = document.data()
                                                
                                                let user = GetUser(uid: patientData["uid"] as? String, role: patientData["role"] as? String, gender: patientData["gender"] as? String, title: patientData["title"] as? String, firstname: patientData["firstname"] as? String, lastname: patientData["lastname"] as? String, spec_ill: patientData["spec_ill"] as? String, taj: patientData["taj"] as? String, profilePicURL: patientData["profilePicURL"] as? String)
                                                patients.append(user)
                                                
                                                let name = "\(patientData["lastname"] as! String) \(patientData["firstname"] as! String)"
                                                let date = data["date"] as? Timestamp
                                                let app = Appointment(_id: data["uid"] as? String, doctorID: data["doctorID"] as? String, patientID: data["patientID"] as? String, name: name, date: date?.dateValue())
                                                appointments.append(app)
                                                
                                                self.db.collection("addresses").whereField("uid", isEqualTo: data["patientID"] as! String)
                                                    .getDocuments() { (querySnapshot, err) in
                                                        if err != nil {
                                                            Alerts.unsuccess(title: "Hiba történt!", message: "Sikertelen lekérdezés! Kérem, próbálja meg újra!", viewController: viewController)
                                                            completion(patients, appointments, addresses, contacts)
                                                        } else {
                                                            if (querySnapshot!.documents.count > 0) {
                                                                for document in querySnapshot!.documents {
                                                                    let data = document.data()

                                                                    let address = GetAddress(city: data["city"] as? String, country: data["country"] as? String, house: data["house"] as? String, state: data["state"] as? String, street: data["street"] as? String, uid: data["uid"] as? String, postcode: data["zipcode"] as? String)
                                                                    
                                                                    addresses.append(address)
                                                                    
                                                                    self.db.collection("contacts").whereField("uid", isEqualTo: user.uid!)
                                                                        .getDocuments() { (querySnapshot, err) in
                                                                            if err != nil {
                                                                                Alerts.unsuccess(title: "Hiba történt!", message: "Sikertelen lekérdezés! Kérem, próbálja meg újra!", viewController: viewController)
                                                                                completion(patients, appointments, addresses, contacts)
                                                                            } else {
                                                                                if querySnapshot!.documents.count > 0 {
                                                                                    for document in querySnapshot!.documents {
                                                                                        let contactData = document.data()
                                                                                        let gotContact = Contact(uid:contactData["uid"] as? String, email: contactData["email"] as? String, phone: contactData["phone"] as? String)
                                                                                        
                                                                                        contacts.append(gotContact)
                                                                                        
                                                                                        completion(patients, appointments, addresses, contacts)

                                                                                    }
                                                                                } else {
                                                                                    completion(patients, appointments, addresses, contacts)

                                                                                }
                                                                            }
                                                                        }
                                                                    
                                                                }
                                                            } else {
                                                                completion(patients, appointments, addresses, contacts)
                                                            }
                                                        }
                                                }
                                            }
                                        }
                                }
                                
                            } else {
                                
                                let date = data["date"] as? Timestamp
                                let app = Appointment(_id: data["uid"] as? String, doctorID: data["doctorID"] as? String, patientID: data["patientID"] as? String, name: data["name"] as? String, date: date?.dateValue())
                                appointments.append(app)

                                completion(patients, appointments, addresses, contacts)
                            }
                            
                        }
                    } else {
                        completion(patients, appointments, addresses, contacts)
                    }
                }
            }
                
    }
    
    func doctorAddAppointment(doctorID: String, Name: String, Date: Date, uid: String,
                              completion: @escaping (Result<String, Error>) -> Void) {
        
        let role = UD.shared.getRole()
        
        if role == "doctor" {
            
            self.db.collection("appointments").document(uid).setData([
                "date": Date,
                "doctorID": doctorID,
                "patientID": "",
                "name": Name,
                "uid": uid
            ]) {
                (error) in
                
                
                if error != nil {
                    completion(.failure(error!))
                }
                else {
                    completion(.success("Success"))
                }
            }
        }
        
    }
    
    func patientGetAppointments(viewController: UIViewController, completion: @escaping ([Appointment], [GetUser], [GetAddress], [Contact]) -> Void) {
        
        var appointments: [Appointment] = []
        var users: [GetUser] = []
        var userAddresses: [GetAddress] = []
        var contact: [Contact] = []
        
        db.collection("appointments").whereField("patientID", isEqualTo: UD.shared.getUID())
            .getDocuments() { (QuerySnapshot, err) in
                if err != nil {
                    Alerts.unsuccess(title: "Hiba történt!", message: "Az időpontjai lekérdezése sikertelen volt! Kérem, próbálja meg újra!", viewController: viewController)
                    completion(appointments, users, userAddresses, contact)
                } else {
                    if QuerySnapshot!.documents.count > 0 {
                        for document in QuerySnapshot!.documents {
                            let appData = document.data()
                            let date = appData["date"] as? Timestamp
                            let app = Appointment(_id: appData["uid"] as? String, doctorID: appData["doctorID"] as? String, patientID: appData["patientID"] as? String, name: appData["name"] as? String, date: date?.dateValue())
                            
                            appointments.append(app)
                            
                            self.db.collection("users").whereField("uid", isEqualTo: app.doctorID!)
                                .getDocuments() { (querySnapshot, err) in
                                    if err != nil {
                                        Alerts.unsuccess(title: "Hiba történt!", message: "Sikertelen lekérdezés! Kérem, próbálja meg újra!", viewController: viewController)
                                        completion(appointments, users, userAddresses, contact)
                                    } else {
                                        if querySnapshot!.documents.count > 0 {
                                            for document in querySnapshot!.documents {
                                                let data = document.data()
                                                let user = GetUser(uid: data["uid"] as? String, role: data["role"] as? String, gender: data["gender"] as? String, title: data["title"] as? String, firstname: data["firstname"] as? String, lastname: data["lastname"] as? String, spec_ill: data["spec_ill"] as? String, taj: data["taj"] as? String, profilePicURL: data["profilePicURL"] as? String)
                                                users.append(user)
                                                
                                                self.db.collection("addresses").whereField("uid", isEqualTo: user.uid!)
                                                    .getDocuments() { (querySnapshot, err) in
                                                        if err != nil {
                                                            Alerts.unsuccess(title: "Hiba történt!", message: "Sikertelen lekérdezés! Kérem, próbálja meg újra!", viewController: viewController)
                                                            completion(appointments, users, userAddresses, contact)
                                                        } else {
                                                            if querySnapshot!.documents.count > 0 {
                                                                for document in querySnapshot!.documents {
                                                                    let data = document.data()
                                                                    let address = GetAddress(city: data["city"] as? String, country: data["country"] as? String, house: data["house"] as? String, state: data["state"] as? String, street: data["street"] as? String, uid: data["uid"] as? String, postcode: data["zipcode"] as? String)
                                                                    userAddresses.append(address)
                                                                    
                                                                    self.db.collection("contacts").whereField("uid", isEqualTo: user.uid!)
                                                                        .getDocuments() { (querySnapshot, err) in
                                                                            if err != nil {
                                                                                Alerts.unsuccess(title: "Hiba történt!", message: "Sikertelen lekérdezés! Kérem, próbálja meg újra!", viewController: viewController)
                                                                                completion(appointments, users, userAddresses, contact)
                                                                            } else {
                                                                                if querySnapshot!.documents.count > 0 {
                                                                                    for document in querySnapshot!.documents {
                                                                                        let contactData = document.data()
                                                                                        let gotContact = Contact(uid:contactData["uid"] as? String, email: contactData["email"] as? String, phone: contactData["phone"] as? String)
                                                                                        
                                                                                        contact.append(gotContact)
                                                                                        
                                                                                        completion(appointments, users, userAddresses, contact)

                                                                                    }
                                                                                } else {
                                                                                    completion(appointments, users, userAddresses, contact)

                                                                                }
                                                                            }
                                                                        }
                                                                }
                                                            } else {
                                                                completion(appointments, users, userAddresses, contact)
                                                            }
                                                        }
                                                    }
                                            }
                                        } else {
                                            completion(appointments, users, userAddresses, contact)                                        }
                                    }
                                }
                            
                        }
                    } else {
                        completion(appointments, users, userAddresses, contact)
                    }
                }
            }
            
    }
        
    func patientDeleteAppointment(appRef: DocumentReference, completion: @escaping (Result<String, Error>) -> Void) {
        
        appRef.updateData([
            "patientID": "",
            "name": "Szabad időpont."
        ]) { err in
            if err != nil {
                completion(.failure(err!))
            } else {
                completion(.success("Success"))
            }
        }
        
    }
    
    func patientGetFreeAppointments(viewController: UIViewController, doctorID: String,completion: @escaping ([Appointment]) -> Void) {
        
        var appointments: [Appointment] = []
        
        db.collection("appointments").whereField("doctorID", isEqualTo: doctorID)
            .whereField("name", isEqualTo: "Szabad időpont.")
            .getDocuments() { (querySnapshot, err) in
                if err != nil {
                    Alerts.unsuccess(title: "Hiba történt!", message: "Az időpontok lekérdezése sikertelen volt. Kérem, próbálja meg újra!", viewController: viewController)
                    completion(appointments)
                } else {
                    if (querySnapshot!.documents.count > 0) {
                        for document in querySnapshot!.documents {
                            let data = document.data()
                            let date = data["date"] as? Timestamp
                            let app = Appointment(_id: data["uid"] as? String, doctorID: data["doctorID"] as? String, patientID: data["patientID"] as? String, name: data["name"] as? String, date: date?.dateValue())
                            appointments.append(app)
                            completion(appointments)
                            }
                    } else {
                        completion(appointments)
                    }
                    }
                    
                }
        }
    
    func patientGetContact(completion: @escaping (Result<Contact, Error>) -> Void) {
        
        db.collection("contacts").whereField("uid", isEqualTo: UD.shared.getUID())
            .getDocuments() { (querySnapshot, err) in
                if err != nil {
                    completion(.failure(err!))
                } else {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                    dateFormatter.locale = NSLocale.current
                    if (querySnapshot!.documents.count > 0) {
                        for document in querySnapshot!.documents {
                            let data = document.data()
                            let contact = Contact(uid: data["uid"] as? String, email: data["email"] as? String, phone: data["phone"] as? String)
                            completion(.success(contact))
                            }
                    } else {
                        let contact = Contact()
                        completion(.success(contact))
                    }
                    }
                    
                }
        
    }
    
    func patientBookAppointment(appRef: DocumentReference, completion: @escaping (Result<String, Error>) -> Void) {
        
        appRef.updateData([
            "patientID": UD.shared.getUID(),
            "name": "Foglalt időpont."
        ]) { err in
            if err != nil {
                completion(.failure(err!))
            } else {
                completion(.success("Success"))
            }
        }
        
    }
    
    func rateDoctor(uid: String, rate: Int, doctorID: String, patientID: String,
                    patientName: String, rateTitle: String, rateText: String,
                    completion: @escaping (Result<String, Error>) -> Void) {
        
        db.collection("ratings").document(uid).setData([
            "uid": uid,
            "rate": rate,
            "doctorID": doctorID,
            "patientID": patientID,
            "patientName": patientName,
            "rateTitle": rateTitle,
            "rateText": rateText
        ]) {
            (error) in
            
            if error != nil {
                completion(.failure(error!))
            }
            else {
                completion(.success("Success"))
            }
        }
        
    }
    
    func userGetRatings(viewController: UIViewController, idType: String, id: String, completion: @escaping ([Rating]) -> Void) {
        
        var ratingArray: [Rating] = []
        
        db.collection("ratings").whereField(idType, isEqualTo: id)
            .getDocuments() { (querySnapshot, err) in
                if err != nil {
                    Alerts.unsuccess(title: "Hiba történt!", message: "Az értékelések lekérdezése sikertelen volt! Kérem, próbálja meg újra!", viewController: viewController)
                    completion(ratingArray)
                } else {
                    if querySnapshot!.documents.count > 0 {
                        for document in querySnapshot!.documents {
                            let data = document.data()
                            let rating = Rating(uid: data["uid"] as? String, rate: data["rate"] as? Int, doctorID: data["doctorID"] as? String, patientID: data["patientID"] as? String, patientName: data["patientName"] as? String, rateTitle: data["rateTitle"] as? String, rateText: data["rateText"] as? String)
                            ratingArray.append(rating)
                            
                            completion(ratingArray)
                        }
                    } else {
                        ratingArray = []
                        completion(ratingArray)
                    }
                    
                }
            }
        
    }
    
    func patientGetName(viewController: UIViewController,completion: @escaping (Result<String, Error>) -> Void) {
        
        db.collection("users").whereField("uid", isEqualTo: UD.shared.getUID())
            .getDocuments() { (querySnapshot, err) in
                if err != nil {
                    completion(.failure(err!))
                } else {
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        let name = "\(data["lastname"] as! String) \(data["firstname"] as! String)"
                        completion(.success(name))
                    }
                }
            }
        
    }
    
    func resetPassword(email: String, completion: @escaping (Result<String, Error>) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if error != nil {
                completion(.failure(error!))
            } else {
                completion(.success("Success"))
            }
        }
    }
    
    func deleteAccount(completion: @escaping (Result<String, Error>) -> Void) {
        
        self.db.collection("users").document(UD.shared.getUID()).delete() { (err) in
            if err != nil {
                completion(.failure(err!))
            } else {
                self.db.collection("addresses").document(UD.shared.getUID()).delete() { (err) in
                    if err != nil {
                        completion(.failure(err!))
                    } else {
                        self.db.collection("contacts").document(UD.shared.getUID()).delete() { (err) in
                            if err != nil {
                                completion(.failure(err!))
                            } else {
                                Auth.auth().currentUser?.delete() { (error) in
                                    if error != nil {
                                        completion(.failure(error!))
                                    } else {
                                        completion(.success("Success"))
                                    }
                                }
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    func adminDeleteUser(userUID: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        guard let url = URL(string: "https://busy-red-chimpanzee-tux.cyclic.app/delete") else { return }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        let currentUser = Auth.auth().currentUser
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error {
                completion(.failure(error))
            } else {
                
                let params = ["uid": userUID, "idToken": idToken]
                
                do {
                    let data = try JSONSerialization.data(withJSONObject: params, options: .init())
                    urlRequest.httpBody = data
                    urlRequest.setValue("application/json", forHTTPHeaderField: "content-type")
                    
                    URLSession.shared.dataTask(with: urlRequest) { (data, resp, err) in
                        
                        guard let data = data else { return }
                        
                        let response = String(data: data, encoding: .utf8)
                        if response! == "Deleted successfully" {
                            let uploadRef = Storage.storage().reference(withPath: "profilePictures/\(userUID).jpg")
                            uploadRef.delete { error in
                                if error != nil {
                                    completion(.success(response!))
                                } else {
                                    completion(.success(response!))
                                }
                            }
                            
                        } else {
                            let errorString = String(data: data, encoding: .utf8)
                            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: errorString ?? ""])))
                        }
                        
                    } .resume()
                } catch {
                    completion(.failure(error))
                }
                
            }
            
        }
    }
    
    func adminAddAdmin(gender: String, title: String, firstname: String, lastname: String, email: String, password: String, completion: @escaping (Result<String, Error>) -> ()) {
        
        guard let url = URL(string: "https://busy-red-chimpanzee-tux.cyclic.app/createUser") else { return }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        let currentUser = Auth.auth().currentUser
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error {
                completion(.failure(error))
            } else {
                
                let params = ["idToken": idToken, "gender": gender, "title": title, "firstname": firstname, "lastname": lastname, "email": email, "password": password]
                
                do {
                    let data = try JSONSerialization.data(withJSONObject: params, options: .init())
                    urlRequest.httpBody = data
                    urlRequest.setValue("application/json", forHTTPHeaderField: "content-type")
                    
                    URLSession.shared.dataTask(with: urlRequest) { (data, resp, err) in
                        
                        guard let data = data else { return }
                        
                        let response = String(data: data, encoding: .utf8)
                        if response! == "Admin created successfully" {
                            completion(.success(response!))
                        } else {
                            let errorString = String(data: data, encoding: .utf8)
                            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: errorString ?? ""])))
                        }
                        
                    } .resume()
                } catch {
                    completion(.failure(error))
                }
                
            }
        }
    }
    
    func verifyEmail(completion: @escaping (Result<String, Error>) -> Void) {
        Auth.auth().currentUser?.sendEmailVerification { error in
            if error != nil {
                completion(.failure(error!))
            } else {
                completion(.success("Success"))
            }
        }
    }
        
}
