//
//  ScheduleAdditionViewModel.swift
//  DreamCalendar
//
//  Created by 이지수 on 2022/11/26.
//

import Foundation

struct TimeInfo {
    let date: Date
    let hour: Int
    let minute: Int
    let type: TimeType
    
    enum TimeType {
        case am, pm
        
        var title: String {
            switch self {
            case .am :
                return "오전"
            case .pm :
                return "오후"
            }
        }
    }
    
    enum DefaultTimeType {
        case start, end
    }
    
    func toDate() -> Date {
        let actualHour: Int
        switch (self.hour, self.type) {
        case (12, .am) :    actualHour = 0
        case (12, .pm) :    actualHour = 12
        case (_, .pm) :     actualHour = hour + 12
        default :           actualHour = hour
        }
        let date = Calendar.current.date(from: DateComponents(
            calendar: Calendar.current,
            year: self.date.year,
            month: self.date.month,
            day: self.date.day,
            hour: actualHour,
            minute: self.minute,
            second: self.date.second)
        )
        return date ?? Date()
    }
    
    static func defaultTime(_ type: DefaultTimeType, date: Date) -> TimeInfo {
        let zero = 0
        let halfOfDay = 12
        let day = 24
        let addValue: Int = type == .start ? 1 : 2
        
        let currentDate = Date()
        var hour: Int = currentDate.hour
        let type: TimeType
        
        switch (currentDate.minute > zero, currentDate.hour < halfOfDay, currentDate.hour + addValue < halfOfDay, currentDate.hour + addValue < day) {
        case (true, _, true, _) :
            hour += addValue
            type = .am
        case (true, _, false, true) :
            hour += addValue
            type = .pm
        case (true, _, false, false) :
            hour = (hour + addValue) % day
            type = .am
        case (false, true, _, _) :
            type = .am
        case (false, false, _, _) :
            type = .pm
        }
        hour = (hour % halfOfDay == zero) ? halfOfDay : (hour % halfOfDay)
        return TimeInfo(date: date, hour: hour, minute: zero, type: type)
    }
}

