//
//  MainViewModel.swift
//  DreamCalendar
//
//  Created by 이지수 on 2022/11/07.
//

import Foundation
import CoreData
import Combine

protocol DateManipulationDelegate {
    mutating func goToToday()
    mutating func goToPreviousMonth()
    mutating func goToNextMonth()
}

protocol RefreshMainViewDelegate {
    func refreshMainViewSchedule()
}

final class MainViewModel: ObservableObject, DateManipulationDelegate, AdditionViewPresentDelegate, RefreshMainViewDelegate {
    
    @Published var isDetailMode: Bool = false
    @Published var isWritingMode: Bool
    @Published var isDetailWritingMode: Bool = false
    
    @Published var selectedDate: Date
    @Published private(set) var date: Date
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    private let scheduleManager: ScheduleManager
    
    @Published private(set) var schedules: [Schedule]
    
    @Published private(set) var error: Error? = nil
    @Published var isShowAlert: Bool = false
    
    var schedulesForSelectedDate: [Schedule] {
        self.schedules.filter({ schedule in
            schedule.isValid && schedule.isInclude(with: self.selectedDate)
        })
    }
    
    init(_ context: NSManagedObjectContext, selectedYear: Int? = nil, month selectedMonth: Int? = nil, day selectedDay: Int? = 32) {
        
        self.scheduleManager = ScheduleManager(viewContext: context)
        
        let year: Int, month: Int, day: Int
        var date = Date()
        
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
        
        date = Calendar.current.date(from: DateComponents(
            calendar: Calendar.current,
            year: year,
            month: month,
            day: day,
            hour: 0,
            minute: 0,
            second: 0)
        ) ?? Date()
        
        self.selectedDate = date
        self.date = date
        self.schedules = []
        self.isWritingMode = false
        self.binding()
    }
    
    deinit {
        self.cancellables.removeAll()
    }
    
    var currentTopTitle: String {
        return "\(String(self.date.year))년 \(self.date.month)월"
    }
    
    var isToday: Bool {
        let today = Date()
        return self.date.year == today.year && self.date.month == today.month && self.date.day == today.day
    }
    
    private func binding() {
        self.$date
            .map({ [weak self] date -> [Schedule] in
                return (try? self?.scheduleManager.getSchedule(in: date) ?? []) ?? []
            })
            .sink(receiveValue: { schedules in
                self.schedules = schedules
            })
            .store(in: &self.cancellables)
        
        self.$selectedDate
            .afterSet(with: { [weak self] date1, date2 in
                guard date1 == date2 else { return }
                self?.isDetailMode.toggle()
            })
            .sink(receiveValue: { _ in })
            .store(in: &self.cancellables)
        
        self.$error
            .map({
                return $0 != nil
            })
            .sink(receiveValue: { [weak self] result in
                self?.isShowAlert = result
            })
            .store(in: &self.cancellables)
    }
    
    func goToToday() {
        self.selectedDate = Date.today
        self.date = Date.today
    }
    
    func goToPreviousMonth() {
        self.date = Calendar.current.date(byAdding: .month,
                                          value: -1,
                                          to: self.date) ?? Date.now
    }
    
    func goToNextMonth() {
        self.date = Calendar.current.date(byAdding: .month,
                                          value: +1,
                                          to: self.date) ?? Date.now
    }
    
    private func monthRangePredicate(withDate date: Date) -> NSPredicate {
        let firstDay = Calendar.current.date(from: DateComponents(
            calendar: Calendar.current,
            year: date.year,
            month: date.month,
            day: 1,
            hour: 0,
            minute: 0,
            second: 0,
            nanosecond: 0
        )) ?? Date.now
        
        let nextMonthFirstDay = Calendar.current.date(byAdding: .month,
                                                      value: +1,
                                                      to: firstDay) ?? Date.now
        
        let lastDay = Calendar.current.date(byAdding: .nanosecond,
                                            value: -1,
                                            to: nextMonthFirstDay) ?? Date.now
        
        let firstDayCVar = firstDay as CVarArg
        let lastDayCVar = lastDay as CVarArg
        
        return NSPredicate(format: "%@ <= startTime AND startTime <= %@ AND %@ <= endTime AND endTime <= %@", firstDayCVar, lastDayCVar, firstDayCVar, lastDayCVar)
    }
    
    func getScheduleAdditionViewModel() -> ScheduleAdditionViewModel {
        return self.scheduleManager.getScheduleAdditionViewModel(withDate: self.selectedDate, andDelegate: self)
    }
    
    func getDetailViewModel(about schedule: Schedule, with delegate: ScheduleDetailViewDelegate) -> ScheduleDetailViewModel {
        return ScheduleDetailViewModel(schedule: schedule,
                                       scheduleManager: self.scheduleManager,
                                       date: self.selectedDate,
                                       delegate: delegate,
                                       scheduleEditingDelegate: self)
    }
    
    func changeError(_ error: Error? = nil) {
        self.error = error
    }
    
    func closeDetailSheet() {
        self.isDetailMode = false
    }
    
    func closeAdditionSheet() {
        if self.isDetailMode {
            self.isDetailWritingMode = false
        } else {
            self.isWritingMode = false
        }
    }
    
    func openDetailSheet() {
        self.isDetailMode = true
    }
    
    func openAdditionSheet() {
        if self.isDetailMode {
            self.isDetailWritingMode = true
        } else {
            self.isWritingMode = true
        }
    }
    
    func refreshMainViewSchedule() {
        do {
            self.schedules = try self.scheduleManager.getSchedule(in: self.date)
        } catch {
            self.error = error
        }
    }
}

fileprivate extension Date {
    static let today: Date = {
        var date = Date()
        
        date = Calendar.current.date(from: DateComponents(
            calendar: Calendar.current,
            year: date.year,
            month: date.month,
            day: date.day,
            hour: 0,
            minute: 0,
            second: 0)
        ) ?? Date()
        
        return date
    }()
}

fileprivate extension Published<Date>.Publisher where Output == Date {
    func afterSet(with compare: @escaping (Date, Date) -> Void) -> AnyPublisher<Date, Never> {
        return self.removeDuplicates(by: { date1, date2 in
            compare(date1, date2)
            return false
        }).eraseToAnyPublisher()
    }
}
