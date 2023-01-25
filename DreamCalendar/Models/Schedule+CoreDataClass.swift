//
//  Schedule+CoreDataClass.swift
//  DreamCalendar
//
//  Created by 이지수 on 2022/12/26.
//
//

import Foundation
import CoreData


public class Schedule: NSManagedObject {
    
    func isInclude(with date: Date) -> Bool {
        let startDate = Calendar.current.date(from: DateComponents(
            calendar: Calendar.current,
            year: self.startTime.year,
            month: self.startTime.month,
            day: self.startTime.day,
            hour: 0,
            minute: 0,
            second: 0)
        ) ?? self.startTime
        let endDate = Calendar.current.date(from: DateComponents(
            calendar: Calendar.current,
            year: self.endTime.year,
            month: self.endTime.month,
            day: self.endTime.day,
            hour: 23,
            minute: 59,
            second: 59)
        ) ?? self.endTime
        return (startDate...endDate) ~= date
    }
}

import CalendarUI

extension Schedule {
    var scheduleForUI: CalendarUI.Schedule {
        let schedule = CalendarUI.Schedule(id: self.id,
                                           serverId: Int(self.server_id),
                                           title: self.title,
                                           isAllDay: self.isAllDay,
                                           startTime: self.startTime,
                                           endTime: self.endTime,
                                           tag: CalendarUI.TagUI(rawValue: Int(self.tagId)),
                                           isValid: self.isValid)
        return schedule
    }
}
