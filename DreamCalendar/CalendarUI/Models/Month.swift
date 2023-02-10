//
//  Month.swift
//  CalendarUI
//
//  Created by 이지수 on 2022/10/04.
//

import Foundation

struct Month {
    let weeks: [Week]
    
    public init(year: Int = Date().year, month: Int = Date().month) throws {
        let zero = 0
        let one = 1
        let firstDay = 1
        
        guard let startDay = Calendar.current.date(from: DateComponents(calendar: Calendar.current,
                                                                        year: year,
                                                                        month: month,
                                                                        day: firstDay,
                                                                        hour: zero,
                                                                        minute: zero,
                                                                        second: zero)),
              let lastDay = Calendar.current.date(byAdding: DateComponents(calendar: Calendar.current,
                                                                           month: one,
                                                                           day: -one), to: startDay)?.day,
              let firstWeekday = Days.allCases.firstIndex(of: startDay.weekday) else {
            throw CalendarUIError.monthIndexError
        }
        
        let maxWeekCount = 6
        let daysOfWeek = 7
        
        var weeks: [Week] = []
        for week in zero..<maxWeekCount {
            let dates: [Date?] = (zero..<daysOfWeek).map { day in
                let value = daysOfWeek * week + (day - firstWeekday)
                guard value >= zero && value < lastDay else {
                    return nil
                }
                return Calendar.current.date(byAdding: .day, value: daysOfWeek * week + (day - firstWeekday), to: startDay)
            }
            if let week = dates.compactMap({ $0 }).isEmpty ? nil : try Week(week: week, dates: dates) {
                weeks.append(week)
            }
        }
        self.weeks = weeks
    }
}

extension Month: Collection {
    var startIndex : Int {
        let zero = 0
        return zero
    }
    var endIndex: Int { return self.weeks.count }
    
    func index(after n: Int) -> Int {
        let one = 1
        return n + one
    }
    subscript(i: Int) -> Week? {
        return i < self.endIndex ? self.weeks[i] : nil
    }
}
