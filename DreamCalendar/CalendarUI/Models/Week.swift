//
//  Week.swift
//  CalendarUI
//
//  Created by 이지수 on 2022/10/04.
//

import Foundation

struct Week: Collection {
    let days: [Days: Date]
    
    init(dates: [Date?]) {
        var days = [Days: Date]()
        zip(Days.allCases, dates).forEach({ day, date in
            days[day] = date
        })
        self.days = days
    }
    
    var startIndex : Int { return 0 }
    var endIndex: Int { return days.count - 1 }
    func index(after n: Int) -> Int {
        return n + 1
    }
    subscript(i: Int) -> Date? {
        let weekday = Days.allCases[i]
        return days[weekday]
    }
}
