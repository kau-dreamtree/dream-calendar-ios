//
//  TagManager.swift
//  DreamCalendar
//
//  Created by 이지수 on 2023/02/05.
//

import Foundation
import CoreData

final class TagManager {
    static private(set) var global: TagManager = TagManager(viewContext: NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType))
    
    static let tagKeys = (1...TagType.allCases.count)
    
    private let viewContext: NSManagedObjectContext
    private var tags: [Int:Tag] = [:]
    
    var tagCollection: [Tag] {
        return Self.tagKeys.compactMap({ self.tags[$0] }).sorted()
    }
    
    private init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    static func initializeGlobalTagManager (with context: NSManagedObjectContext) throws {
        let manager = TagManager(viewContext: context)
        let tags = try? manager.fetchAllTag()
        tags?.forEach() { tag in
            manager.tags.updateValue(tag, forKey: Int(tag.id))
        }
        Self.tagKeys.forEach { key in
            guard manager.tags[key] == nil else { return }
            let tag = Tag.defaultTag(context: context, id: Int16(key))
            manager.tags.updateValue(tag, forKey: key)
        }
        try context.save()
        Self.global = manager
        return
    }
    
    private func fetchAllTag() throws -> [Tag] {
        let request = Tag.fetchRequest()
        return try self.viewContext.fetch(request)
    }
    
    func saveTagChange() throws {
        try self.viewContext.save()
        let tags = try self.fetchAllTag()
        tags.forEach() { tag in
            if self.tags[Int(tag.id)] != tag {
                // TODO: TagUpdateLog 기록 추가
            }
            self.tags.updateValue(tag, forKey: Int(tag.id))
        }
    }
    
    func reinitializeAll() throws {
        Self.tagKeys.forEach { key in
            guard var tag = self.tags[key] else { return }
            tag.order = tag.type.defaultOrder
            tag.title = tag.type.defaultTitle
        }
        
        
        try self.viewContext.save()
    }
    
    func tag(id: Int16) -> Tag {
        self.tags[Int(id)] ?? .defaultTag(context: self.viewContext, id: id)
    }
}
