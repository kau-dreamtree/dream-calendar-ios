//
//  Schedule.swift
//  CalendarUI
//
//  Created by 이지수 on 2022/11/13.
//

import Foundation

public let testSchedules: [Schedule] = [Schedule(id: UUID(),
                                                 serverId: 1111,
                                                 title: "Test1",
                                                 isAllDay: true,
                                                 startTime: Date.now,
                                                 endTime: Calendar.current.date(byAdding: .day,
                                                                                value: 1,
                                                                                to: Date.now) ?? Date.now,
                                                 tag: .babyBlue,
                                                 isValid: true)]

public struct Schedule: Codable {
    let id: UUID
    let serverId: Int
    let title: String
    let isAllDay: Bool
    let startTime: Date
    let endTime: Date
    let tag: TagUI
    let isValid: Bool
    
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
            year: startTime.year,
            month: startTime.month,
            day: startTime.day)),
              let endDay = Calendar.current.date(from: DateComponents(
            calendar: Calendar.current,
            year: endTime.year,
            month: endTime.month,
            day: endTime.day)) else { return 0 }
        return Calendar.current.dateComponents([.day], from: endDay, to: startDay).day ?? 0
    }
    
    func includedWithIn(start baseStartDate: Date, end baseEndDate: Date) -> Bool {
        return (baseStartDate...baseEndDate) ~= self.startTime
        || (baseStartDate...baseEndDate) ~= self.endTime
        || (self.startTime...self.endTime) ~= baseStartDate
    }
}

public struct ScheduleBlock: Codable {
    let schedule: Schedule
    let length: Int
    let week: Week
    let startDay: Days
    
    var isFullColor: Bool {
        return schedule.isAllDay
    }
    
    var title: String {
        return self.schedule.title
    }
}

public struct Schedules: Codable, Collection {
    let schedules: [Days: [ScheduleBlock]]
    
    public var startIndex : Int { return 0 }
    public var endIndex: Int { return schedules.count - 1 }
    
    static func sortingSchedules(_ schedules: [Schedule], on monthInfo: Month) -> [Schedules] {
        var schedulesPerWeek: [[Days: [ScheduleBlock]]] = monthInfo.weeks.map({ week in
            var weekSchedule: [Days: [ScheduleBlock]] = [:]
            week.days.keys.forEach() {
                weekSchedule[$0] = []
            }
            return weekSchedule
        })
        for weekIndex in (0..<monthInfo.count) {
            let week = monthInfo.weeks[weekIndex]
            for schedule in schedules where schedule.includedWithIn(start: week.first, end: week.last) {
                // [n주차 시작, n주차 종료]
                if week.isIncluded(date: schedule.startTime) && week.isIncluded(date: schedule.endTime) {
                    schedulesPerWeek[weekIndex][schedule.startTime.weekday]?
                        .append(ScheduleBlock(schedule: schedule,
                                              length: schedule.length,
                                              week: week,
                                              startDay: schedule.startTime.weekday))
                } else if week.isIncluded(date: schedule.startTime) && !week.isIncluded(date: schedule.endTime) {
                    // [n주차 시작, n+1주차 종료],
                    let length = 8 - schedule.startTime.weekday.rawValue
                    schedulesPerWeek[weekIndex][schedule.startTime.weekday]?
                        .append(ScheduleBlock(schedule: schedule,
                                              length: length,
                                              week: week,
                                              startDay: schedule.startTime.weekday))
                } else if week.isIncluded(date: schedule.endTime) {
                    // [n-1주차 시작, n주차 종료]
                    schedulesPerWeek[weekIndex][.sun]?
                        .append(ScheduleBlock(schedule: schedule,
                                              length: schedule.endTime.weekday.rawValue,
                                              week: week,
                                              startDay: .sun))
                } else {
                    // [n-1주차 시작, n+1주차 종료]
                    schedulesPerWeek[weekIndex][.sun]?
                        .append(ScheduleBlock(schedule: schedule,
                                              length: 7,
                                              week: week,
                                              startDay: .sun))
                }
            }
        }
        return schedulesPerWeek.map({ Schedules(schedules: $0) })
    }
    
    public func index(after n: Int) -> Int {
        return n + 1
    }
    
    public subscript(i: Int) -> [ScheduleBlock] {
        let weekday = Days.allCases[i]
        return self.schedules[weekday] ?? []
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
