//
//  Schedule+CoreDataProperties.swift
//  DreamCalendar
//
//  Created by 이지수 on 2022/12/26.
//
//

import Foundation
import CoreData


extension Schedule {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Schedule> {
        return NSFetchRequest<Schedule>(entityName: "Schedule")
    }

    @NSManaged public var id: UUID
    @NSManaged public var serverId: Int64
    @NSManaged public var title: String
    @NSManaged public var isAllDay: Bool
    @NSManaged public var startTime: Date
    @NSManaged public var endTime: Date
    @NSManaged public var isValid: Bool
    @NSManaged public var tagId: Int16
}

extension Schedule : Identifiable {

}

extension Schedule {
    var tag: Tag {
        return TagManager.global.tag(id: self.tagId)
    }
    
    var tagType: TagType {
        return TagType(rawValue: Int(self.tagId)) ?? .babyBlue
    }
    
    func createLog(_ context: NSManagedObjectContext, type: UpdateLogType) -> ScheduleUpdateLog {
        let log = ScheduleUpdateLog(context: context)
        log.id = UUID()
        log.schedule = self
        log.type = Int16(type.rawValue)
        log.synchronization = false
        log.createdDate = Date()
        return log
    }
}

extension Schedule: Comparable {
    public static func <(lhs: Schedule, rhs: Schedule) -> Bool {
        if lhs.startTime.year != rhs.startTime.year || lhs.startTime.month != rhs.startTime.month || lhs.startTime.day != rhs.startTime.day {
            return lhs.startTime < rhs.startTime
        } else if lhs.endTime.year != rhs.endTime.year || lhs.endTime.month != rhs.endTime.month || lhs.endTime.day != rhs.endTime.day {
            return lhs.endTime > rhs.endTime
        } else if lhs.isAllDay != rhs.isAllDay {
            return lhs.isAllDay
        } else {
            return lhs.startTime < rhs.startTime
        }
    }
}
