//
//  ScheduleAdditionViewModel.swift
//  DreamCalendar
//
//  Created by 이지수 on 2022/12/26.
//

import Foundation
import Combine
import CoreData

final class ScheduleAdditionViewModel: ObservableObject {
    
    @Published var schedule: Schedule
    @Published private var error: Error? = nil
    let viewContext: NSManagedObjectContext
    private let delegate: AdditionViewPresentDelegate & RefreshMainViewDelegate
    private let scheduleManager: ScheduleManager
    private var cancellables: Set<AnyCancellable> = []
    let date: Date
    
    var defaultStartTime: TimeInfo {
        return self.schedule.startTime.toTimeInfo()
    }
    
    var defaultEndTime: TimeInfo {
        return self.schedule.endTime.toTimeInfo()
    }
    
    init(_ manager: ScheduleManager, delegate: AdditionViewPresentDelegate & RefreshMainViewDelegate, schedule: Schedule, date: Date) {
        self.scheduleManager = manager
        self.viewContext = manager.viewContext
        self.delegate = delegate
        self.schedule = schedule
        self.date = date
        self.setScheduleTimeConstraint()
    }
    
    private func setScheduleTimeConstraint() {
        self.schedule.publisher(for: \.startTime)
            .filter({ [weak self] startTime in
                guard let self = self else { return true }
                return startTime >= self.schedule.endTime
            })
            .map({ date in
                return Calendar.current.date(byAdding: .hour,
                                             value: +1,
                                             to: date) ?? date
            })
            .sink(receiveValue: { [weak self] endTime in
                self?.schedule.endTime = endTime
            })
            .store(in: &self.cancellables)
        
        self.schedule.publisher(for: \.endTime)
            .filter({ [weak self] endTime in
                guard let self = self else { return true }
                return self.schedule.startTime >= endTime
            })
            .map({ date in
                return Calendar.current.date(byAdding: .hour,
                                             value: -1,
                                             to: date) ?? date
            })
            .sink(receiveValue: { [weak self] startTime in
                self?.schedule.startTime = startTime
            })
            .store(in: &self.cancellables)
    }
    
    private func removeAllBinding() {
        self.cancellables.removeAll()
    }
    
    func uploadScheduleButtonDidTouched() {
        do {
            self.removeAllBinding()
            try self.scheduleManager.addSchedule(self.schedule)
            self.scheduleManager.removeScheduleAdditionViewModel()
            
            self.delegate.refreshMainViewSchedule()
            self.delegate.closeAdditionSheet()
        } catch {
            self.error = error
        }
    }
    
    func closeScheduleButtonDidTouched() {
        do {
            self.removeAllBinding()
            try self.scheduleManager.cancelScheduleAddition(self.schedule)
            self.scheduleManager.removeScheduleAdditionViewModel()
            
            self.delegate.closeAdditionSheet()
        } catch {
            self.error = error
        }
    }
}
