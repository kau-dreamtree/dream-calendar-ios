//
//  Days.swift
//  CalendarUI
//
//  Created by 이지수 on 2022/10/04.
//

import Foundation

public enum Days: Int, CustomStringConvertible, CaseIterable, Codable {
    
    case sun = 1, mon, tue, wed, thu, fri, sat
    
    public var description: String {
        switch self {
        case .sun: return "일"
        case .mon: return "월"
        case .tue: return "화"
        case .wed: return "수"
        case .thu: return "목"
        case .fri: return "금"
        case .sat: return "토"
        }
    }
    
    static var firstWeekday: Days {
        return Days(rawValue: Calendar.current.firstWeekday) ?? .sun
    }
    
    public static var allCases: [Days] {
        var days = [Days]()
        (Calendar.current.firstWeekday...7).forEach {
            days.append(Days(rawValue: $0) ?? firstWeekday)
        }
        (1..<Calendar.current.firstWeekday).forEach {
            days.append(Days(rawValue: $0) ?? firstWeekday)
        }
        return days
    }
}
