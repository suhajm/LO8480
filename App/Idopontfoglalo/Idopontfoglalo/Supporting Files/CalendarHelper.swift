//
//  CalendarHelper.swift
//  Idopontfoglalo
//
//  Created by Suhaj Milán on 2022. 08. 22..
//  Source: https://www.youtube.com/watch?v=E-bFeJLsvW0
//          https://www.youtube.com/watch?v=abbWOYFZd68
//

import Foundation
import UIKit

class CalendarHelper
{
    let calendar = Calendar.current
    
    func dateString(date: Date) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy. MMMM"
        dateFormatter.locale = Locale(identifier: "hu_HU")
        return dateFormatter.string(from: date)
    }
    
    func timeString(date: Date) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter.string(from: date)
    }
    
    func dayOfMonth(date: Date) -> Int
    {
        let components = calendar.dateComponents([.day], from: date)
        return components.day!
    }
    
    func addDays(date: Date, days: Int) -> Date
    {
        return calendar.date(byAdding: .day, value: days, to: date)!
    }
    
    func mondayForDate(date: Date) -> Date
    {
        var current = date
        let oneWeekAgo = addDays(date: current, days: -7)
        
        while(current > oneWeekAgo)
        {
            let currentWeekDay = calendar.dateComponents([.weekday], from: current).weekday
            if(currentWeekDay == 2)
            {
                return current
            }
            current = addDays(date: current, days: -1)
        }
        return current
    }
    
}
