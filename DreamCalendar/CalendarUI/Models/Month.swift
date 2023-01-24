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
        guard let startDay = Calendar.current.date(from: DateComponents(calendar: Calendar.current,
                                                                        year: year,
                                                                        month: month,
                                                                        day: 1,
                                                                        hour: 0,
                                                                        minute: 0,
                                                                        second: 0)),
              let lastDay = Calendar.current.date(byAdding: DateComponents(calendar: Calendar.current,
                                                                           month: 1,
                                                                           day: -1), to: startDay)?.day,
              let firstWeekday = Days.allCases.firstIndex(of: startDay.weekday) else {
            throw CalendarUIError.monthIndexError
        }
        
        var weeks: [Week] = []
        for week in 0..<6 {
            let dates: [Date?] = (0..<7).map { day in
                let value = 7*week+(day-firstWeekday)
                guard value >= 0 && value < lastDay else {
                    return nil
                }
                return Calendar.current.date(byAdding: .day, value: 7*week+(day-firstWeekday), to: startDay)
            }
            if let week = dates.compactMap({ $0 }).isEmpty ? nil : try Week(week: week, dates: dates) {
                weeks.append(week)
            }
        }
        print(weeks.first?.first)
        self.weeks = weeks
    }
}

extension Month: Collection {
    var startIndex : Int { return 0 }
    var endIndex: Int { return self.weeks.count }
    
    func index(after n: Int) -> Int {
        return n + 1
    }
    subscript(i: Int) -> Week? {
        return i < self.endIndex ? self.weeks[i] : nil
    }
}
