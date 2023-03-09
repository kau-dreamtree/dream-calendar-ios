//
//  ScheduleUpdateLog+CoreDataProperties.swift
//  DreamCalendar
//
//  Created by 이지수 on 2022/12/26.
//
//

import Foundation
import CoreData


extension ScheduleUpdateLog {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ScheduleUpdateLog> {
        return NSFetchRequest<ScheduleUpdateLog>(entityName: "ScheduleUpdateLog")
    }

    @NSManaged public var id: UUID
    @NSManaged public var type: Int16
    @NSManaged public var synchronization: Bool
    @NSManaged public var createdDate: Date
    @NSManaged public var schedule: Schedule

}

extension ScheduleUpdateLog : Identifiable {

}

enum UpdateLogType : Int {
    case create = 1, update, delete
}
