//
//  MainViewModel.swift
//  DreamCalendar
//
//  Created by 이지수 on 2022/11/07.
//

import Foundation
import CoreData

protocol DateManipulationDelegate {
    mutating func goToToday()
    mutating func goToPreviousMonth()
    mutating func goToNextMonth()
}

class MainViewModel: ObservableObject, DateManipulationDelegate {
    
    @Published private(set) var selectedDate: Date
    private(set) var scheduleAdditionViewModel: ScheduleAdditionViewModel? = nil
    private let viewContext: NSManagedObjectContext
    
    @Published private(set) var schedules: [Schedule]
    
    private(set) var error: Error? = nil
    @Published var isShowAlert: Bool = false
    
    init(_ context: NSManagedObjectContext, selectedYear: Int? = nil, month selectedMonth: Int? = nil, day selectedDay: Int? = 32) {
        
        self.viewContext = context
        
        let year: Int, month: Int, day: Int
        let date = Date()
        
        if let selectedYear = selectedYear {
            year = selectedYear
        } else {
            year = date.year
        }
        
        if let selectedMonth = selectedMonth, (1...12) ~= selectedMonth {
            month = selectedMonth
        } else {
            month = date.month
        }
        
        if let selectedDay = selectedDay, (1...31) ~= selectedDay {
            day = selectedDay
        } else {
            day = date.day
        }
        
        self.selectedDate = Calendar.current.date(from: DateComponents(
            calendar: Calendar.current,
            year: year,
            month: month,
            day: day)
        ) ?? Date()
        
        self.schedules = []
        self.binding()
    }
    
    var currentTopTitle: String {
        return "\(String(self.selectedDate.year))년 \(self.selectedDate.month)월"
    }
    
    var isToday: Bool {
        let today = Date()
        return self.selectedDate.year == today.year && self.selectedDate.month == today.month
    }
    
    private func binding() {
        self.$selectedDate
            .map({ [weak self] date -> [Schedule] in
                return self?.fetchSchedule(withCurrentPage: date) ?? []
            })
            .assign(to: &self.$schedules)
    }
    
    func goToToday() {
        self.selectedDate = Date()
    }
    
    func goToPreviousMonth() {
        self.selectedDate = Calendar.current.date(byAdding: .month,
                                                  value: -1,
                                                  to: self.selectedDate) ?? Date.now
    }
    
    func goToNextMonth() {
        self.selectedDate = Calendar.current.date(byAdding: .month,
                                                  value: +1,
                                                  to: self.selectedDate) ?? Date.now
    }
    
    private func monthRangePredicate(withDate date: Date) -> NSPredicate {
        let firstDay = Calendar.current.date(from: DateComponents(
            calendar: Calendar.current,
            year: date.year,
            month: date.month,
            day: 1
        )) ?? Date.now
        
        let nextMonthFirstDay = Calendar.current.date(byAdding: .month,
                                                      value: +1,
                                                      to: firstDay) ?? Date.now
        
        let lastDay = Calendar.current.date(byAdding: .day,
                                            value: -1,
                                            to: nextMonthFirstDay) ?? Date.now
        
        let firstDayCVar = firstDay as CVarArg
        let lastDayCVar = lastDay as CVarArg
        
        return NSPredicate(format: "%@ <= startTime AND startTime <= %@ AND %@ <= endTime AND endTime <= %@", firstDayCVar, lastDayCVar, firstDayCVar, lastDayCVar)
    }
    
    func chooseSpecificDay(year: Int? = nil, month: Int? = nil, day: Int? = nil) {
        self.selectedDate = Calendar.current.date(from: DateComponents(
            calendar: Calendar.current,
            year: year ?? self.selectedDate.year,
            month: month ?? self.selectedDate.month,
            day: day ?? self.selectedDate.day)
        ) ?? Date()
    }
    
    func getScheduleAdditionViewModel() -> ScheduleAdditionViewModel? {
        guard let viewModel = ScheduleAdditionViewModel(self.viewContext, date: self.selectedDate) else {
            self.error = DCError.coreData
            return nil
        }
        self.scheduleAdditionViewModel = viewModel
        return viewModel
    }
    
    func removeScheduleAdditionViewModel() {
        self.scheduleAdditionViewModel = nil
    }
    
    func changeError(_ error: Error? = nil) {
        self.error = error
        self.isShowAlert = error != nil
    }
    
    func cancelScheduleAddition(_ schedule: Schedule) {
        self.viewContext.delete(schedule)
    }
    
    func addSchedule(_ schedule: Schedule) {
        schedule.log(self.viewContext, type: .create)
        do {
            try self.viewContext.save()
            self.schedules = self.fetchSchedule(withCurrentPage: self.selectedDate)
        } catch {
            self.changeError(error)
        }
    }
    
    private func fetchSchedule(withCurrentPage date: Date) -> [Schedule] {
        do {
            let request = Schedule.fetchRequest()
            request.predicate = self.monthRangePredicate(withDate: self.selectedDate)
            return try self.viewContext.fetch(request)
        } catch {
            self.changeError(error)
            return []
        }
    }
}
