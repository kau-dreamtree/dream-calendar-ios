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
        let lastTime = Calendar.current.date(from: DateComponents(calendar: Calendar.current,
                                                                  year: self.last.year,
                                                                  month: self.last.month,
                                                                  day: self.last.day,
                                                                  hour: 24,
                                                                  minute: 0,
                                                                  second: 0)) ?? endDay
        return lastTime
    }
    
    func isIncluded(date: Date) -> Bool {
        return (self.first...self.lastTime) ~= date
    }
    
    func index(after n: Int) -> Int {
        return n + 1
    }
    
    subscript(i: Int) -> Date? {
        let weekday = Days.allCases[i]
        return days[weekday]
    }
}
