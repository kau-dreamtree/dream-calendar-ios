//
//  Month.swift
//  CalendarUI
//
//  Created by 이지수 on 2022/10/04.
//

import Foundation

struct Month: Collection {
    let weeks: [Week]
    
    init(year: Int = Date().year, month: Int = Date().month) throws {
        guard let startDay = Calendar.current.date(from: DateComponents(calendar: Calendar.current, year: year, month: month, day: 1)),
              let lastDay = Calendar.current.date(byAdding: DateComponents(calendar: Calendar.current, month: 1, day: -1), to: startDay)?.day,
              let firstWeekday = Days.allCases.firstIndex(of: startDay.weekday) else {
            throw CalendarUIError.monthIndexError
        }
        
        self.weeks = (0..<6).compactMap { week in
            let dates: [Date?] = (0..<7).map { day in
                let value = 7*week+(day-firstWeekday)
                guard value >= 0 && value < lastDay else {
                    return nil
                }
                return Calendar.current.date(byAdding: .day, value: 7*week+(day-firstWeekday), to: startDay)
            }
            return dates.compactMap({ $0 }).isEmpty ? nil : Week(dates: dates)
        }
    }
    
    var startIndex : Int { return 0 }
    var endIndex: Int { return self.weeks.count }
    func index(after n: Int) -> Int {
        return n + 1
    }
    subscript(i: Int) -> Week? {
        return i < self.endIndex ? self.weeks[i] : nil
    }
}
