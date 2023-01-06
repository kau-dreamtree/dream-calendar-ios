//
//  PersistentContainer.swift
//  DreamCalendar
//
//  Created by 이지수 on 2022/12/26.
//

import CoreData

extension NSPersistentContainer {
    static let DCPresistentContainer = {
        let containerName = "DreamCalendar"
        let container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error = error as NSError? {
                fatalError("CoreData load Error", line: 14)
            }
        })
        return container
    }
}
