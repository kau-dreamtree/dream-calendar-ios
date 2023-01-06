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
