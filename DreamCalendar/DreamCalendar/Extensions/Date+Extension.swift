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
}
