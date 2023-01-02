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
    @NSManaged public var server_id: Int64
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
    func tag(context: NSManagedObjectContext) -> Tag {
        let request: NSFetchRequest<Tag> = Tag.fetchRequest()
        request.predicate = NSPredicate(format: "id = %d", self.tagId)
        
        do {
            if let tag = try PersistenceController.shared.fetch(request: request).first {
                return tag
            } else {
                return Tag.defaultTag(context: context, id: self.tagId)
            }
        } catch {
            return Tag.defaultTag(context: context, id: self.tagId)
        }
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
        return log
    }
}

