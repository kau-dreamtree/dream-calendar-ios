//
//  Schedule.swift
//  CalendarUI
//
//  Created by 이지수 on 2022/11/13.
//

import Foundation

public struct Schedule: Codable, Comparable {
    let id: UUID
    let serverId: Int
    let title: String
    let isAllDay: Bool
    let startTime: Date
    let endTime: Date
    let tag: TagUI
    let isValid: Bool
    
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
    public static func <(lhs: Self, rhs: Self) -> Bool {
        if lhs.startTime.year != rhs.startTime.year || lhs.startTime.month != rhs.startTime.month || lhs.startTime.day != rhs.startTime.day {
            return lhs.startTime < rhs.startTime
        } else if lhs.endTime.year != rhs.endTime.year || lhs.endTime.month != rhs.endTime.month || lhs.endTime.day != rhs.endTime.day {
            return lhs.endTime > rhs.endTime
        } else if lhs.isAllDay != rhs.isAllDay {
            return rhs.isAllDay
        } else {
            return lhs.serverId < rhs.serverId
        }
    }
    
    public init(id: UUID, serverId: Int, title: String, isAllDay: Bool, startTime: Date, endTime: Date, tag: TagUI, isValid: Bool) {
        self.id = id
        self.serverId = serverId
        self.title = title
        self.isAllDay = isAllDay
        self.startTime = startTime
        self.endTime = endTime
        self.tag = tag
        self.isValid = isValid
    }
    
    var length: Int {
        guard let startDay = Calendar.current.date(from: DateComponents(
            calendar: Calendar.current,
            year: self.startTime.year,
            month: self.startTime.month,
            day: self.startTime.day)),
              let endDay = Calendar.current.date(from: DateComponents(
            calendar: Calendar.current,
            year: self.endTime.year,
            month: self.endTime.month,
            day: self.endTime.day)) else { return 1 }
        return (Calendar.current.dateComponents([.day], from: startDay, to: endDay).day ?? 0) + 1
    }
    
    func includedWithIn(start baseStartDate: Date, end baseEndDate: Date) -> Bool {
        return (baseStartDate...baseEndDate) ~= self.startTime
        || (baseStartDate...baseEndDate) ~= self.endTime
        || (self.startTime...self.endTime) ~= baseStartDate
    }
}

public struct ScheduleBlock: Codable {
    let schedule: Schedule
    let week: Week
    let length: Int
    let startDay: Days
    let endDay: Days
    
    init(schedule: Schedule, week: Week) {
        self.schedule = schedule
        self.week = week
        
        switch (self.week.isIncluded(date: self.schedule.startTime), self.week.isIncluded(date: self.schedule.endTime)) {
        case (true, true) :     // [n주차 시작, n주차 종료]
            self.length = self.schedule.length
        case (true, false) :    // [n주차 시작, n+1주차 종료],
            self.length = Days.allCases.count - self.schedule.startTime.weekday.rawValue + 1
        case (false, true) :    // [n-1주차 시작, n주차 종료]
            self.length = self.schedule.endTime.weekday.rawValue
        case (false, false):    // [n-1주차 시작, n+1주차 종료]
            self.length = Days.allCases.count
        }
        
        switch self.week.isIncluded(date: self.schedule.startTime) {
        case true :
            self.startDay = self.schedule.startTime.weekday
        case false :
            self.startDay = .sun
        }
        
        switch self.week.isIncluded(date: self.schedule.endTime) {
        case true :
            self.endDay = self.schedule.endTime.weekday
        case false :
            self.endDay = .sat
        }
    }
    
    var isFullColor: Bool {
        return schedule.isAllDay
    }
    
    var title: String {
        return self.schedule.title
    }
    
    func scheduleLine(withFilledMap filledMap: [Days: [Int: Bool]]) -> Int? {
//        let maximumSeenableScheduleLineCount: Int = 7
        
        for line in (0..<WeekView.maximumLineCount) where filledMap[self.startDay]?[line] == false {
            guard (self.startDay...self.endDay).filter({ filledMap[$0]?[line] == true }).isEmpty else { continue }
            return line
        }
        
        return nil
    }
}

