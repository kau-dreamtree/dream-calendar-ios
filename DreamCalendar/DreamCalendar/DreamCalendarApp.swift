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
//            MainView(viewModel: MainViewModel(self.persistenceController.container.viewContext))
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
            LoginView(viewModel: LoginViewModel())
        }
    }
}
