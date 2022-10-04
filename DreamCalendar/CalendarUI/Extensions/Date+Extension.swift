//
//  Date+Extension.swift
//  CalendarUI
//
//  Created by 이지수 on 2022/10/04.
//

import Foundation

public extension Date {
    var year: Int {
        return Calendar.current.component(.year, from: self)
    }
    
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    var weekday: Days {
        let rawValue = Calendar.current.component(.weekday, from: self)
        return Days(rawValue: rawValue) ?? Days.firstWeekday
    }
}

public extension DateFormatter {
    static let DCdateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-m-d"
        return dateFormatter
    }()
}