public struct Schedules: Codable, Collection {
    let schedulesPerLine: [Int: [ScheduleBlock?]]
    let hasMoreInfo: [Days: Bool]
    
    public var startIndex : Int { return 0 }
    public var endIndex: Int { return schedulesPerLine.keys.count - 1}
    
    static func sortingSchedules(_ schedules: [Schedule], on monthInfo: Month) -> [Schedules] {
        
        let maximumSeenableScheduleLineCount: Int = 7
        
        var isFilledMap: [[Days: [Int: Bool]]] = monthInfo.weeks.map({ _ in [:] })
        (0..<monthInfo.weeks.count).forEach { week in
            Days.allCases.forEach { day in
                isFilledMap[week].updateValue([:], forKey: day)
                (0..<maximumSeenableScheduleLineCount).forEach { line in
                    isFilledMap[week][day]?.updateValue(false, forKey: line)
                }
            }
        }
        
        var schedulesPerWeekOrderByLine: [[Int: [ScheduleBlock]]] = monthInfo.weeks.map({ _ in [:] })
        var hasMoreInfo: [[Days: Bool]] = monthInfo.weeks.map({ _ in [:] })
        
        for schedule in schedules.sorted() {
            for week in monthInfo.weeks where schedule.includedWithIn(start: week.first, end: week.lastTime) {
                let weekIndex = week.week
                let scheduleBlock = ScheduleBlock(schedule: schedule, week: week)
                if let line = scheduleBlock.scheduleLine(withFilledMap: isFilledMap[weekIndex]) {
                    if schedulesPerWeekOrderByLine[weekIndex][line] == nil {
                        schedulesPerWeekOrderByLine[weekIndex].updateValue([], forKey: line)
                    }
                    schedulesPerWeekOrderByLine[weekIndex][line]?.append(scheduleBlock)
                    (scheduleBlock.startDay...scheduleBlock.endDay).forEach { day in
                        isFilledMap[weekIndex][day]?.updateValue(true, forKey: line)
                    }
                } else {
                    hasMoreInfo[weekIndex][scheduleBlock.startDay] = true
                }
            }
        }
        
        let optionalSchedulesPerWeekOrderByLine: [[Int: [ScheduleBlock?]]]
        optionalSchedulesPerWeekOrderByLine = schedulesPerWeekOrderByLine.map({ lineSchedulesList in
            var weekSchedules: [Int: [ScheduleBlock?]] = [:]
            lineSchedulesList.forEach({ line, schedules in
                var currentDay = Days.allCases.first ?? .sun
                var lineSchedules: [ScheduleBlock?] = []
                schedules.forEach { schedule in
                    (currentDay..<schedule.startDay).forEach { _ in
                        lineSchedules.append(nil)
                    }
                    lineSchedules.append(schedule)
                    currentDay = schedule.endDay.advanced(by: 1)
                }
                if lineSchedules.last??.endDay != .sat {
                    (currentDay...(Days.allCases.last ?? .sat)).forEach { _ in
                        lineSchedules.append(nil)
                    }
                }
                weekSchedules.updateValue(lineSchedules, forKey: line)
            })
            return weekSchedules
        })
        
        return (0..<monthInfo.weeks.count).map({ week in
            Schedules(schedulesPerLine: optionalSchedulesPerWeekOrderByLine[week], hasMoreInfo: hasMoreInfo[week])
        })
    }
    
    public func index(after n: Int) -> Int {
        return n + 1
    }
    
    public subscript(i: Int) -> [ScheduleBlock?] {
        return self.schedulesPerLine[i] ?? []
    }
}

public enum TagUI: Int, Codable {
    case babyBlue = 1, green, yellow, orange, red, pink, purple, grey, navy, black
    
    public init(rawValue: Int) {
        switch rawValue {
        case 1 : self = TagUI.babyBlue
        case 2 : self = TagUI.green
        case 3 : self = TagUI.yellow
        case 4 : self = TagUI.orange
        case 5 : self = TagUI.red
        case 6 : self = TagUI.pink
        case 7 : self = TagUI.purple
        case 8 : self = TagUI.grey
        case 9 : self = TagUI.navy
        case 10 : self = TagUI.black
        default : self = TagUI.babyBlue
        }
    }
}
