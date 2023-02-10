//
//  Date+Extension.swift
//  DreamCalendar
//
//  Created by 이지수 on 2022/11/19.
//

import Foundation

extension Date {
    var hour: Int {
        return Calendar.current.component(.hour, from: self)
    }
    
    var minute: Int {
        return Calendar.current.component(.minute, from: self)
    }
    
    var second: Int {
        return Calendar.current.component(.second, from: self)
    }
    
    var weekday: String {
        let weekday = Calendar.current.component(.weekday, from: self)
        switch weekday {
        case 1 : return "일"
        case 2 : return "월"
        case 3 : return "화"
        case 4 : return "수"
        case 5 : return "목"
        case 6 : return "금"
        default : return "토"
        }
    }
    
    var nextMonth: Date {
        return Calendar.current.date(byAdding: .month,
                                          value: +1,
                                          to: self) ?? self
    }
    
    var previousMonth: Date {
        return Calendar.current.date(byAdding: .month,
                                          value: -1,
                                          to: self) ?? self
    }
    
    var firstDayOfMonth: Date {
        let firstDay = 1
        let zero = 0
        
        return Calendar.current.date(from: DateComponents(
            calendar: Calendar.current,
            year: self.year,
            month: self.month,
            day: firstDay,
            hour: zero,
            minute: zero,
            second: zero,
            nanosecond: zero)
        ) ?? self
    }
    
    var startOfDay: Date {
        let zero = 0
        
        return Calendar.current.date(from: DateComponents(
            calendar: Calendar.current,
            year: self.year,
            month: self.month,
            day: self.day,
            hour: zero,
            minute: zero,
            second: zero,
            nanosecond: zero)
        ) ?? self
    }
    
    var endOfDay: Date {
        guard let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: self)?.startOfDay else { return self }
        return Calendar.current.date(byAdding: .second, value: -1, to: nextDate) ?? self
    }
    
    func toTimeInfo() -> TimeInfo {
        let startOfDay = 0
        let halfOfDay = 12
        let day = 24
        
        let hour: Int
        let type: TimeInfo.TimeType = self.hour < halfOfDay ? .am : .pm
        
        switch self.hour {
        case startOfDay :
            hour = halfOfDay
        case (halfOfDay + 1)..<day :
            hour = self.hour - halfOfDay
        default :
            hour = self.hour
        }
        
        return TimeInfo(date: self,
                        hour: hour,
                        minute: self.minute,
                        type: type)
    }
    
    func isSameDay(with comparisionDate: Date) -> Bool {
        return comparisionDate.year == self.year
        && comparisionDate.month == self.month
        && comparisionDate.day == self.day
    }
    
    func toString(with comparisonDate : Date) -> String {
        let timeInfo = self.toTimeInfo()
        switch self.isSameDay(with: comparisonDate) {
        case true :
            return String(format: "\(timeInfo.type.title) %02d:%02d", timeInfo.hour, timeInfo.minute)
        case false :
            return String(format: "%02d월 %02d일 \(timeInfo.type.title) %02d:%02d", self.month, self.day, timeInfo.hour, timeInfo.minute)
        }
    }
    
    func toString() -> String {
        return String(format: "%02d월 %02d일", self.month, self.day)
    }
    
    func timeToString() -> String {
        return self.toString(with: self)
    }
}
