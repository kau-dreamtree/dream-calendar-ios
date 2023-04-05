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
    private let delegate: AdditionViewPresentDelegate & RefreshMainViewDelegate
    private let scheduleManager: ScheduleManager
    private var cancellables: Set<AnyCancellable> = []
    let tags: [Tag]
    private var mode: Mode
    let date: Date
    
    private let temporarySchedule: TemporarySchedule
    
    private struct TemporarySchedule {
        let title: String
        let isAllDay: Bool
        let startTime: Date
        let endTime: Date
        let tagId: Int16
    }
    
    enum Mode {
        case create, modify, complete
    }
    
    var defaultStartTime: TimeInfo {
        return self.schedule.startTime.toTimeInfo()
    }
    
    var defaultEndTime: TimeInfo {
        return self.schedule.endTime.toTimeInfo()
    }
    
    init(_ manager: ScheduleManager, delegate: AdditionViewPresentDelegate & RefreshMainViewDelegate, schedule: Schedule, mode: Mode, date: Date) {
        self.scheduleManager = manager
        self.delegate = delegate
        self.schedule = schedule
        self.temporarySchedule = TemporarySchedule(title: schedule.title,
                                                   isAllDay: schedule.isValid,
                                                   startTime: schedule.startTime,
                                                   endTime: schedule.endTime,
                                                   tagId: schedule.tagId)
        self.date = date
        self.mode = mode
        self.tags = TagManager.global.tagCollection
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
            switch self.mode {
            case .modify :
                try self.scheduleManager.modifySchedule(self.schedule)
            case .create :
                try self.scheduleManager.addSchedule(self.schedule)
            default :
                break
            }
            self.scheduleManager.removeScheduleAdditionViewModel()
            self.completeExplicitButtonAction()
            
            self.delegate.refreshMainViewSchedule()
            self.delegate.closeAdditionSheet()
        } catch {
            self.error = error
        }
    }
    
    func closeScheduleButtonDidTouched() {
        do {
            self.removeAllBinding()
            switch self.mode {
            case .modify :
                self.restoreChanges()
            case .create :
                try self.scheduleManager.cancelScheduleAddition(self.schedule)
            default :
                break
            }
            self.scheduleManager.removeScheduleAdditionViewModel()
            self.completeExplicitButtonAction()
            
            self.delegate.closeAdditionSheet()
        } catch {
            self.error = error
        }
    }
    
    func implicitCloseButtonDidTouched() {
        guard self.mode != .complete else { return }
        self.closeScheduleButtonDidTouched()
    }
    
    private func completeExplicitButtonAction() {
        self.mode = .complete
    }
    
    private func restoreChanges() {
        self.schedule.title = self.temporarySchedule.title
        self.schedule.isAllDay = self.temporarySchedule.isAllDay
        self.schedule.startTime = self.temporarySchedule.startTime
        self.schedule.endTime = self.temporarySchedule.endTime
        self.schedule.tagId = self.temporarySchedule.tagId
    }
}
