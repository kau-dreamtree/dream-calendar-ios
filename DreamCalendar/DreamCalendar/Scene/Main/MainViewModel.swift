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
    
    static let centerIndex: Int = 2
    
    @Published var isDetailMode: Bool = false
    @Published var isWritingMode: Bool
    @Published var isDetailWritingMode: Bool = false
    
    @Published var selectedDate: Date
    @Published var date: Date
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    let scheduleManager: ScheduleManager
    
    @Published private(set) var schedules: [Date: [(Schedule, Bool)]]
    @Published private(set) var error: Error? = nil
    @Published var isShowAlert: Bool = false
    
    var schedulesForSelectedDate: [(Schedule, Bool)]
    
    var scheduleCollection: [(date: Date, schedules: [(Schedule, Bool)])] {
        return self.schedules.map({ (date: $0.key, schedules: $0.value) }).sorted(by: { $0.date < $1.date })
    }
    
    init(_ scheduleManager: ScheduleManager, selectedYear: Int? = nil, month selectedMonth: Int? = nil, day selectedDay: Int? = 32) {
        
        self.scheduleManager = scheduleManager
        
        let year: Int, month: Int, day: Int
        var selectedDate = Date()
        
        if let selectedYear = selectedYear {
            year = selectedYear
        } else {
            year = selectedDate.year
        }
        
        if let selectedMonth = selectedMonth, (1...12) ~= selectedMonth {
            month = selectedMonth
        } else {
            month = selectedDate.month
        }
        
        if let selectedDay = selectedDay, (1...31) ~= selectedDay {
            day = selectedDay
        } else {
            day = selectedDate.day
        }
        
        selectedDate = Calendar.current.date(from: DateComponents(
            calendar: Calendar.current,
            year: year,
            month: month,
            day: day))?.startOfDay ?? Date()
        
        self.selectedDate = selectedDate
        self.date = selectedDate.firstDayOfMonth
        self.schedules = [:]
        self.schedulesForSelectedDate = []
        self.isWritingMode = false
        self.error = nil
        self.isShowAlert = false
        self.fetchAllSchedules(with: self.date)
        self.binding()
        
        NotificationCenter.default.addObserver(forName: .backgroundUpdated, object: nil, queue: nil) { [weak self] _ in
            self?.refreshMainViewSchedule()
        }
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
        self.$selectedDate
            .afterSet(with: { [weak self] date1, date2 in
                guard date1 == date2 else { return }
                self?.isDetailMode.toggle()
            })
            .sink(receiveValue: { [weak self] date in
                guard let self = self else { return }
                self.schedulesForSelectedDate = self.schedulesOnDate(date: date)
            })
            .store(in: &self.cancellables)
        
        self.$error
            .map({
                return $0 != nil
            })
            .sink(receiveValue: { [weak self] result in
                self?.isShowAlert = result
            })
            .store(in: &self.cancellables)
        
        self.$date
            .sink { [weak self] date in
                guard let self = self else { return }
                if self.schedules[date.previousMonth.previousMonth] == nil {
                    self.fetchSchedules(with: date.previousMonth.previousMonth)
                    self.schedules[date.nextMonth.nextMonth.nextMonth] = nil
                }
                if self.schedules[date.nextMonth.nextMonth] == nil {
                    self.fetchSchedules(with: date.nextMonth.nextMonth)
                    self.schedules[date.previousMonth.previousMonth.previousMonth] = nil
                }
            }
            .store(in: &self.cancellables)
    }
    
    func changeIndex(_ index: Int) {
        let pageUnit = 1
        switch index {
        case Self.centerIndex - pageUnit :
            self.date = self.date.previousMonth
        case Self.centerIndex + pageUnit :
            self.date = self.date.nextMonth
        default :
            break
        }
    }
    
    func goToToday() {
        self.selectedDate = Date.today
        self.date = self.selectedDate.firstDayOfMonth
    }
    
    func goToPreviousMonth() {
        self.date = self.date.previousMonth
    }
    
    func goToNextMonth() {
        self.date = self.date.nextMonth
    }
    
    private func fetchAllSchedules(with current: Date) {
        DispatchQueue.main.async {
            self.fetchSchedules(with: current.previousMonth.previousMonth)
            self.fetchSchedules(with: current.previousMonth)
            self.fetchSchedules(with: current)
            self.fetchSchedules(with: current.nextMonth)
            self.fetchSchedules(with: current.nextMonth.nextMonth)
        }
    }
    
    private func fetchSchedules(with date: Date) {
        do {
            let schedules = try self.scheduleManager.getSchedule(in: date)
            let notUpdatedSchedules = Set(self.scheduleManager.localCommitLog.map({ $0.schedule }))
            self.schedules.updateValue(schedules.map({($0, notUpdatedSchedules.contains($0) == false)}), forKey: date)
        } catch {
            self.changeError(DCError.coreData(error))
        }
    }
    
    private func monthRangePredicate(withDate date: Date) -> NSPredicate {
        let firstDay = date.firstDayOfMonth
        let nextMonthFirstDay = firstDay.nextMonth
        let lastDay = Calendar.current.date(byAdding: .second,
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
        DispatchQueue.main.async {
            self.fetchAllSchedules(with: self.date)
            self.schedulesForSelectedDate = self.schedulesOnDate(date: self.selectedDate)
        }
    }
    
    private func schedulesOnDate(date: Date) -> [(Schedule, Bool)] {
        return self.schedules[date.firstDayOfMonth]?.map({$0.0}).filter({ schedule in
            return schedule.isValid && schedule.isInclude(with: date)
        }).map({ [weak self] schedule in
            return (schedule, self?.scheduleManager.notUpdatedSchedules.contains(schedule) == true)
        }) ?? []
    }
}

fileprivate extension Date {
    static let today: Date = {
        return Date().firstDayOfMonth
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
