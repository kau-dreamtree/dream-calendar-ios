//
//  Month.swift
//  CalendarUI
//
//  Created by 이지수 on 2022/10/04.
//

import Foundation

struct Month: Collection {
    let weeks: [Week]
    
    init(date: (year: Int, month: Int)?) throws {
        let stringDate: String
        if let date = date {
            stringDate = "\(date.year)-\(date.month)-1"
        } else {
            let date = Date()
            stringDate = "\(date.year)-\(date.month)-1"
        }
        
        guard let startDay = DateFormatter.DCdateFormatter.date(from: stringDate),
              let nextMonthFirstDay = Calendar.current.date(byAdding: .month, value: 1, to: startDay) ,
              let lastDay = Calendar.current.date(byAdding: .day, value: -1, to: nextMonthFirstDay)?.day,
              let firstWeekday = Days.allCases.firstIndex(of: startDay.weekday) else {
            throw CalendarUIError.monthIndexError
        }
        
        self.weeks = (0..<5).map { week in
            let dates: [Date?] = (0..<7).map { day in
                let value = 7*week+(day-firstWeekday)
                guard value >= 0 && value <= lastDay else {
                    return nil
                }
                return Calendar.current.date(byAdding: .day, value: 7*week+(day-firstWeekday), to: startDay)
            }
            return Week(dates: dates)
        }
    }
    
    var startIndex : Int { return 0 }
    var endIndex: Int { return weeks.count - 1 }
    func index(after n: Int) -> Int {
        return n + 1
    }
    subscript(i: Int) -> Week? {
        return i <= endIndex ? weeks[i] : nil
    }
}
