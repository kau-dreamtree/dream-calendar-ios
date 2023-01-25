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

final class MainViewModel: ObservableObject, DateManipulationDelegate {
    
    enum Mode {
        case main, detail, addition
    }
    
    @Published var isDetailMode: Bool = false
    @Published var isWritingMode: Bool = false
    
    @Published var selectedDate: Date
    @Published private(set) var mode: Mode = .main
    @Published private(set) var date: Date
    private(set) var scheduleAdditionViewModel: ScheduleAdditionViewModel? = nil
    private let viewContext: NSManagedObjectContext
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    
    @Published private(set) var schedules: [Schedule]
    @Published var schedulesForSelectedDate: [Schedule]
    
    private(set) var error: Error? = nil
    @Published var isShowAlert: Bool = false
    
    init(_ context: NSManagedObjectContext, selectedYear: Int? = nil, month selectedMonth: Int? = nil, day selectedDay: Int? = 32) {
        
        self.viewContext = context
        
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
        self.schedulesForSelectedDate = []
        self.binding()
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
                return self?.fetchSchedule(withCurrentPage: date) ?? []
            })
            .sink(receiveValue: { schedules in
                self.schedules = schedules
            })
            .store(in: &self.cancellables)
        
        self.$selectedDate
            .afterSet(with: { [weak self] date1, date2 in
                guard date1 == date2 else { return }
                self?.changeMode(.detail)
                self?.isDetailMode.toggle()
            })
            .sink(receiveValue: { _ in })
            .store(in: &self.cancellables)
        
        self.$mode.combineLatest(self.$selectedDate)
            .filter({ mode, _ in
                return mode == .detail
            })
            .map({ [weak self] _, date -> [Schedule] in
                guard let self = self else { return [] }
                return self.schedules.filter({ schedule in
                    schedule.isInclude(with: date)
                })
            })
            .sink(receiveValue: { [weak self] schedules in
                self?.schedulesForSelectedDate = schedules
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
    
    func getScheduleAdditionViewModel() -> ScheduleAdditionViewModel? {
        guard let viewModel = ScheduleAdditionViewModel(self.viewContext, date: self.selectedDate) else {
            self.error = DCError.coreData
            return nil
        }
        self.scheduleAdditionViewModel = viewModel
        return viewModel
    }
    
    func removeScheduleAdditionViewModel() {
        self.scheduleAdditionViewModel?.removeAllBinding()
        self.scheduleAdditionViewModel = nil
    }
    
    func changeError(_ error: Error? = nil) {
        self.error = error
        self.isShowAlert = error != nil
    }
    
    func cancelScheduleAddition(_ schedule: Schedule) {
        self.viewContext.delete(schedule)
        do {
            // TODO: save app crash 해결 필요
            try self.viewContext.save()
        } catch {
            self.changeError(error)
        }
    }
    
    func addSchedule(_ schedule: Schedule) {
        schedule.createLog(self.viewContext, type: .create)
        do {
            try self.viewContext.save()
            self.schedules = self.fetchSchedule(withCurrentPage: self.date)
        } catch {
            self.changeError(error)
        }
    }
    
    func changeMode(_ mode: Mode) {
        self.mode = mode
    }
    
    private func fetchSchedule(withCurrentPage date: Date) -> [Schedule] {
        do {
            let request = Schedule.fetchRequest()
            request.predicate = self.monthRangePredicate(withDate: date)
            return try self.viewContext.fetch(request)
        } catch {
            self.changeError(error)
            return []
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
