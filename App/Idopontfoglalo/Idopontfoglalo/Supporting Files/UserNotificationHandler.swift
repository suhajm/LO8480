//
//  Notification.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2023. 02. 22..
//  https://www.youtube.com/watch?v=qDbbdvTYpVI&list=LL&index=8&t=194s
//

import Foundation
import UserNotifications
import UIKit

class UserNotificationHandler {
    
    static let shared = UserNotificationHandler()
    
    var notificationCenter = UNUserNotificationCenter.current()

    func scheduleNotification(identifier: String, date: Date,
                              title: String, message: String, viewController: UIViewController) {
        notificationCenter.getNotificationSettings { (settings) in
                    
                    DispatchQueue.main.async
                    {
                        let title = title
                        let message = message
                        let minusOneDay = Calendar.current.date(byAdding: .day, value: -1, to: date)
                        
                        if(settings.authorizationStatus == .authorized)
                        {
                            let content = UNMutableNotificationContent()
                            content.title = title
                            content.body = message
                            
                            let dateComp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: minusOneDay!)
                            
                            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: false)
                            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                            
                            self.notificationCenter.add(request) { (error) in
                                if(error != nil)
                                {
                                    print("Error " + error.debugDescription)
                                    return
                                } else {
                                    print("notification created")
                                }
                            }

                        }
                        else
                        {
                            let ac = UIAlertController(title: "Engedélyezi az értesítéseket?", message: "Ahhoz, hogy 24 órával az kiírt időpontja előtt értesíteni tudjuk, engedélyeznie kell az értesítéseket.", preferredStyle: .alert)
                            let goToSettings = UIAlertAction(title: "Beállítások", style: .default)
                            { (_) in
                                guard let setttingsURL = URL(string: UIApplication.openSettingsURLString)
                                else
                                {
                                    return
                                }
                                
                                if(UIApplication.shared.canOpenURL(setttingsURL))
                                {
                                    UIApplication.shared.open(setttingsURL) { (_) in}
                                }
                            }
                            ac.addAction(goToSettings)
                            ac.addAction(UIAlertAction(title: "Mégsem", style: .default, handler: { (_) in}))
                            viewController.present(ac, animated: true)
                        }
                    }
                }
    }
}
