//
//  HolidayAnniversary+CoreDataProperties.swift
//  DreamCalendar
//
//  Created by 이지수 on 2022/12/26.
//
//

import Foundation
import CoreData


extension HolidayAnniversary {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HolidayAnniversary> {
        return NSFetchRequest<HolidayAnniversary>(entityName: "HolidayAnniversary")
    }

    @NSManaged public var server_id: Int64
    @NSManaged public var title: String
    @NSManaged public var startDate: Date
    @NSManaged public var type: Int16
    @NSManaged public var repeated: Bool
    @NSManaged public var endDate: Date

}

extension HolidayAnniversary : Identifiable {

}
