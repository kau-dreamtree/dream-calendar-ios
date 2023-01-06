//
//  TagUpdateLog+CoreDataProperties.swift
//  DreamCalendar
//
//  Created by 이지수 on 2022/12/26.
//
//

import Foundation
import CoreData


extension TagUpdateLog {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TagUpdateLog> {
        return NSFetchRequest<TagUpdateLog>(entityName: "TagUpdateLog")
    }

    @NSManaged public var id: UUID
    @NSManaged public var synchronization: Bool
    @NSManaged public var tag: Tag

}

extension TagUpdateLog : Identifiable {

}
