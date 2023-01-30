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
    
    private var weekday: Int {
        return Calendar.current.component(.weekday, from: self)
    }
    
    func toTimeInfo() -> TimeInfo {
        let hour: Int
        let type: TimeInfo.TimeType = self.hour < 12 ? .am : .pm
        switch self.hour {
        case 0 :        hour = 12
        case 13..<24 :  hour = self.hour - 12
        default :       hour = self.hour
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
        let weekday: String
        switch self.weekday {
        case 1 : weekday = "일"
        case 2 : weekday = "월"
        case 3 : weekday = "화"
        case 4 : weekday = "수"
        case 5 : weekday = "목"
        case 6 : weekday = "금"
        default : weekday = "토"
        }
        return String(format: "%02d월 %02d일 \(weekday)요일", self.month, self.day)
    }
}
