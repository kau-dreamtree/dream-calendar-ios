//
//  DreamCalendarApp.swift
//  DreamCalendar
//
//  Created by 이지수 on 2022/10/03.
//

import SwiftUI

@main
struct DreamCalendarApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
