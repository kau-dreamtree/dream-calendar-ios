//
//  Tag+CoreDataProperties.swift
//  DreamCalendar
//
//  Created by 이지수 on 2022/12/26.
//
//

import Foundation
import CoreData


extension Tag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }

    @NSManaged public var id: Int16
    @NSManaged public var order: Int16
    @NSManaged public var title: String

}

extension Tag : Identifiable {

}

extension Tag {
    
    static func defaultTag(context: NSManagedObjectContext, id: Int16) -> Tag {
        let tagType = TagType(rawValue: Int(id)) ?? .babyBlue
        
        let tag = Tag(context: context)
        tag.id = tagType.id
        tag.order = tagType.defaultOrder
        tag.title = tagType.defaultTitle
        return tag
    }
    
    var type: TagType {
        return TagType(rawValue: Int(self.id)) ?? .babyBlue
    }
}


extension Tag: Comparable {
    public static func <(lhs: Tag, rhs: Tag) -> Bool {
        return lhs.order < rhs.order
    }
}
