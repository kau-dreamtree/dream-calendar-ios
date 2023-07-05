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
        let startDate = self.startTime.startOfDay
        let endDate = self.endTime.endOfDay
        return (startDate...endDate) ~= date
    }
}

import CalendarUI

extension Schedule {
    func scheduleForUI(isNotUpdated: Bool) -> CalendarUI.Schedule {
        let schedule = CalendarUI.Schedule(id: self.id,
                                           serverId: Int(self.serverId),
                                           title: self.title,
                                           isAllDay: self.isAllDay,
                                           startTime: self.startTime,
                                           endTime: self.endTime,
                                           tag: CalendarUI.TagUI(rawValue: Int(self.tagId)),
                                           isValid: self.isValid,
                                           isNotUpdated: isNotUpdated)
        return schedule
    }
}
