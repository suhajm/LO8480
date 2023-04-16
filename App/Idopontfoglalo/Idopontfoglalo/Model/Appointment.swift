//
//  Appointment.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2022. 08. 22..
//

import Foundation

struct Appointment: Codable {
    
    var _id: String!
    var doctorID: String!
    var patientID: String!
    var name: String!
    var date: Date!
    
    func appointmentToDate(date: Date, list: [Appointment]) -> [Appointment] {
        
        var daysAppointments = [Appointment]()
        for appointment in list {
            if(Calendar.current.isDate(appointment.date, inSameDayAs:date))
            {
                daysAppointments.append(appointment)
            }
        }
        return daysAppointments
    }
}
