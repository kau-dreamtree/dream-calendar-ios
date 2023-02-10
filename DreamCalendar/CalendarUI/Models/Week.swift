//
//  Week.swift
//  CalendarUI
//
//  Created by 이지수 on 2022/10/04.
//

import Foundation

struct Week: Codable, Collection {
    private let startDay: Date
    private let endDay: Date
    let week: Int
    let days: [Days: Date]
    
    init(week: Int, dates: [Date?]) throws {
        let compactDates: [Date] = dates.compactMap({ $0 })
        guard let startDay = compactDates.first,
              let endDay = compactDates.last else {
            throw CalendarUIError.weekIndexError
        }
        self.week = week
        self.startDay = startDay
        self.endDay = endDay
        
        var days = [Days: Date]()
        zip(Days.allCases, dates).forEach({ day, date in
            days[day] = date
        })
        self.days = days
    }
    
    var startIndex : Int {
        return (days.keys.sorted(by: { $0.rawValue < $1.rawValue }).first?.rawValue ?? 1) - 1
    }
    var endIndex: Int {
        return (days.keys.sorted(by: { $0.rawValue > $1.rawValue }).first?.rawValue ?? days.count) - 1
    }
    
    var first: Date {
        let weekday = Days.allCases[startIndex]
        return days[weekday] ?? startDay
    }
    
    var last: Date {
        let weekday = Days.allCases[endIndex]
        return days[weekday] ?? endDay
    }
    
    var lastTime: Date {
        let one = 1
        let zero = 0
        
        guard let nextDay = Calendar.current.date(byAdding: .day, value: one, to: self.last) else { return self.last }
        let StartOfnextDay = Calendar.current.date(from: DateComponents(calendar: Calendar.current,
                                                                        year: nextDay.year,
                                                                        month: nextDay.month,
                                                                        day: nextDay.day,
                                                                        hour: zero,
                                                                        minute: zero,
                                                                        second: zero,
                                                                        nanosecond: zero)) ?? self.last
        return Calendar.current.date(byAdding: .nanosecond, value: -one, to: StartOfnextDay) ?? self.last
    }
    
    func isIncluded(date: Date) -> Bool {
        return (self.first...self.lastTime) ~= date
    }
    
    func index(after n: Int) -> Int {
        let unit = 1
        return n + unit
    }
    
    subscript(i: Int) -> Date? {
        let weekday = Days.allCases[i]
        return days[weekday]
    }
}
